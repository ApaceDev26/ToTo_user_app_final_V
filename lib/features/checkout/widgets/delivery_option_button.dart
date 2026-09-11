import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:toto_user/common/widgets/custom_tool_tip.dart';
import 'package:toto_user/features/checkout/controllers/checkout_controller.dart';
import 'package:toto_user/features/profile/controllers/profile_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/auth_helper.dart';
import 'package:toto_user/helper/custom_validator.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DeliveryOptionButton extends StatelessWidget {
  final String value;
  final String title;
  final double? charge;
  final bool? isFree;
  final double total;
  final String? chargeForView;
  final JustTheController? deliveryFeeTooltipController;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  final TextEditingController? guestNameTextEditingController;
  final TextEditingController? guestNumberTextEditingController;
  final TextEditingController? guestEmailController;

  /// For delivery variants: standard | front_door | reception
  final String? deliveryPreference;
  const DeliveryOptionButton(
      {super.key,
      required this.value,
      required this.title,
      required this.charge,
      required this.isFree,
      required this.total,
      this.chargeForView,
      this.deliveryFeeTooltipController,
      required this.badWeatherCharge,
      required this.extraChargeForToolTip,
      this.guestNameTextEditingController,
      this.guestNumberTextEditingController,
      this.guestEmailController,
      this.deliveryPreference});

  bool _isSelected(CheckoutController c) {
    if (value == 'delivery') {
      return c.orderType == 'delivery' &&
          c.deliveryPreference == (deliveryPreference ?? 'standard');
    }
    return c.orderType == value;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CheckoutController>(
      builder: (checkoutController) {
        bool select = _isSelected(checkoutController);
        final bool isDeliveryVariant = value == 'delivery';
        final double preferenceFee =
            (deliveryPreference != null && deliveryPreference != 'standard')
                ? CheckoutController.deliveryPreferenceSurcharge
                : 0;
        return InkWell(
          onTap: () async {
            checkoutController.setOrderType(
                value == 'delivery' ? 'delivery' : value,
                notify: false);
            if (value == 'delivery') {
              checkoutController
                  .setDeliveryPreference(deliveryPreference ?? 'standard');
            } else {
              checkoutController.setDeliveryPreference('standard');
            }

            if (checkoutController.orderType == 'take_away') {
              checkoutController.addTips(0);
              if (checkoutController.isPartialPay ||
                  checkoutController.paymentMethodIndex == 1) {
                double tips = 0;
                try {
                  tips = double.parse(checkoutController.tipController.text);
                } catch (_) {}
                checkoutController.checkBalanceStatus(total,
                    discount: charge! + tips);
              }
            } else if (checkoutController.orderType == 'dine_in') {
              checkoutController.addTips(0);
              if (checkoutController.isPartialPay ||
                  checkoutController.paymentMethodIndex == 1) {
                double tips = 0;
                try {
                  tips = double.parse(checkoutController.tipController.text);
                } catch (_) {}
                checkoutController.checkBalanceStatus(total,
                    discount: charge! + tips);
              }

              if (AuthHelper.isLoggedIn()) {
                String phone = await _splitPhoneNumber(
                    Get.find<ProfileController>()
                            .userInfoModel
                            ?.userInfo
                            ?.phone ??
                        '');

                guestNameTextEditingController?.text =
                    '${Get.find<ProfileController>().userInfoModel?.userInfo?.fName ?? ''} ${Get.find<ProfileController>().userInfoModel?.userInfo?.fName ?? ''}';
                guestNumberTextEditingController?.text = phone;
                guestEmailController?.text = Get.find<ProfileController>()
                        .userInfoModel
                        ?.userInfo
                        ?.email ??
                    '';
              }
            } else {
              checkoutController.updateTips(
                checkoutController.getDmTipIndex().isNotEmpty
                    ? int.parse(checkoutController.getDmTipIndex())
                    : 0,
                notify: false,
              );

              if (checkoutController.isPartialPay) {
                checkoutController.changePartialPayment();
              } else {
                checkoutController.setPaymentMethod(-1);
              }
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: select ? Theme.of(context).cardColor : Colors.transparent,
              borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
              border: Border.all(
                  color: select
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).disabledColor,
                  width: 0.5),
            ),
            padding: const EdgeInsets.symmetric(
                horizontal: Dimensions.paddingSizeSmall,
                vertical: Dimensions.paddingSizeSmall),
            child: Row(
              children: [
                Radio<String>(
                  value: isDeliveryVariant
                      ? 'delivery_${deliveryPreference ?? 'standard'}'
                      : value,
                  groupValue: checkoutController.orderType == 'delivery'
                      ? 'delivery_${checkoutController.deliveryPreference}'
                      : checkoutController.orderType,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onChanged: (_) {
                    checkoutController.setOrderType(
                        value == 'delivery' ? 'delivery' : value,
                        notify: false);
                    if (value == 'delivery') {
                      checkoutController.setDeliveryPreference(
                          deliveryPreference ?? 'standard');
                    } else {
                      checkoutController.setDeliveryPreference('standard');
                    }
                  },
                  activeColor: Theme.of(context).primaryColor,
                  visualDensity:
                      const VisualDensity(horizontal: -3, vertical: -3),
                ),
                const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title,
                      style: robotoMedium.copyWith(
                          color:
                              Theme.of(context).textTheme.bodyMedium!.color)),
                  Row(children: [
                    Text(
                      isDeliveryVariant
                          ? (isFree == true
                              ? 'free'.tr
                              : (preferenceFee > 0
                                  ? '${'charge'.tr}: ${'normal'.tr} + ${preferenceFee.toInt()}${Get.find<SplashController>().configModel!.currencySymbol ?? ''}'
                                  : '${'charge'.tr}: +${chargeForView ?? ''}'))
                          : 'free'.tr,
                      style: robotoRegular.copyWith(
                          fontSize: Dimensions.fontSizeSmall,
                          color: Theme.of(context).textTheme.bodyMedium!.color),
                    ),
                    const SizedBox(width: Dimensions.paddingSizeExtraSmall),
                    isDeliveryVariant &&
                            checkoutController.extraCharge != null &&
                            (chargeForView! != '0') &&
                            extraChargeForToolTip > 0
                        ? CustomToolTip(
                            message:
                                '${'this_charge_include_extra_vehicle_charge'.tr} ${PriceConverter.convertPrice(extraChargeForToolTip)} ${badWeatherCharge > 0 ? '${'and_bad_weather_charge'.tr} ${PriceConverter.convertPrice(badWeatherCharge)}' : ''}',
                            tooltipController: deliveryFeeTooltipController,
                            preferredDirection: AxisDirection.right,
                            child: const Icon(Icons.info,
                                color: Colors.blue, size: 14),
                          )
                        : const SizedBox(),
                  ]),
                ]),
                const SizedBox(width: Dimensions.paddingSizeSmall),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _splitPhoneNumber(String number) async {
    PhoneValid phoneNumber = await CustomValidator.isPhoneValid(number);
    Get.find<CheckoutController>().countryDialCode =
        '+${phoneNumber.countryCode}';
    return phoneNumber.phone.replaceFirst('+${phoneNumber.countryCode}', '');
  }
}
