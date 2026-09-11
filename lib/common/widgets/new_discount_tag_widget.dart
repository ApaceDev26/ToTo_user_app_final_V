import 'package:iconsax/iconsax.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewDiscountTagWidget extends StatelessWidget {
  final double? discount;
  final String? discountType;
  final double fromTop;
  final double fromLeft;
  final double? fontSize;
  final bool? freeDelivery;
  final bool isProductBottomSheet;
  final double paddingHorizontal;
  final double paddingVertical;
  const NewDiscountTagWidget(
      {super.key,
      required this.discount,
      required this.discountType,
      this.fromTop = 10,
      this.fontSize,
      this.freeDelivery = false,
      this.isProductBottomSheet = false,
      this.fromLeft = 0,
      this.paddingHorizontal = 10,
      this.paddingVertical = 10});

  @override
  Widget build(BuildContext context) {
    bool isRightSide =
        Get.find<SplashController>().configModel!.currencySymbolDirection ==
            'right';
    String currencySymbol =
        Get.find<SplashController>().configModel!.currencySymbol!;

    return !isProductBottomSheet
        ? (discount! > 0 || freeDelivery!)
            ? Positioned(
                top: fromTop,
                left: fromLeft,
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(235, 255, 255, 255),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  padding: EdgeInsets.symmetric(
                      horizontal: paddingHorizontal,
                      vertical: Dimensions.paddingSizeExtraSmall),
                  child: Row(
                    children: [
                      Icon(Iconsax.discount_shape, size: 14),
                      const SizedBox(width: 2),
                      Align(
                        child: Text(
                          discount! > 0
                              ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}'
                                  '${discount.toString().replaceAll(RegExp(r'\.0$'), '')}'
                                  '${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
                              : 'free_delivery'.tr,
                          style: robotoMedium.copyWith(
                            color: Colors.black,
                            fontSize: fontSize ??
                                (ResponsiveHelper.isMobile(context) ? 8 : 10),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : const SizedBox()
        : (discount! > 0 || freeDelivery!)
            ? Positioned(
                bottom: 0,
                right: 0,
                left: 0,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(Dimensions.radiusSmall),
                      bottomRight: Radius.circular(Dimensions.radiusSmall),
                    ),
                    gradient: LinearGradient(colors: [
                      Theme.of(Get.context!).primaryColor,
                      Theme.of(Get.context!)
                          .primaryColor
                          .withValues(alpha: 0.0),
                    ], begin: Alignment.centerLeft, end: Alignment.centerRight),
                  ),
                  child: Text(
                    discount! > 0
                        ? '${(isRightSide || discountType == 'percent') ? '' : currencySymbol}$discount${discountType == 'percent' ? '%' : isRightSide ? currencySymbol : ''} ${'off'.tr}'
                        : 'free_delivery'.tr,
                    style: robotoMedium.copyWith(
                      color: Colors.white,
                      fontSize: fontSize ??
                          (ResponsiveHelper.isMobile(context) ? 14 : 16),
                    ),
                    textAlign: TextAlign.start,
                  ),
                ),
              )
            : const SizedBox();
  }
}
