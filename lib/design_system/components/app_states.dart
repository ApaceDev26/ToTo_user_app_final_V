import 'package:flutter/material.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/design_system/components/app_button.dart';

class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = AppRadius.xs,
  });

  final double? width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Shimmer(
      duration: const Duration(seconds: 2),
      color: colors.surfaceElevated,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: colors.line,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}

class AppSkeletonCard extends StatelessWidget {
  const AppSkeletonCard({super.key, this.imageHeight = 140});

  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSkeleton(height: imageHeight, radius: AppRadius.md),
        const SizedBox(height: AppSpacing.md),
        const AppSkeleton(width: 160, height: 14),
        const SizedBox(height: AppSpacing.sm),
        const AppSkeleton(width: 100, height: 12),
      ],
    );
  }
}

enum AppEmptyType {
  generic,
  cart,
  orders,
  search,
  favourites,
  address,
  notification,
  chat,
  coupon,
  offline,
  error,
}

class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.type = AppEmptyType.generic,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final AppEmptyType type;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  IconData get _icon {
    if (icon != null) return icon!;
    switch (type) {
      case AppEmptyType.cart:
        return Icons.shopping_bag_outlined;
      case AppEmptyType.orders:
        return Icons.receipt_long_outlined;
      case AppEmptyType.search:
        return Icons.search_off_rounded;
      case AppEmptyType.favourites:
        return Icons.favorite_border_rounded;
      case AppEmptyType.address:
        return Icons.location_off_outlined;
      case AppEmptyType.notification:
        return Icons.notifications_none_rounded;
      case AppEmptyType.chat:
        return Icons.chat_bubble_outline_rounded;
      case AppEmptyType.coupon:
        return Icons.local_offer_outlined;
      case AppEmptyType.offline:
        return Icons.wifi_off_rounded;
      case AppEmptyType.error:
        return Icons.error_outline_rounded;
      case AppEmptyType.generic:
        return Icons.inbox_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.x3l),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(_icon, size: 40, color: colors.accent),
              ),
              const SizedBox(height: AppSpacing.x2l),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.titleMd(colors.ink),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMd(colors.inkMuted),
                ),
              ],
              if (actionLabel != null && onAction != null) ...[
                const SizedBox(height: AppSpacing.x2l),
                AppButton(
                  label: actionLabel!,
                  onPressed: onAction,
                  expand: false,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppErrorState extends StatelessWidget {
  const AppErrorState({
    super.key,
    this.title = 'Something went wrong',
    this.subtitle,
    this.onRetry,
  });

  final String title;
  final String? subtitle;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppEmptyState(
      type: AppEmptyType.error,
      title: title,
      subtitle: subtitle ?? 'Please try again in a moment.',
      actionLabel: onRetry != null ? 'Try again' : null,
      onAction: onRetry,
    );
  }
}
