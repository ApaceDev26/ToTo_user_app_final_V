import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/checkout/controllers/checkout_controller.dart';
import 'package:toto_user/features/checkout/widgets/payment_method_bottom_sheet2.dart';
import 'package:toto_user/features/profile/controllers/profile_controller.dart';
import 'package:toto_user/helper/extensions.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentSection extends StatelessWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isWalletActive;
  final bool isOfflinePaymentActive;
  final double total;
  final CheckoutController checkoutController;
  const PaymentSection({
    super.key,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.checkoutController,
    required this.isOfflinePaymentActive,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    double walletBalance =
        Get.find<ProfileController>().userInfoModel?.walletBalance ?? 0;

    return InkWell(
      onTap: () {
        if (ResponsiveHelper.isDesktop(context)) {
          Get.dialog(Dialog(
              backgroundColor: Colors.transparent,
              child: PaymentMethodBottomSheet2(
                isCashOnDeliveryActive: isCashOnDeliveryActive,
                isDigitalPaymentActive: isDigitalPaymentActive,
                isWalletActive: isWalletActive,
                totalPrice: total,
                isOfflinePaymentActive: isOfflinePaymentActive,
              )));
        } else {
          Get.bottomSheet(
            PaymentMethodBottomSheet2(
              isCashOnDeliveryActive: isCashOnDeliveryActive,
              isDigitalPaymentActive: isDigitalPaymentActive,
              isWalletActive: isWalletActive,
              totalPrice: total,
              isOfflinePaymentActive: isOfflinePaymentActive,
            ),
            backgroundColor: Colors.transparent,
          );
        }
      },
      borderRadius: AppRadius.mdAll,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.mdAll,
          boxShadow: AppShadows.of(context, 1),
          border: Border.all(color: colors.line, width: 1),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(spacing: AppSpacing.sm, children: [
              Text('payment_method'.tr,
                  style: AppTypography.titleSm(colors.ink)),
            ]),
          ]),

          Divider(color: colors.line, height: AppSpacing.x2l),

          Container(
            child: checkoutController.paymentMethodIndex == 0 &&
                    !checkoutController.isPartialPay
                ? Row(children: [
                    Image.asset(
                      Images.cash,
                      width: 20,
                      height: 20,
                      color: colors.ink,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                        child: Row(
                      children: [
                        Text(
                          'cash_on_delivery'.tr,
                          style: AppTypography.labelMd(colors.inkMuted),
                        ),
                      ],
                    )),
                    Text(
                      PriceConverter.convertPrice(total),
                      textDirection: TextDirection.ltr,
                      style: AppTypography.price(colors.accent),
                    )
                  ])
                : checkoutController.isPartialPay
                    ? Column(children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('paid_by_wallet'.tr,
                                  style: AppTypography.bodySm(colors.ink)),
                              Text(
                                PriceConverter.convertPrice(walletBalance),
                                textDirection: TextDirection.ltr,
                                style: AppTypography.labelMd(colors.accent),
                              ),
                            ]),
                        const SizedBox(height: AppSpacing.xs),
                        Row(children: [
                          Text(
                            '${checkoutController.paymentMethodIndex == 0 ? 'cash_on_delivery'.tr : checkoutController.paymentMethodIndex == 1 && !checkoutController.isPartialPay ? 'wallet_payment'.tr : checkoutController.paymentMethodIndex == 2 ? '${'digital_payment'.tr} (${checkoutController.digitalPaymentName?.replaceAll('_', ' ').toTitleCase() ?? ''})' : checkoutController.paymentMethodIndex == 3 ? '${'offline_payment'.tr} (${checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodName})' : 'select_payment_method'.tr} ${checkoutController.paymentMethodIndex != 2 ? '(${'due'.tr})' : ''}',
                            style: AppTypography.bodySm(
                                checkoutController.paymentMethodIndex == 1 &&
                                        checkoutController.isPartialPay
                                    ? colors.inkFaint
                                    : colors.ink),
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          checkoutController.paymentMethodIndex == 1 &&
                                  checkoutController.isPartialPay
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: AppSpacing.xs),
                                  child: Icon(Icons.error,
                                      size: 16, color: colors.danger),
                                )
                              : const SizedBox(),
                          const Spacer(),
                          Text(
                            PriceConverter.convertPrice(total - walletBalance),
                            textDirection: TextDirection.ltr,
                            style: AppTypography.labelMd(colors.accent),
                          ),
                        ]),
                      ])
                    : Row(children: [
                        checkoutController.paymentMethodIndex != -1
                            ? Image.asset(
                                checkoutController.paymentMethodIndex == 0
                                    ? Images.cash
                                    : checkoutController.paymentMethodIndex == 1
                                        ? Images.wallet
                                        : Images.digitalPayment,
                                width: 20,
                                height: 20,
                                color: colors.ink,
                              )
                            : Icon(Icons.wallet_outlined,
                                size: 18, color: colors.inkFaint),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                            child: Row(children: [
                          Text(
                            checkoutController.paymentMethodIndex == 0
                                ? 'cash_on_delivery'.tr
                                : checkoutController.paymentMethodIndex == 1 &&
                                        !checkoutController.isPartialPay
                                    ? 'wallet_payment'.tr
                                    : checkoutController.paymentMethodIndex == 2
                                        ? '${'digital_payment'.tr} (${checkoutController.digitalPaymentName?.replaceAll('_', ' ').toTitleCase() ?? ''})'
                                        : checkoutController
                                                    .paymentMethodIndex ==
                                                3
                                            ? '${'offline_payment'.tr} (${checkoutController.offlineMethodList![checkoutController.selectedOfflineBankIndex].methodName})'
                                            : 'select_payment_method'.tr,
                            style: AppTypography.bodySm(colors.inkMuted),
                          ),
                          checkoutController.paymentMethodIndex == -1
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: AppSpacing.xs),
                                  child: Icon(Icons.error,
                                      size: 16, color: colors.danger),
                                )
                              : const SizedBox(),
                        ])),
                        !ResponsiveHelper.isDesktop(context)
                            ? PriceConverter.convertAnimationPrice(
                                checkoutController.isPartialPay
                                    ? checkoutController.viewTotalPrice
                                    : total,
                                textStyle: AppTypography.price(colors.accent),
                              )
                            : const SizedBox(),
                      ]),
          ),
        ]),
      ),
    );
  }
}
