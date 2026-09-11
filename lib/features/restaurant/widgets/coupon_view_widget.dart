import 'package:carousel_slider/carousel_slider.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/coupon/controllers/coupon_controller.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

/// Calm coupon strip for restaurant details — one surface, no competing cards.
class CouponViewWidget extends StatelessWidget {
  final double scrollingRate;
  const CouponViewWidget({super.key, required this.scrollingRate});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final collapse = scrollingRate.clamp(0.0, 1.0);

    return GetBuilder<CouponController>(builder: (couponController) {
      final coupons = couponController.couponList;
      if (coupons == null || coupons.isEmpty) {
        return const SizedBox.shrink();
      }

      final height = isDesktop
          ? 88.0 - (collapse * 16)
          : 72.0 - (collapse * 40);
      if (height < 28) return const SizedBox.shrink();

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: height,
            width: double.infinity,
            child: CarouselSlider.builder(
              options: CarouselOptions(
                autoPlay: coupons.length > 1,
                enlargeCenterPage: false,
                disableCenter: true,
                viewportFraction: 1,
                autoPlayInterval: const Duration(seconds: 7),
                onPageChanged: (index, reason) {
                  couponController.setCurrentIndex(index, true);
                },
              ),
              itemCount: coupons.length,
              itemBuilder: (context, index, _) {
                final coupon = coupons[index];
                return Container(
                  decoration: BoxDecoration(
                    color: colors.accentSoft,
                    borderRadius: AppRadius.smAll,
                    border: Border.all(color: colors.line),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.local_offer_outlined,
                        size: AppIcons.sm,
                        color: colors.accent,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              coupon.title ?? coupon.code ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelMd(colors.ink),
                            ),
                            if (collapse < 0.5) ...[
                              const SizedBox(height: AppSpacing.xxs),
                              Text(
                                '${DateConverter.stringToReadableString(coupon.startDate!)} ${'to'.tr} ${DateConverter.stringToReadableString(coupon.expireDate!)}'
                                ' · ${'min_purchase'.tr} ${PriceConverter.convertPrice(coupon.minPurchase)}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.bodySm(colors.inkMuted),
                              ),
                            ],
                          ],
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(
                              ClipboardData(text: coupon.code ?? ''));
                          showCustomSnackBar('coupon_code_copied'.tr,
                              isError: false);
                        },
                        borderRadius: AppRadius.xsAll,
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                coupon.code ?? '',
                                style: AppTypography.labelSm(colors.accent),
                              ),
                              const SizedBox(width: AppSpacing.xxs),
                              Icon(
                                Icons.copy_rounded,
                                size: 14,
                                color: colors.accent,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          if (coupons.length > 1 && collapse < 0.4) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(coupons.length, (index) {
                final active = index == couponController.currentIndex;
                return AnimatedContainer(
                  duration: AppDurations.fast,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: active ? 14 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: active
                        ? colors.accent
                        : colors.accent.withValues(alpha: 0.35),
                    borderRadius: AppRadius.pillAll,
                  ),
                );
              }),
            ),
          ],
        ],
      );
    });
  }
}
