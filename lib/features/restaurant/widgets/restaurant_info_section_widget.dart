import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/coupon/controllers/coupon_controller.dart';
import 'package:toto_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:toto_user/features/restaurant/widgets/coupon_view_widget.dart';
import 'package:toto_user/common/widgets/customizable_space_bar_widget.dart';
import 'package:toto_user/features/restaurant/widgets/info_view_widget.dart';
import 'package:toto_user/common/models/restaurant_model.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marquee/marquee.dart';

/// Restaurant Details header — editorial cover + identity panel.
class RestaurantInfoSectionWidget extends StatelessWidget {
  final Restaurant restaurant;
  final RestaurantController restController;
  final bool hasCoupon;
  const RestaurantInfoSectionWidget({
    super.key,
    required this.restaurant,
    required this.restController,
    required this.hasCoupon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final double xyz = MediaQuery.of(context).size.width - 1170;
    final double realSpaceNeeded = xyz / 2;
    final announcement = restaurant.announcementActive == true &&
        (restaurant.announcementMessage ?? '').isNotEmpty;

    final statusTop = MediaQuery.paddingOf(context).top;
    // Collapsed bar must fit logo + name below the status area.
    final mobileToolbarHeight = 88.0;
    final expandedHeight = isDesktop
        ? 320.0
        : hasCoupon
            ? 360.0 + statusTop
            : 300.0 + statusTop;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      toolbarHeight: isDesktop ? 120 : mobileToolbarHeight,
      pinned: true,
      primary: true,
      centerTitle: false,
      floating: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      surfaceTintColor: Colors.transparent,
      backgroundColor: colors.canvas,
      leadingWidth: isDesktop ? 0 : 56,
      leading: !isDesktop
          ? Padding(
              padding: const EdgeInsets.only(left: AppSpacing.sm),
              child: Center(
                child: _GlassBackButton(onTap: () => Get.back()),
              ),
            )
          : const SizedBox.shrink(),
      flexibleSpace: GetBuilder<CouponController>(builder: (couponController) {
        final hasCoupons = couponController.couponList != null &&
            couponController.couponList!.isNotEmpty;
        return Container(
          margin: isDesktop
              ? EdgeInsets.symmetric(horizontal: realSpaceNeeded)
              : EdgeInsets.zero,
          child: FlexibleSpaceBar(
            titlePadding: EdgeInsets.zero,
            centerTitle: true,
            expandedTitleScale: 1,
            title: CustomizableSpaceBarWidget(
              builder: (context, scrollingRate) {
                final collapse = scrollingRate.clamp(0.0, 1.0);
                return isDesktop
                    ? _DesktopIdentityPanel(
                        restaurant: restaurant,
                        restController: restController,
                        hasCoupons: hasCoupons,
                        announcement: announcement,
                        collapse: collapse,
                      )
                    : _MobileIdentityPanel(
                        restaurant: restaurant,
                        restController: restController,
                        hasCoupon: hasCoupon,
                        collapse: collapse,
                      );
              },
            ),
            background: _CoverBackground(
              imageUrl: restaurant.coverPhotoFullUrl,
              bottomInset: isDesktop ? 88 : (hasCoupon ? 168 : 120),
            ),
          ),
        );
      }),
      actions: const [SizedBox.shrink()],
    );
  }
}

