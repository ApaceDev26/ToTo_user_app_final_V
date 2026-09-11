import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:toto_user/common/widgets/validate_check.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_icons.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/design_system/components/app_button.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/verification/controllers/verification_controller.dart';
import 'package:toto_user/features/verification/screens/verification_screen.dart';
import 'package:toto_user/features/verification/screens/forget_pass_screen_phone.dart';
import 'package:toto_user/helper/custom_validator.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ForgetPassScreen extends StatefulWidget {
  final bool fromDialog;
  const ForgetPassScreen({super.key, this.fromDialog = false});

  @override
  State<ForgetPassScreen> createState() => _ForgetPassScreenState();
}

class _ForgetPassScreenState extends State<ForgetPassScreen> {
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
    final bool otpCapabilityEnabled =
        (config.isSmsActive == true || config.firebaseOtpVerification == true);

    // Show phone option only when admin enabled phone verification AND
    // there is an available OTP capability (SMS or Firebase)
    isPhone = phoneVerificationEnabled && otpCapabilityEnabled;
    isEmail = Get.find<SplashController>().configModel!.isMailActive!;

    _formKeyLogin = GlobalKey<FormState>();
    if (!kIsWeb) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_numberFocusNode);
        FocusScope.of(context).requestFocus(_emailFocusNode);
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
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final colors = AppColors.of(context);
    return Scaffold(
      backgroundColor: ResponsiveHelper.isDesktop(context)
          ? Colors.transparent
          : colors.canvas,
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
        padding: const EdgeInsets.all(AppSpacing.sm),
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
                    color: colors.surface,
                    borderRadius: AppRadius.mdAll,
                  )
                : null,
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                ResponsiveHelper.isDesktop(context)
                    ? Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.close_rounded,
                              color: colors.ink, size: AppIcons.md),
                        ),
                      )
                    : const SizedBox(),
                (isEmail)
                    ? Padding(
                        padding: widget.fromDialog
                            ? const EdgeInsets.all(AppSpacing.x3l)
                            : context.width > 700
                                ? const EdgeInsets.all(AppSpacing.lg)
                                : EdgeInsets.all(AppSpacing.page(context)),
                        child: Column(children: [
                          Image.asset(Images.logo,
                              height: widget.fromDialog ? 100 : 100,
                              width: 100),
                          const SizedBox(height: AppSpacing.xl),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.sm),
                            child: Text('forgot_your_password'.tr,
                                style: AppTypography.titleLg(colors.ink),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl),
                            child: Text(
                              'please_enter_the_registered_email_where_you_want'
                                  .tr,
                              style: AppTypography.bodyMd(colors.inkMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x3l),
                          Form(
                            key: _formKeyLogin,
                            child: CustomTextFieldWidget(
                              titleText: 'enter_email'.tr,
                              labelText: 'email'.tr,
                              showLabelText: true,
                              required: true,
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              inputType: TextInputType.emailAddress,
                              inputAction: TextInputAction.done,
                              prefixIcon: CupertinoIcons.mail_solid,
                              validator: (value) =>
                                  ValidateCheck.validateEmail(value),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x3l),
                          GetBuilder<VerificationController>(
                              builder: (verificationController) {
                            return GetBuilder<AuthController>(
                                builder: (authController) {
                              return AppButton(
                                label: 'request_otp'.tr,
                                isLoading: verificationController.isLoading ||
                                    authController.isLoading,
                                onPressed: () =>
                                    _onPressedForgetPass(_countryDialCode!),
                              );
                            });
                          }),
                          if (isPhone)
                            Column(
                              children: [
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Divider(
                                        color: colors.line,
                                        thickness: 1,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Text('Or'.tr,
                                        style: AppTypography.bodyMd(
                                            colors.inkFaint)),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: Divider(
                                        color: colors.line,
                                        thickness: 1,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                              ],
                            ),
                          (isPhone)
                              ? AppButton(
                                  label: 'Get OTP on Phone'.tr,
                                  variant: AppButtonVariant.soft,
                                  isLoading: false,
                                  onPressed: () =>
                                      ResponsiveHelper.isDesktop(context)
                                          ? () {
                                              Get.back();
                                              Get.dialog(
                                                  const ForgetPassScreenPhone(
                                                      fromDialog: true));
                                            }()
                                          : Get.toNamed(RouteHelper
                                              .getForgotPassRoutePhone()),
                                )
                              : const SizedBox(),
                          const SizedBox(height: AppSpacing.xl),
                          Text('or'.tr,
                              style: AppTypography.titleSm(colors.inkMuted),
                              textAlign: TextAlign.center),
                          const SizedBox(height: AppSpacing.xl),
                          RichText(
                              text: TextSpan(children: [
                                TextSpan(
                                  text: '${'back_to'.tr} ',
                                  style: AppTypography.bodyMd(colors.ink),
                                ),
                                TextSpan(
                                  text: 'login_in'.tr,
                                  style: AppTypography.labelLg(colors.accent)
                                      .copyWith(
                                          decoration: TextDecoration.underline,
                                          decorationColor: colors.accent),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = isDesktop
                                        ? () => Get.back()
                                        : () => Get.offAllNamed(
                                            RouteHelper.getSignInRoute('')),
                                ),
                              ]),
                              textAlign: TextAlign.center,
                              maxLines: 3),
                        ]),
                      )
                    : Padding(
                        padding: widget.fromDialog
                            ? const EdgeInsets.all(AppSpacing.x3l)
                            : context.width > 700
                                ? const EdgeInsets.all(AppSpacing.lg)
                                : EdgeInsets.all(AppSpacing.page(context)),
                        child: Column(children: [
                          Image.asset(Images.forgot,
                              height: widget.fromDialog ? 160 : 220),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl,
                                vertical: AppSpacing.sm),
                            child: Text('sorry_something_went_wrong'.tr,
                                style: AppTypography.titleLg(colors.ink),
                                textAlign: TextAlign.center),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.xl),
                            child: Text(
                              'please_try_again_after_some_time_or_contact_with_our_support_team'
                                  .tr,
                              style: AppTypography.bodyMd(colors.inkMuted),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.x3l),
                          AppButton(
                              label: 'help_and_support'.tr,
                              onPressed: () {
                                Get.toNamed(RouteHelper.getSupportRoute());
                              }),
                        ]),
                      )
              ]),
            ),
          ),
        ),
      )),
    );
  }

  void _onPressedForgetPass(String countryCode) async {
    String phone = '123456789';
    String email = _emailController.text.trim();

    String numberWithCountryCode = countryCode + phone;
    PhoneValid phoneValid =
        await CustomValidator.isPhoneValid(numberWithCountryCode);
    numberWithCountryCode = phoneValid.phone;

    if (_formKeyLogin!.currentState!.validate()) {
      if (!phoneValid.isValid && !isEmail) {
        showCustomSnackBar('invalid_phone_number'.tr);
      } else {
        Get.find<VerificationController>()
            .forgetPassword(email: email, phone: numberWithCountryCode)
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
                  email: email,
                  token: '',
                  fromSignUp: false,
                  fromForgetPassword: true,
                  loginType: '',
                  password: '',
                ));
              } else {
                Get.toNamed(RouteHelper.getVerificationRoute(
                    numberWithCountryCode,
                    email,
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