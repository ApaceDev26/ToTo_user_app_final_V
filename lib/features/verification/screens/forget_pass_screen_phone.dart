import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:toto_user/common/widgets/validate_check.dart';
import 'package:toto_user/features/language/controllers/localization_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/verification/controllers/verification_controller.dart';
import 'package:toto_user/features/verification/screens/verification_screen.dart';
import 'package:toto_user/features/verification/screens/forget_pass_screen.dart';
import 'package:toto_user/helper/custom_validator.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/util/styles.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassScreenPhone extends StatefulWidget {
  final bool fromDialog;
  const ForgetPassScreenPhone({super.key, this.fromDialog = false});

  @override
  State<ForgetPassScreenPhone> createState() => _ForgetPassScreenPhoneState();
}

class _ForgetPassScreenPhoneState extends State<ForgetPassScreenPhone> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _numberFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  String? _countryDialCode = CountryCode.fromCountryCode(
          Get.find<SplashController>().configModel!.country!)
      .dialCode;
  GlobalKey<FormState>? _formKeyLogin;
  bool isEmail = false;
  bool isPhone = false;

  @override
  void initState() {
    super.initState();

    final config = Get.find<SplashController>().configModel!;
    final bool phoneVerificationEnabled =
        config.centralizeLoginSetup?.phoneVerificationStatus ?? false;
    final bool emailVerificationEnabled =
        config.centralizeLoginSetup?.emailVerificationStatus ?? false;
    final bool otpCapabilityEnabled =
        (config.isSmsActive == true || config.firebaseOtpVerification == true);

    // Show phone option only when admin enabled phone verification AND
    // there is an available OTP capability (SMS or Firebase)
    isPhone = phoneVerificationEnabled && otpCapabilityEnabled;
    // Show email option only when admin enabled email verification
    isEmail = emailVerificationEnabled;

    _formKeyLogin = GlobalKey<FormState>();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_numberFocusNode);
      });
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    _numberFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context)
          ? Colors.transparent
          : Theme.of(context).cardColor,
      appBar: ResponsiveHelper.isDesktop(context)
          ? null
          : CustomAppBarWidget(
              title: 'forgot_password'.tr,
              onBackPressed: () => ResponsiveHelper.isDesktop(context)
                  ? () => Get.back()
                  : Get.offAllNamed(RouteHelper.getSignInRoute('')),
            ),
      body: Center(
          child: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
        child: Center(
          child: Container(
            height: widget.fromDialog ? 600 : null,
            width: widget.fromDialog
                ? 475
                : context.width > 700
                    ? 700
                    : context.width,
            decoration: context.width > 700
                ? BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                    boxShadow: ResponsiveHelper.isDesktop(context)
                        ? null
                        : [
                            BoxShadow(
                                color: Colors.grey[Get.isDarkMode ? 700 : 300]!,
                                blurRadius: 5,
                                spreadRadius: 1)
                          ],
                  )
                : null,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ResponsiveHelper.isDesktop(context)
                    ? Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: const Icon(Icons.clear),
                        ),
                      )
                    : const SizedBox(),
                (isPhone)
                    ? Padding(
                        padding: widget.fromDialog
                            ? const EdgeInsets.all(
                                Dimensions.paddingSizeOverLarge)
                            : context.width > 700
                                ? const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault)
                                : const EdgeInsets.all(
                                    Dimensions.paddingSizeLarge),
                        child: Column(children: [
                          Image.asset(Images.logo,
                              height: widget.fromDialog ? 100 : 100,
                              width: 100),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge,
                                vertical: Dimensions.paddingSizeSmall),
                            child: Text('forgot_your_password'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeExtraLarge),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge),
                            child: Text(
                              'please_enter_the_registered_phone_where_you_want'
                                  .tr,
                              style: robotoRegular.copyWith(
                                  fontSize: widget.fromDialog
                                      ? Dimensions.fontSizeSmall
                                      : null,
                                  color: Theme.of(context).hintColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                              height: Dimensions.paddingSizeOverLarge),
                          Form(
                              key: _formKeyLogin,
                              child: CustomTextFieldWidget(
                                titleText: 'xxx-xxx-xxxxx'.tr,
                                controller: _numberController,
                                focusNode: _numberFocusNode,
                                inputType: TextInputType.phone,
                                inputAction: TextInputAction.done,
                                isPhone: true,
                                onCountryChanged: (CountryCode countryCode) {
                                  _countryDialCode = countryCode.dialCode;
                                },
                                countryDialCode: CountryCode.fromCountryCode(
                                            Get.find<SplashController>()
                                                .configModel!
                                                .country!)
                                        .code ??
                                    Get.find<LocalizationController>()
                                        .locale
                                        .countryCode,
                                onSubmit: (text) => GetPlatform.isWeb
                                    ? _onPressedForgetPass(_countryDialCode!)
                                    : null,
                                labelText: 'phone'.tr,
                                validator: (value) =>
                                    ValidateCheck.validateEmptyText(
                                        value, null),
                              )),
                          const SizedBox(
                              height: Dimensions.paddingSizeOverLarge),
                          GetBuilder<VerificationController>(
                              builder: (verificationController) {
                            return GetBuilder<AuthController>(
                                builder: (authController) {
                              return CustomButtonWidget(
                                radius: 100,
                                buttonText: 'request_otp'.tr,
                                isLoading: verificationController.isLoading ||
                                    authController.isLoading,
                                onPressed: () =>
                                    _onPressedForgetPass(_countryDialCode!),
                              );
                            });
                          }),
                          if (isEmail)
                            Column(
                              children: [
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: Theme.of(context).disabledColor,
                                        thickness: 1,
                                      ),
                                    ),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Text('Or'.tr,
                                        style: robotoRegular.copyWith(
                                            color: Theme.of(context)
                                                .disabledColor)),
                                    const SizedBox(
                                        width: Dimensions.paddingSizeSmall),
                                    Expanded(
                                      child: Divider(
                                        color: Theme.of(context).disabledColor,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                    height: Dimensions.paddingSizeSmall),
                              ],
                            ),
                          if (isEmail)
                            CustomButtonWidget(
                              radius: 100,
                              buttonText: 'Get OTP on Email'.tr,
                              color: Colors.grey[300],
                              textColor: Colors.grey,
                              isLoading: false,
                              onPressed: () =>
                                  ResponsiveHelper.isDesktop(context)
                                      ? () {
                                          Get.back();
                                          Get.dialog(const ForgetPassScreen(
                                              fromDialog: true));
                                        }()
                                      : Get.toNamed(
                                          RouteHelper.getForgotPassRoute()),
                            ),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          Text('or'.tr,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeLarge,
                                  color: Theme.of(context).hintColor),
                              textAlign: TextAlign.center),
                          const SizedBox(height: Dimensions.paddingSizeLarge),
                          RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: '${'back_to'.tr} ',
                                  style: robotoRegular.copyWith(
                                      fontSize: Dimensions.fontSizeDefault,
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color),
                                ),
                                TextSpan(
                                  text: 'login_in'.tr,
                                  style: robotoMedium.copyWith(
                                      color: Theme.of(context).primaryColor,
                                      fontSize: Dimensions.fontSizeDefault,
                                      decoration: TextDecoration.underline),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap =
                                        ResponsiveHelper.isDesktop(context)
                                            ? () => Get.back()
                                            : () => Get.back(),
                                ),
                              ]),
                              textAlign: TextAlign.center,
                              maxLines: 3),
                        ]),
                      )
                    : Padding(
                        padding: widget.fromDialog
                            ? const EdgeInsets.all(
                                Dimensions.paddingSizeOverLarge)
                            : context.width > 700
                                ? const EdgeInsets.all(
                                    Dimensions.paddingSizeDefault)
                                : const EdgeInsets.all(
                                    Dimensions.paddingSizeLarge),
                        child: Column(children: [
                          Image.asset(Images.forgot,
                              height: widget.fromDialog ? 160 : 220),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge,
                                vertical: Dimensions.paddingSizeSmall),
                            child: Text('sorry_something_went_wrong'.tr,
                                style: robotoBold.copyWith(
                                    fontSize: Dimensions.fontSizeExtraLarge),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeLarge),
                            child: Text(
                              'please_try_again_after_some_time_or_contact_with_our_support_team'
                                  .tr,
                              style: robotoRegular.copyWith(
                                  fontSize: widget.fromDialog
                                      ? Dimensions.fontSizeSmall
                                      : null,
                                  color: Theme.of(context).hintColor),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(
                              height: Dimensions.paddingSizeOverLarge),
                          CustomButtonWidget(
                              buttonText: 'help_and_support'.tr,
                              onPressed: () {
                                Get.toNamed(RouteHelper.getSupportRoute());
                              }),
                        ]),
                      ),
              ]),
            ),
          ),
        ),
      )),
    );
  }

  void _onPressedForgetPass(String countryCode) async {
    String phone = _numberController.text.trim();
    // Remove leading 0 for Bangladesh (+880) country code
    if (countryCode == "+880" && phone.isNotEmpty && phone.startsWith("0")) {
      phone = phone.substring(1);
    }
    // String email = _emailController.text.trim();

    String numberWithCountryCode = countryCode + phone;
    PhoneValid phoneValid =
        await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (_formKeyLogin!.currentState!.validate()) {
      if (!phoneValid.isValid && !isEmail) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else {
        Get.find<VerificationController>()
            .forgetPassword(phone: numberWithCountryCode)
            .then((status) async {
          if (status.isSuccess) {
            if (Get.find<SplashController>()
                .configModel!
                .firebaseOtpVerification!) {
              Get.find<AuthController>().firebaseVerifyPhoneNumber(
                  numberWithCountryCode, status.message, '',
                  fromSignUp: false);
            } else {
              if (ResponsiveHelper.isDesktop(Get.context)) {
                Get.back();
                Get.dialog(VerificationScreen(
                  number: numberWithCountryCode,
                  email: '',
                  token: '',
                  fromSignUp: false,
                  fromForgetPassword: true,
                  loginType: '',
                  password: '',
                ));
              } else {
                Get.toNamed(RouteHelper.getVerificationRoute(
                    numberWithCountryCode,
                    '',
                    '',
                    RouteHelper.forgotPassword,
                    '',
                    ''));
              }
            }
          } else {
            showCustomSnackBar(status.message);
          }
        });
      }
    }
  }
}
