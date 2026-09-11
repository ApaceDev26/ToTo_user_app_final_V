import 'package:flutter/material.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/design_system/components/app_primitives.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';

/// Editorial restaurant card — media-first, not template left-thumb.
class AppRestaurantCard extends StatelessWidget {
  const AppRestaurantCard({
    super.key,
    required this.name,
    required this.imageUrl,
    this.cuisine,
    this.rating,
    this.ratingCount,
    this.distance,
    this.deliveryTime,
    this.discountLabel,
    this.isClosed = false,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  final String name;
  final String? imageUrl;
  final String? cuisine;
  final double? rating;
  final int? ratingCount;
  final String? distance;
  final String? deliveryTime;
  final String? discountLabel;
  final bool isClosed;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      button: true,
      label: name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.mdAll,
              boxShadow: AppShadows.of(context, 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 16 / 10,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomImageWidget(
                        image: imageUrl ?? '',
                        fit: BoxFit.cover,
                      ),
                      if (discountLabel != null)
                        Positioned(
                          left: AppSpacing.sm,
                          top: AppSpacing.sm,
                          child: AppTag.discount(label: discountLabel!),
                        ),
                      if (onFavorite != null)
                        Positioned(
                          right: AppSpacing.sm,
                          top: AppSpacing.sm,
                          child: _FavButton(
                            isFavorite: isFavorite,
                            onTap: onFavorite!,
                          ),
                        ),
                      if (isClosed)
                        Container(
                          color: colors.overlay,
                          alignment: Alignment.center,
                          child: Text(
                            'Closed',
                            style: AppTypography.labelLg(colors.onAccent),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSm(colors.ink),
                      ),
                      if (cuisine != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          cuisine!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySm(colors.inkMuted),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          if (rating != null)
                            AppRating(rating: rating!, count: ratingCount),
                          if (deliveryTime != null) ...[
                            const SizedBox(width: AppSpacing.md),
                            Icon(Icons.schedule_rounded,
                                size: 14, color: colors.inkFaint),
                            const SizedBox(width: 2),
                            Text(deliveryTime!,
                                style: AppTypography.bodySm(colors.inkMuted)),
                          ],
                          if (distance != null) ...[
                            const SizedBox(width: AppSpacing.md),
                            Text(distance!,
                                style: AppTypography.bodySm(colors.inkMuted)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavButton extends StatelessWidget {
  const _FavButton({required this.isFavorite, required this.onTap});
  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      label: isFavorite ? 'Remove favourite' : 'Add favourite',
      child: Material(
        color: colors.glass,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(
              isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              size: 20,
              color: isFavorite ? colors.warm : colors.ink,
            ),
          ),
        ),
      ),
    );
  }
}

/// Editorial food card — vertical tile.
class AppFoodCard extends StatelessWidget {
  const AppFoodCard({
    super.key,
    required this.name,
    required this.imageUrl,
    required this.price,
    this.originalPrice,
    this.restaurantName,
    this.discountLabel,
    this.onTap,
    this.onAdd,
  });

  final String name;
  final String? imageUrl;
  final String price;
  final String? originalPrice;
  final String? restaurantName;
  final String? discountLabel;
  final VoidCallback? onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      button: true,
      label: name,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Container(
            width: 168,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.mdAll,
              boxShadow: AppShadows.of(context, 1),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AspectRatio(
                  aspectRatio: 1,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomImageWidget(
                        image: imageUrl ?? '',
                        fit: BoxFit.cover,
                      ),
                      if (discountLabel != null)
                        Positioned(
                          left: AppSpacing.sm,
                          top: AppSpacing.sm,
                          child: AppTag.discount(label: discountLabel!),
                        ),
                      if (onAdd != null)
                        Positioned(
                          right: AppSpacing.sm,
                          bottom: AppSpacing.sm,
                          child: Material(
                            color: colors.accent,
                            borderRadius: AppRadius.smAll,
                            child: InkWell(
                              onTap: onAdd,
                              borderRadius: AppRadius.smAll,
                              child: SizedBox(
                                width: 36,
                                height: 36,
                                child: Icon(Icons.add_rounded,
                                    color: colors.onAccent, size: 20),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.labelLg(colors.ink),
                      ),
                      if (restaurantName != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          restaurantName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.bodySm(colors.inkFaint),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      AppPriceText(price: price, originalPrice: originalPrice),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
