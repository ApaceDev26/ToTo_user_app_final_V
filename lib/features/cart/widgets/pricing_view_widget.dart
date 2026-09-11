import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/design_system/components/app_primitives.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/cart/widgets/checkout_button_widget.dart';
import 'package:toto_user/features/cart/widgets/cutlary_view_widget.dart';
import 'package:toto_user/features/cart/widgets/extra_packaging_widget.dart';
import 'package:toto_user/features/cart/widgets/not_available_product_view_widget.dart';
import 'package:toto_user/features/checkout/widgets/delivery_instruction_view.dart';
import 'package:toto_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PricingViewWidget extends StatelessWidget {
  final CartController cartController;
  final bool isRestaurantOpen;
  final bool fromDineIn;
  const PricingViewWidget(
      {super.key,
      required this.cartController,
      required this.isRestaurantOpen,
      this.fromDineIn = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Container(
      decoration: isDesktop
          ? BoxDecoration(
              borderRadius: AppRadius.mdAll,
              color: colors.surface,
              boxShadow: AppShadows.of(context, 1),
              border: Border.all(color: colors.line, width: 1),
            )
          : BoxDecoration(
              color: colors.canvas,
              borderRadius: AppRadius.smAll,
            ),
      child: GetBuilder<RestaurantController>(builder: (restaurantController) {
        return Column(children: [
          isDesktop
              ? Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                    child: Text('order_summary'.tr,
                        style: AppTypography.titleSm(colors.ink)),
                  ),
                )
              : const SizedBox(),
          const SizedBox(height: AppSpacing.sm),
          !isDesktop && !fromDineIn
              ? ExtraPackagingWidget(cartController: cartController)
              : const SizedBox(),
          !isDesktop && !fromDineIn
              ? CutleryViewWidget(
                  restaurantController: restaurantController,
                  cartController: cartController)
              : const SizedBox(),
          !isDesktop
              ? NotAvailableProductViewWidget(cartController: cartController)
              : const SizedBox(),
          !isDesktop ? const DeliveryInstructionView() : const SizedBox(),
          isDesktop
              ? const SizedBox()
              : const SizedBox(height: AppSpacing.xl),
          isDesktop
              ? Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  child: Column(children: [
                    _SummaryRow(
                      label: 'item_price'.tr,
                      valueChild: PriceConverter.convertAnimationPrice(
                          cartController.itemPrice,
                          textStyle: AppTypography.bodyMd(colors.ink)),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    cartController.variationPrice > 0
                        ? _SummaryRow(
                            label: 'variations'.tr,
                            valueChild: Text(
                                '(+) ${PriceConverter.convertPrice(cartController.variationPrice)}',
                                style: AppTypography.bodyMd(colors.ink),
                                textDirection: TextDirection.ltr),
                          )
                        : const SizedBox(),
                    SizedBox(
                        height: cartController.addOns > 0 ? AppSpacing.sm : 0),
                    cartController.displayDiscount > 0
                        ? _SummaryRow(
                            label: 'discount'.tr,
                            valueChild: restaurantController.restaurant != null
                                ? Row(children: [
                                    Text('(-)',
                                        style:
                                            AppTypography.bodyMd(colors.ink)),
                                    PriceConverter.convertAnimationPrice(
                                        cartController.displayDiscount,
                                        textStyle:
                                            AppTypography.bodyMd(colors.ink)),
                                  ])
                                : Text('calculating'.tr,
                                    style:
                                        AppTypography.bodyMd(colors.inkMuted)),
                          )
                        : const SizedBox(),
                    SizedBox(
                        height: cartController.addOns > 0 ? AppSpacing.sm : 0),
                    _SummaryRow(
                      label: 'addons'.tr,
                      valueChild: Row(children: [
                        Text('(+)', style: AppTypography.bodyMd(colors.ink)),
                        PriceConverter.convertAnimationPrice(
                            cartController.addOns,
                            textStyle: AppTypography.bodyMd(colors.ink)),
                      ]),
                    ),
                    isDesktop
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                            child: AppDivider(),
                          )
                        : const SizedBox(),
                    isDesktop
                        ? _SummaryRow(
                            label: 'subtotal'.tr,
                            labelStyle: AppTypography.labelLg(colors.accent),
                            valueChild: PriceConverter.convertAnimationPrice(
                                cartController.subTotal,
                                textStyle:
                                    AppTypography.price(colors.accent)),
                          )
                        : const SizedBox(),
                  ]),
                )
              : const SizedBox(),
          isDesktop && !fromDineIn
              ? ExtraPackagingWidget(cartController: cartController)
              : const SizedBox(),
          isDesktop && !fromDineIn
              ? CutleryViewWidget(
                  restaurantController: restaurantController,
                  cartController: cartController)
              : const SizedBox(),
          isDesktop
              ? NotAvailableProductViewWidget(cartController: cartController)
              : const SizedBox(),
          isDesktop ? const DeliveryInstructionView() : const SizedBox(),
          SizedBox(height: isDesktop ? AppSpacing.xl : 0),
          isDesktop
              ? CheckoutButtonWidget(
                  cartController: cartController,
                  availableList: cartController.availableList,
                  isRestaurantOpen: isRestaurantOpen,
                  fromDineIn: fromDineIn)
              : const SizedBox.shrink(),
        ]);
      }),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.valueChild,
    this.labelStyle,
  });

  final String label;
  final Widget valueChild;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: labelStyle ?? AppTypography.bodyMd(colors.inkMuted)),
        valueChild,
      ],
    );
  }
}
