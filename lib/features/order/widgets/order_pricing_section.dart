import 'package:dotted_border/dotted_border.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/order/controllers/order_controller.dart';
import 'package:toto_user/features/order/widgets/bottom_view_widget.dart';
import 'package:toto_user/features/order/widgets/order_product_widget.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/order/domain/models/order_model.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderPricingSection extends StatelessWidget {
  final double itemsPrice;
  final double addOns;
  final OrderModel order;
  final double subTotal;
  final double discount;
  final double couponDiscount;
  final double tax;
  final double dmTips;
  final double deliveryCharge;
  final double total;
  final OrderController orderController;
  final int? orderId;
  final String? contactNumber;
  final double extraPackagingAmount;
  final double referrerBonusAmount;
  const OrderPricingSection({
    super.key,
    required this.itemsPrice,
    required this.addOns,
    required this.order,
    required this.subTotal,
    required this.discount,
    required this.couponDiscount,
    required this.tax,
    required this.dmTips,
    required this.deliveryCharge,
    required this.total,
    required this.orderController,
    this.orderId,
    this.contactNumber,
    required this.extraPackagingAmount,
    required this.referrerBonusAmount,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final subscription = order.subscription != null;
    final taxIncluded = order.taxStatus ?? false;
    final isDineIn = order.orderType == 'dine_in';
    final showDmTips = !subscription &&
        !isDineIn &&
        order.orderType != 'take_away' &&
        Get.find<SplashController>().configModel!.dmTipsStatus == 1;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: colors.line),
        boxShadow: AppShadows.of(context, 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (isDesktop) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.xl,
                AppSpacing.md,
              ),
              child: Text(
                'item_info'.tr,
                style: AppTypography.displayMd(colors.ink).copyWith(
                  fontSize: 20,
                  height: 1.2,
                  letterSpacing: -0.3,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: orderController.orderDetails!.length,
              itemBuilder: (context, index) {
                return OrderProductWidget(
                  order: order,
                  orderDetails: orderController.orderDetails![index],
                );
              },
            ),
            Divider(height: 1, color: colors.line),
          ],
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              children: [
                _PriceRow(
                  label: 'item_price'.tr,
                  value: PriceConverter.convertPrice(itemsPrice),
                  colors: colors,
                ),
                const SizedBox(height: AppSpacing.sm),
                _PriceRow(
                  label: 'addons'.tr,
                  value: '(+) ${PriceConverter.convertPrice(addOns)}',
                  colors: colors,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(height: 1, color: colors.line),
                ),
                if (!subscription) ...[
                  _PriceRow(
                    label: 'subtotal'.tr,
                    value: PriceConverter.convertPrice(subTotal),
                    colors: colors,
                    emphasis: true,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                _PriceRow(
                  label: 'discount'.tr,
                  value: '(-) ${PriceConverter.convertPrice(discount)}',
                  colors: colors,
                ),
                if (order.additionalCharge != null &&
                    order.additionalCharge! > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _PriceRow(
                    label: Get.find<SplashController>()
                        .configModel!
                        .additionalChargeName!,
                    value:
                        '(+) ${PriceConverter.convertPrice(order.additionalCharge)}',
                    colors: colors,
                  ),
                ],
                if (couponDiscount > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _PriceRow(
                    label: 'coupon_discount'.tr,
                    value:
                        '(-) ${PriceConverter.convertPrice(couponDiscount)}',
                    colors: colors,
                  ),
                ],
                if (referrerBonusAmount > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _PriceRow(
                    label: 'referral_discount'.tr,
                    value:
                        '(-) ${PriceConverter.convertPrice(referrerBonusAmount)}',
                    colors: colors,
                  ),
                ],
                if (tax != 0 && !taxIncluded) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _PriceRow(
                    label: 'vat_tax'.tr,
                    value: '(+) ${PriceConverter.convertPrice(tax)}',
                    colors: colors,
                  ),
                ],
                if (showDmTips) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _PriceRow(
                    label: 'delivery_man_tips'.tr,
                    value: '(+) ${PriceConverter.convertPrice(dmTips)}',
                    colors: colors,
                  ),
                ],
                if (extraPackagingAmount > 0) ...[
                  const SizedBox(height: AppSpacing.sm),
                  _PriceRow(
                    label: 'extra_packaging'.tr,
                    value:
                        '(+) ${PriceConverter.convertPrice(extraPackagingAmount)}',
                    colors: colors,
                  ),
                ],
                if (!isDineIn && order.orderType != 'take_away') ...[
                  const SizedBox(height: AppSpacing.sm),
                  _PriceRow(
                    label: 'delivery_fee'.tr,
                    value: deliveryCharge > 0
                        ? '(+) ${PriceConverter.convertPrice(deliveryCharge)}'
                        : 'free'.tr,
                    colors: colors,
                    valueColor:
                        deliveryCharge > 0 ? null : colors.accent,
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(height: 1, color: colors.line),
                ),
                if (order.paymentMethod == 'partial_payment')
                  Container(
                    decoration: BoxDecoration(
                      color: colors.accentSoft,
                      borderRadius: AppRadius.mdAll,
                    ),
                    child: DottedBorder(
                      color: colors.accent,
                      strokeWidth: 1,
                      strokeCap: StrokeCap.butt,
                      dashPattern: const [8, 5],
                      padding: const EdgeInsets.all(AppSpacing.md),
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(AppRadius.md),
                      child: Column(
                        children: [
                          _PriceRow(
                            label: taxIncluded
                                ? '${'total_amount'.tr} ${'vat_tax_inc'.tr}'
                                : 'total_amount'.tr,
                            value: PriceConverter.convertPrice(total),
                            colors: colors,
                            emphasis: true,
                            valueColor: colors.accent,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _PriceRow(
                            label: 'paid_by_wallet'.tr,
                            value: PriceConverter.convertPrice(
                                order.payments?[0].amount ?? 0),
                            colors: colors,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _PriceRow(
                            label:
                                '${order.payments?[1].paymentStatus == 'paid' ? 'paid_by'.tr : 'due_amount'.tr} (${order.payments?[1].paymentMethod?.toString().replaceAll('_', ' ')})',
                            value: PriceConverter.convertPrice(
                                order.payments?[1].amount ?? 0),
                            colors: colors,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  _PriceRow(
                    label: taxIncluded
                        ? '${subscription ? 'subtotal'.tr : 'total_amount'.tr} ${'vat_tax_inc'.tr}'
                        : (subscription ? 'subtotal'.tr : 'total_amount'.tr),
                    value: PriceConverter.convertPrice(total),
                    colors: colors,
                    emphasis: true,
                    large: true,
                    valueColor: colors.accent,
                  ),
                if (subscription) ...[
                  const SizedBox(height: AppSpacing.md),
                  _PriceRow(
                    label: 'subscription_order_count'.tr,
                    value: order.subscription!.quantity.toString(),
                    colors: colors,
                    emphasis: true,
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Divider(height: 1, color: colors.line),
                  ),
                  _PriceRow(
                    label: 'total_amount'.tr,
                    value: PriceConverter.convertPrice(
                        total * order.subscription!.quantity!),
                    colors: colors,
                    emphasis: true,
                    large: true,
                    valueColor: colors.accent,
                  ),
                ],
              ],
            ),
          ),
          if (isDesktop)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: BottomViewWidget(
                orderController: orderController,
                order: order,
                orderId: orderId,
                total: total,
                contactNumber: contactNumber,
              ),
            ),
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.label,
    required this.value,
    required this.colors,
    this.emphasis = false,
    this.large = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final AppColors colors;
  final bool emphasis;
  final bool large;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = large
        ? AppTypography.titleSm(valueColor ?? colors.ink)
        : emphasis
            ? AppTypography.labelMd(valueColor ?? colors.ink)
            : AppTypography.bodyMd(valueColor ?? colors.inkMuted);
    final labelStyle = large
        ? AppTypography.titleSm(colors.ink)
        : emphasis
            ? AppTypography.labelMd(colors.ink)
            : AppTypography.bodyMd(colors.inkMuted);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(child: Text(label, style: labelStyle)),
        const SizedBox(width: AppSpacing.md),
        Text(
          value,
          style: style,
          textDirection: TextDirection.ltr,
        ),
      ],
    );
  }
}
