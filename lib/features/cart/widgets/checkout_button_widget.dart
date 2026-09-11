import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/design_system/components/app_button.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/checkout/controllers/checkout_controller.dart';
import 'package:toto_user/features/coupon/controllers/coupon_controller.dart';
import 'package:toto_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CheckoutButtonWidget extends StatelessWidget {
  final CartController cartController;
  final List<bool> availableList;
  final bool isRestaurantOpen;
  final bool fromDineIn;
  const CheckoutButtonWidget(
      {super.key,
      required this.cartController,
      required this.availableList,
      required this.isRestaurantOpen,
      this.fromDineIn = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    double percentage = 0;
    bool isDesktop = ResponsiveHelper.isDesktop(context);

    return Container(
      width: Dimensions.webMaxWidth,
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.lg),
      decoration: isDesktop
          ? null
          : BoxDecoration(
              color: colors.surface,
              border: Border(top: BorderSide(color: colors.line, width: 1)),
            ),
      child: SafeArea(
        child:
            GetBuilder<RestaurantController>(builder: (restaurantController) {
          if (restaurantController.restaurant != null &&
              restaurantController.restaurant!.freeDelivery != null &&
              !restaurantController.restaurant!.freeDelivery! &&
              (Get.find<SplashController>()
                          .configModel
                          ?.adminFreeDelivery
                          ?.status ==
                      true &&
                  (Get.find<SplashController>()
                              .configModel
                              ?.adminFreeDelivery
                              ?.type !=
                          null &&
                      Get.find<SplashController>()
                              .configModel
                              ?.adminFreeDelivery
                              ?.type ==
                          'free_delivery_by_specific_criteria') &&
                  (Get.find<SplashController>()
                          .configModel!
                          .adminFreeDelivery
                          ?.freeDeliveryOver !=
                      null))) {
            percentage = cartController.subTotal /
                Get.find<SplashController>()
                    .configModel!
                    .adminFreeDelivery!
                    .freeDeliveryOver!;
          }
          return Column(mainAxisSize: MainAxisSize.min, children: [
            (restaurantController.restaurant != null &&
                    restaurantController.restaurant!.freeDelivery != null &&
                    !restaurantController.restaurant!.freeDelivery! &&
                    (Get.find<SplashController>()
                                .configModel
                                ?.adminFreeDelivery
                                ?.status ==
                            true &&
                        (Get.find<SplashController>()
                                    .configModel
                                    ?.adminFreeDelivery
                                    ?.type !=
                                null &&
                            Get.find<SplashController>()
                                    .configModel
                                    ?.adminFreeDelivery
                                    ?.type ==
                                'free_delivery_by_specific_criteria') &&
                        (Get.find<SplashController>()
                                .configModel!
                                .adminFreeDelivery
                                ?.freeDeliveryOver !=
                            null)) &&
                    percentage < 1)
                ? Padding(
                    padding:
                        EdgeInsets.only(bottom: isDesktop ? AppSpacing.xl : 0),
                    child: Column(children: [
                      Row(children: [
                        Image.asset(Images.percentTag, height: 20, width: 20),
                        const SizedBox(width: AppSpacing.xs),
                        PriceConverter.convertAnimationPrice(
                          Get.find<SplashController>()
                                  .configModel!
                                  .adminFreeDelivery!
                                  .freeDeliveryOver! -
                              cartController.subTotal,
                          textStyle: AppTypography.labelMd(colors.accent),
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text('more_for_free_delivery'.tr,
                            style: AppTypography.bodySm(colors.inkMuted)),
                      ]),
                      const SizedBox(height: AppSpacing.xs),
                      ClipRRect(
                        borderRadius: AppRadius.pillAll,
                        child: LinearProgressIndicator(
                          backgroundColor: colors.accentSoft,
                          color: colors.accent,
                          minHeight: 4,
                          value: percentage,
                        ),
                      ),
                    ]),
                  )
                : const SizedBox(),
            !isDesktop
                ? Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('subtotal'.tr,
                            style: AppTypography.labelLg(colors.accent)),
                        PriceConverter.convertAnimationPrice(
                            cartController.subTotal,
                            textStyle: AppTypography.price(colors.accent)),
                      ],
                    ),
                  )
                : const SizedBox(),
            GetBuilder<CartController>(builder: (cartController) {
              final busy = cartController.isLoading ||
                  restaurantController.restaurant == null;
              return AppButton(
                label: 'confirm_delivery_details'.tr,
                isLoading: cartController.isLoading,
                // Use primary for filled background, which uses white text.
                variant: AppButtonVariant.primary,
                onPressed: busy
                    ? null
                    : () {
                        Get.find<CheckoutController>().updateFirstTime();
                        _processToCheckoutButtonPressed(restaurantController);
                      },
              );
            }),
            SizedBox(height: isDesktop ? AppSpacing.x3l : 0),
          ]);
        }),
      ),
    );
  }

  void _processToCheckoutButtonPressed(
      RestaurantController restaurantController) {
    if (!cartController.cartList.first.product!.scheduleOrder! &&
        cartController.availableList.contains(false)) {
      showCustomSnackBar('one_or_more_product_unavailable'.tr);
    } else if (restaurantController.restaurant!.freeDelivery == null ||
        restaurantController.restaurant!.cutlery == null) {
      showCustomSnackBar('restaurant_is_unavailable'.tr);
    } /* else if(!isRestaurantOpen) {
      showCustomSnackBar('restaurant_is_close_now'.tr);
    } */
    else {
      Get.find<CouponController>().removeCouponData(false);
      Get.toNamed(RouteHelper.getCheckoutRoute('cart', fromDineIn: fromDineIn));
    }
  }
}
