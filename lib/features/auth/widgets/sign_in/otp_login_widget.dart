import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/common/widgets/custom_text_field_widget.dart';
import 'package:toto_user/common/widgets/validate_check.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/auth/widgets/social_login_widget.dart';
import 'package:toto_user/features/auth/widgets/trams_conditions_check_box_widget.dart';
import 'package:toto_user/features/language/controllers/localization_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/styles.dart';

class OtpLoginWidget extends StatelessWidget {
  final TextEditingController phoneController;
  final FocusNode phoneFocus;
  final String? countryDialCode;
  final Function(CountryCode countryCode)? onCountryChanged;
  final Function() onClickLoginButton;
  final bool socialEnable;
  final Function()? onEmailViewClick;
  const OtpLoginWidget(
      {super.key,
      required this.phoneController,
      required this.phoneFocus,
      required this.onCountryChanged,
      required this.countryDialCode,
      required this.onClickLoginButton,
      this.socialEnable = false,
      this.onEmailViewClick});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final config = Get.find<SplashController>().configModel!;

    final bool manualLoginStatus =
        config.centralizeLoginSetup?.manualLoginStatus ?? false;
    return GetBuilder<AuthController>(builder: (authController) {
      return Padding(
        padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? Dimensions.paddingSizeLarge : 0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 90),
          CustomTextFieldWidget(
            hintText: 'xxx-xxx-xxxxx'.tr,
            controller: phoneController,
            focusNode: phoneFocus,
            inputAction: TextInputAction.done,
            inputType: TextInputType.phone,
            isPhone: true,
            onCountryChanged: onCountryChanged,
            countryDialCode: CountryCode.fromCountryCode(
                        Get.find<SplashController>().configModel!.country!)
                    .code ??
                Get.find<LocalizationController>().locale.countryCode,
            labelText: 'phone'.tr,
            required: true,
            validator: (value) => ValidateCheck.validateEmptyText(
                value, "please_enter_phone_number".tr),
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraLarge),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              onTap: () => authController.toggleRememberMeForOtp(),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child:                     Checkbox(
                      side: BorderSide(color: Theme.of(context).hintColor),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      activeColor: Theme.of(context).primaryColor,
                      checkColor: Colors.white,
                      value: authController.isActiveRememberMeForOtp,
                      onChanged: (bool? isChecked) =>
                          authController.toggleRememberMeForOtp(),
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  Text('remember_me'.tr, style: robotoRegular),
                ],
              ),
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          TramsConditionsCheckBoxWidget(
              authController: authController, fromDialog: true),
          const SizedBox(height: Dimensions.paddingSizeLarge),
          CustomButtonWidget(
            buttonText: 'Continue'.tr,
            radius: 100,
            isBold: isDesktop ? false : true,
            isLoading: authController.isLoading,
            onPressed: onClickLoginButton,
            fontSize: isDesktop
                ? Dimensions.fontSizeSmall
                : Dimensions.fontSizeDefault,
          ),
          socialEnable
              ? const SocialLoginWidget(onlySocialLogin: false)
              : const SizedBox(),
          socialEnable && isDesktop
              ? const SizedBox(height: Dimensions.paddingSizeLarge)
              : const SizedBox(),
          onEmailViewClick != null
              ? const SizedBox()
              // Column(children: [
              //     const SizedBox(height: Dimensions.paddingSizeSmall),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Expanded(
              //           child: Divider(
              //             color: Theme.of(context).disabledColor,
              //             thickness: 1,
              //           ),
              //         ),
              //         const SizedBox(width: Dimensions.paddingSizeSmall),
              //         Text('Or'.tr,
              //             style: robotoRegular.copyWith(
              //                 color: Theme.of(context).disabledColor)),
              //         const SizedBox(width: Dimensions.paddingSizeSmall),
              //         Expanded(
              //           child: Divider(
              //             color: Theme.of(context).disabledColor,
              //             thickness: 1,
              //           ),
              //         ),
              //       ],
              //     ),
              //     const SizedBox(height: Dimensions.paddingSizeSmall),
              //     if (!isDesktop && manualLoginStatus)
              //       CustomButtonWidget(
              //         buttonText: 'Login with email'.tr,
              //         radius: 100,
              //         isBold: isDesktop ? false : false,
              //         isLoading: authController.isLoading,
              //         color: Colors.grey.withOpacity(0.2),
              //         textColor: Colors.black.withOpacity(0.8),
              //         onPressed: onEmailViewClick,
              //         fontSize: isDesktop
              //             ? Dimensions.fontSizeSmall
              //             : Dimensions.fontSizeDefault,
              //       ),
              //     if (!isDesktop && manualLoginStatus)
              //       const SizedBox(height: Dimensions.paddingSizeLarge),
              //     Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Text('do_not_have_account'.tr,
              //             style: robotoRegular.copyWith(
              //                 color: Theme.of(context).hintColor)),
              //         InkWell(
              //           onTap: authController.isLoading
              //               ? null
              //               : () {
              //                   Get.toNamed(RouteHelper.getSignUpRoute());
              //                 },
              //           child: Padding(
              //             padding: const EdgeInsets.all(
              //                 Dimensions.paddingSizeExtraSmall),
              //             child: Text('sign_up'.tr,
              //                 style: robotoMedium.copyWith(
              //                     color: Theme.of(context).primaryColor)),
              //           ),
              //         ),
              //       ],
              //     ),
              //   ])
              : const SizedBox(),
          !socialEnable && onEmailViewClick == null
              ? const SizedBox(height: 100)
              : const SizedBox(),
        ]),
      );
    });
  }
}
