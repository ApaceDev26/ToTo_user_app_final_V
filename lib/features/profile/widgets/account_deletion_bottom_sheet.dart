import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/profile/controllers/profile_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/util/styles.dart';

class AccountDeletionBottomSheet extends StatefulWidget {
  final ProfileController profileController;
  final bool isRunningOrderAvailable;
  const AccountDeletionBottomSheet({super.key, required this.profileController, this.isRunningOrderAvailable = false});

  @override
  State<AccountDeletionBottomSheet> createState() => _AccountDeletionBottomSheetState();
}

class _AccountDeletionBottomSheetState extends State<AccountDeletionBottomSheet> {
  bool _otpRequired = false;
  String _otpCode = '';
  Timer? _timer;
  int _seconds = 0;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _seconds = _seconds - 1;
      if (_seconds == 0) {
        timer.cancel();
        _timer?.cancel();
      }
      if (mounted) {
        setState(() {});
      }
    });
  }

  Future<void> _sendOtp() async {
    bool success = await widget.profileController.sendOtpForAccountDeletion();
    if (success) {
      setState(() {
        _otpRequired = true;
      });
      _startTimer();
      showCustomSnackBar('otp_successfully_send'.tr, isError: false);
    }
  }

  Future<void> _verifyAndDelete() async {
    if (_otpCode.length < 6) {
      showCustomSnackBar('please_enter_verification_code'.tr);
      return;
    }
    bool success = await widget.profileController.verifyOtpAndDeleteAccount(_otpCode);
    if (success) {
      Get.back();
    }
  }

  Future<void> _resendOtp() async {
    bool success = await widget.profileController.sendOtpForAccountDeletion();
    if (success) {
      _startTimer();
      showCustomSnackBar('resend_code_successful'.tr, isError: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    String? phoneNumber = widget.profileController.userInfoModel?.phone;

    return Container(
      width: ResponsiveHelper.isDesktop(context) ? 500 : context.width,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
      ),
      padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20), topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        child: Column(mainAxisSize: MainAxisSize.min, children: [

          ResponsiveHelper.isDesktop(context) ? const SizedBox() : Container(
            height: 5, width: 35,
            decoration: BoxDecoration(
              color: Theme.of(context).disabledColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0 : Dimensions.paddingSizeLarge),

          Stack(clipBehavior: Clip.none, children: [
            ClipOval(child: CustomImageWidget(
              placeholder: Images.guestIconLight,
              imageColor: Theme.of(context).colorScheme.error.withValues(alpha: 0.3),
              image: '${(widget.profileController.userInfoModel != null && isLoggedIn) ? widget.profileController.userInfoModel!.imageFullUrl : ''}',
              height: 70, width: 70, fit: BoxFit.cover,
            )),

            Positioned(
              right: -5, top: 0,
              child: Icon(widget.isRunningOrderAvailable ? Icons.warning_rounded : CupertinoIcons.clear_circled_solid, color: Theme.of(context).colorScheme.error, size: 25),
            ),

          ]),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          Text(
            widget.isRunningOrderAvailable 
                ? 'sorry_you_cannot_delete_your_account'.tr 
                : _otpRequired 
                    ? 'verify_otp'.tr 
                    : 'delete_your_account'.tr, 
            style: robotoBold.copyWith(fontSize: Dimensions.fontSizeLarge), 
            textAlign: TextAlign.center
          ),
          const SizedBox(height: Dimensions.paddingSizeExtraSmall),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Text(
              widget.isRunningOrderAvailable 
                  ? 'please_complete_your_ongoing_and_accepted_orders'.tr 
                  : _otpRequired 
                      ? 'we_have_a_verification_code'.tr + (phoneNumber != null && phoneNumber.length > 4 ? ' ${phoneNumber.replaceRange(phoneNumber.length - 4, phoneNumber.length, '****')}' : (phoneNumber != null ? ' $phoneNumber' : ''))
                      : 'you_will_not_be_able_to_recover_your_data_again'.tr,
              style: robotoRegular, 
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: Dimensions.paddingSizeLarge),

          // OTP Input Field
          if (_otpRequired && !widget.isRunningOrderAvailable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: PinCodeTextField(
                length: 6,
                appContext: context,
                keyboardType: TextInputType.number,
                animationType: AnimationType.slide,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  fieldHeight: 50,
                  fieldWidth: 40,
                  borderWidth: 0.7,
                  borderRadius: BorderRadius.circular(Dimensions.radiusDefault),
                  selectedColor: Theme.of(context).primaryColor,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Theme.of(context).cardColor,
                  inactiveColor: Theme.of(context).disabledColor.withValues(alpha: 0.6),
                  activeColor: Theme.of(context).disabledColor,
                  activeFillColor: Theme.of(context).cardColor,
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
                onChanged: (value) {
                  setState(() {
                    _otpCode = value;
                  });
                },
                beforeTextPaste: (text) => true,
              ),
            ),

          if (_otpRequired && !widget.isRunningOrderAvailable)
            const SizedBox(height: Dimensions.paddingSizeDefault),

          // Resend OTP
          if (_otpRequired && !widget.isRunningOrderAvailable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'did_not_receive_the_code'.tr,
                    style: robotoRegular.copyWith(
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                  const SizedBox(width: Dimensions.paddingSizeSmall),
                  TextButton(
                    onPressed: _seconds < 1 ? _resendOtp : null,
                    child: Text(
                      '${'resent_it'.tr}${_seconds > 0 ? ' (${_seconds}s)' : ''}',
                      style: TextStyle(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ],
              ),
            ),

          if (_otpRequired && !widget.isRunningOrderAvailable)
            const SizedBox(height: Dimensions.paddingSizeLarge),

          Padding(
            padding: EdgeInsets.only(left: widget.isRunningOrderAvailable ? 70 : 50, right: widget.isRunningOrderAvailable ? 70 : 50, bottom: 20),
            child: widget.isRunningOrderAvailable ? CustomButtonWidget(
              buttonText: 'view_orders'.tr,
              height: 40,
              color: Theme.of(context).primaryColor,
              fontSize: Dimensions.fontSizeDefault,
              onPressed: () {
                Get.back();
                Get.toNamed(RouteHelper.getOrderRoute());
              },
            ) : GetBuilder<ProfileController>(
                builder: (pController) {
                return pController.isLoading 
                    ? const Center(child: CircularProgressIndicator()) 
                    : _otpRequired
                        ? Column(
                            children: [
                              Row(children: [
                                Expanded(child: CustomButtonWidget(
                                  buttonText: 'cancel'.tr,
                                  height: 40,
                                  color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                                  fontSize: Dimensions.fontSizeDefault,
                                  textColor: Theme.of(context).textTheme.bodyLarge!.color,
                                  onPressed: () => Get.back(),
                                )),
                                const SizedBox(width: Dimensions.paddingSizeDefault),
                                Expanded(child: CustomButtonWidget(
                                  buttonText: 'verify'.tr,
                                  height: 40,
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: Dimensions.fontSizeDefault,
                                  isLoading: pController.isLoading,
                                  onPressed: _otpCode.length == 6 ? _verifyAndDelete : null,
                                )),
                              ]),
                            ],
                          )
                        : Row(children: [
                            Expanded(child: CustomButtonWidget(
                              buttonText: 'cancel'.tr,
                              height: 40,
                              color: Theme.of(context).disabledColor.withValues(alpha: 0.5),
                              fontSize: Dimensions.fontSizeDefault,
                              textColor: Theme.of(context).textTheme.bodyLarge!.color,
                              onPressed: () => Get.back(),
                            )),
                            const SizedBox(width: Dimensions.paddingSizeDefault),
                            Expanded(child: CustomButtonWidget(
                              buttonText: 'remove'.tr,
                              height: 40,
                              color: Theme.of(context).colorScheme.error,
                              fontSize: Dimensions.fontSizeDefault,
                              isLoading: pController.isLoading,
                              onPressed: _sendOtp,
                            )),
                          ]);
              }
            ),
          ),

        ]),
      ),

    );
  }
}
