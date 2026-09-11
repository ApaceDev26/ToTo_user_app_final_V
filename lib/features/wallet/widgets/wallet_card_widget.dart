import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/language/controllers/localization_controller.dart';
import 'package:toto_user/features/profile/controllers/profile_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/wallet/controllers/withdraw_controller.dart';
import 'package:toto_user/features/wallet/widgets/add_fund_dialogue_widget.dart';
import 'package:toto_user/features/wallet/widgets/withdraw_request_bottom_sheet_widget.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class WalletCardWidget extends StatelessWidget {
  final JustTheController tooltipController;
  const WalletCardWidget({super.key, required this.tooltipController});

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final colors = AppColors.of(context);
    return GetBuilder<ProfileController>(builder: (profileController) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(children: [
            Container(
              margin: EdgeInsets.only(
                  top: isDesktop ? 0 : AppSpacing.xl),
              padding: EdgeInsets.all(
                  isDesktop ? 35 : AppSpacing.x2l),
              decoration: BoxDecoration(
                borderRadius: AppRadius.mdAll,
                color: colors.accent,
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('wallet_amount'.tr,
                        style: AppTypography.bodySm(colors.onAccent)),
                    const SizedBox(height: AppSpacing.sm),
                    Row(children: [
                      Text(
                        PriceConverter.convertPrice(
                            profileController.userInfoModel?.walletBalance ??
                                0),
                        textDirection: TextDirection.ltr,
                        style: AppTypography.displayMd(colors.onAccent),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Get.find<SplashController>().configModel!.addFundStatus!
                          ? JustTheTooltip(
                              backgroundColor: colors.ink,
                              controller: tooltipController,
                              preferredDirection: AxisDirection.down,
                              tailLength: 14,
                              tailBaseWidth: 20,
                              content: Padding(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                child: Text(
                                  'if_you_want_to_add_fund_to_your_wallet_then_click_add_fund_button'
                                      .tr,
                                  style: AppTypography.bodySm(colors.canvas),
                                ),
                              ),
                              child: InkWell(
                                onTap: () => tooltipController.showTooltip(),
                                child: Icon(Icons.info_outline,
                                    color: colors.onAccent),
                              ),
                            )
                          : const SizedBox(),
                    ]),
                  ]),
            ),
            Get.find<SplashController>().configModel!.addFundStatus!
                ? Positioned(
                    top: Get.find<SplashController>()
                            .configModel!
                            .customerWithdrawStatus!
                        ? 40
                        : 60,
                    right: Get.find<LocalizationController>().isLtr ? 20 : null,
                    left: Get.find<LocalizationController>().isLtr ? null : 10,
                    bottom: Get.find<SplashController>()
                            .configModel!
                            .customerWithdrawStatus!
                        ? null
                        : 40,
                    child: InkWell(
                      onTap: () {
                        if (Get.find<SplashController>()
                            .configModel!
                            .digitalPayment!) {
                          Get.dialog(
                            const Dialog(
                              shadowColor: Colors.transparent,
                              backgroundColor: Colors.transparent,
                              surfaceTintColor: Colors.transparent,
                              insetPadding: EdgeInsets.zero,
                              child: SizedBox(
                                  width: 500, child: AddFundDialogueWidget()),
                            ),
                          );
                        } else {
                          showCustomSnackBar(
                              'currently_digital_payment_is_not_available'.tr);
                        }
                      },
                      child: Container(
                        width: 90,
                        decoration: BoxDecoration(
                            borderRadius: AppRadius.mdAll,
                            color: colors.surface),
                        padding: const EdgeInsets.all(AppSpacing.xs),
                        child: Text(
                          'add'.tr,
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyMd(colors.accent),
                        ),
                      ),
                    ),
                  )
                : const SizedBox(),
            Get.find<SplashController>().configModel!.customerWithdrawStatus!
                ? Positioned(
                    top: 83,
                    right: Get.find<LocalizationController>().isLtr ? 20 : null,
                    left: Get.find<LocalizationController>().isLtr ? null : 80,
                    child: Material(
                      color: Colors.transparent,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Get.toNamed(RouteHelper.withdrawHistory);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: colors.surface),
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                child: Icon(Icons.history, color: colors.accent),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                debugPrint('Withdraw button tapped!');
                                if (profileController
                                            .userInfoModel?.walletBalance !=
                                        null &&
                                    profileController
                                            .userInfoModel!.walletBalance! >
                                        0) {
                                  try {
                                    // Ensure controller is initialized
                                    if (!Get.isRegistered<
                                        WithdrawController>()) {
                                      showCustomSnackBar(
                                          'please_wait_initializing'.tr);
                                      return;
                                    }

                                    // Initialize withdraw methods before showing bottom sheet
                                    await Get.find<WithdrawController>()
                                        .initWithdrawMethod();

                                    Get.bottomSheet(
                                      const WithdrawRequestBottomSheetWidget(),
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                    );
                                  } catch (e) {
                                    debugPrint(
                                        'Error showing withdraw bottom sheet: $e');
                                    showCustomSnackBar(
                                        'error_loading_withdraw_options'.tr);
                                  }
                                } else {
                                  showCustomSnackBar(
                                      'insufficient_wallet_balance'.tr);
                                }
                              },
                              child: Container(
                                width: 90,
                                decoration: BoxDecoration(
                                    borderRadius: AppRadius.mdAll,
                                    color: colors.surface),
                                padding: const EdgeInsets.all(AppSpacing.xs),
                                child: Text(
                                  'Withdraw'.tr,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMd(colors.accent),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : const SizedBox(),
            Positioned(
              bottom: 0,
              right: 60,
              child: IgnorePointer(
                child: Image.asset(
                  Images.walletPay,
                  height: 80,
                  width: 80,
                  opacity: const AlwaysStoppedAnimation(0.2),
                ),
              ),
            ),
          ]),
          isDesktop
              ? const SizedBox()
              : const SizedBox(height: AppSpacing.xl),
          isDesktop
              ? const SizedBox(height: AppSpacing.lg)
              : const SizedBox(),
          isDesktop
              ? Text('how_to_use'.tr,
                  style: AppTypography.titleSm(colors.ink))
              : const SizedBox(),
          isDesktop
              ? const SizedBox(height: AppSpacing.lg)
              : const SizedBox(),
          !isDesktop ? const SizedBox() : const WalletStepper(),
        ],
      );
    });
  }
}

class WalletStepper extends StatelessWidget {
  const WalletStepper({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return SizedBox(
      height: 200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.xs),
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.accent, width: 2)),
              ),
              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: colors.accent.withValues(alpha: 0.30),
                ),
              ),
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.accent, width: 2)),
              ),
              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: colors.accent.withValues(alpha: 0.30),
                ),
              ),
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.accent, width: 2)),
              ),
              Expanded(
                child: VerticalDivider(
                  thickness: 3,
                  color: colors.accent.withValues(alpha: 0.30),
                ),
              ),
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.accent, width: 2)),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                    'earn_money_to_your_wallet_by_completing_the_offer_challenged'
                        .tr,
                    style: AppTypography.bodyMd(colors.ink)),
                Text('convert_your_loyalty_points_into_wallet_money'.tr,
                    style: AppTypography.bodyMd(colors.ink)),
                Text(
                    'amin_also_reward_their_top_customers_with_wallet_money'.tr,
                    style: AppTypography.bodyMd(colors.ink)),
                Text('send_your_wallet_money_while_order'.tr,
                    style: AppTypography.bodyMd(colors.ink)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