class _GlassBackButton extends StatelessWidget {
  const _GlassBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      label: 'back'.tr,
      child: Material(
        color: colors.glass,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: AppIcons.touchTarget,
            height: AppIcons.touchTarget,
            child: Icon(
              Icons.arrow_back_rounded,
              size: AppIcons.sm,
              color: colors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

class _CoverBackground extends StatelessWidget {
  const _CoverBackground({
    required this.imageUrl,
    required this.bottomInset,
  });

  final String? imageUrl;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: bottomInset),
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImageWidget(
            height: double.infinity,
            fit: BoxFit.cover,
            placeholder: Images.restaurantCover,
            image: imageUrl ?? '',
            isRestaurant: true,
          ),
          // Soft bottom fade into canvas so the identity panel feels continuous.
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    colors.canvas.withValues(alpha: 0),
                    colors.canvas.withValues(alpha: 0.85),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MobileIdentityPanel extends StatelessWidget {
  const _MobileIdentityPanel({
    required this.restaurant,
    required this.restController,
    required this.hasCoupon,
    required this.collapse,
  });

  final Restaurant restaurant;
  final RestaurantController restController;
  final bool hasCoupon;
  final double collapse;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final collapsed = collapse >= 0.92;
    // Clear the leading back button as the flexible space shrinks.
    final leadingClearance = 48.0 * collapse;

    if (collapsed) {
      // Keep identity in the toolbar band only — never under the status bar.
      return Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: 72,
          child: Padding(
            padding: EdgeInsets.only(
              left: leadingClearance + AppSpacing.sm,
              right: AppSpacing.page(context),
              bottom: AppSpacing.sm,
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: InfoViewWidget(
                restaurant: restaurant,
                restController: restController,
                scrollingRate: 1,
                compact: true,
              ),
            ),
          ),
        ),
      );
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          left: AppSpacing.page(context) + leadingClearance * 0.35,
          right: AppSpacing.page(context),
          bottom: AppSpacing.sm,
        ),
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: colors.line.withValues(alpha: 0.7)),
          boxShadow: AppShadows.of(context, 1),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoViewWidget(
              restaurant: restaurant,
              restController: restController,
              scrollingRate: collapse,
            ),
            if (hasCoupon && collapse < 0.75) ...[
              const SizedBox(height: AppSpacing.md),
              CouponViewWidget(scrollingRate: collapse),
            ],
          ],
        ),
      ),
    );
  }
}

class _DesktopIdentityPanel extends StatelessWidget {
  const _DesktopIdentityPanel({
    required this.restaurant,
    required this.restController,
    required this.hasCoupons,
    required this.announcement,
    required this.collapse,
  });

  final Restaurant restaurant;
  final RestaurantController restController;
  final bool hasCoupons;
  final bool announcement;
  final double collapse;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isOpen = restController.isRestaurantOpenNow(
      restaurant.active!,
      restaurant.schedules,
    );

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: hasCoupons ? AppSpacing.x3l : 120,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(color: colors.line.withValues(alpha: 0.7)),
          boxShadow: AppShadows.of(context, 2),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (announcement && collapse < 0.9)
              _AnnouncementBanner(
                message: restaurant.announcementMessage!,
                height: 36 - (collapse * 36),
              ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Opacity(
                    opacity: (1 - collapse).clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, collapse * 24),
                      child: _DesktopLogo(
                        imageUrl: restaurant.logoFullUrl,
                        size: 88 - (collapse * 36),
                        isOpen: isOpen,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    flex: hasCoupons ? 3 : 1,
                    child: InfoViewWidget(
                      restaurant: restaurant,
                      restController: restController,
                      scrollingRate: collapse,
                      showLogo: false,
                    ),
                  ),
                  if (hasCoupons) ...[
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      flex: 2,
                      child: CouponViewWidget(scrollingRate: collapse),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DesktopLogo extends StatelessWidget {
  const _DesktopLogo({
    required this.imageUrl,
    required this.size,
    required this.isOpen,
  });

  final String? imageUrl;
  final double size;
  final bool isOpen;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (size < 40) return const SizedBox.shrink();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.smAll,
        border: Border.all(color: colors.line),
        boxShadow: AppShadows.of(context, 1),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CustomImageWidget(
            image: imageUrl ?? '',
            fit: BoxFit.cover,
            isRestaurant: true,
          ),
          if (!isOpen)
            Container(
              color: colors.overlay,
              alignment: Alignment.center,
              child: Text(
                'closed_now'.tr,
                textAlign: TextAlign.center,
                style: AppTypography.labelSm(colors.onAccent),
              ),
            ),
        ],
      ),
    );
  }
}

class _AnnouncementBanner extends StatelessWidget {
  const _AnnouncementBanner({
    required this.message,
    required this.height,
  });

  final String message;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    if (height < 8) return const SizedBox.shrink();
    return Container(
      height: height,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      color: colors.success.withValues(alpha: 0.12),
      child: Row(
        children: [
          Icon(Icons.campaign_outlined, size: 18, color: colors.success),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Marquee(
              text: message,
              style: AppTypography.labelMd(colors.success),
              blankSpace: 40,
              velocity: 40,
              pauseAfterRound: const Duration(seconds: 1),
            ),
          ),
        ],
      ),
    );
  }
}
