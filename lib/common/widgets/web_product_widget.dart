import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/hover_widgets/on_hover_widget.dart';
import 'package:toto_user/common/widgets/product_bottom_sheet_widget.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/common/models/restaurant_model.dart';
import 'package:toto_user/features/restaurant/screens/restaurant_screen.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Lumen Atelier web grid card — full-bleed glass dock (food) or cover (restaurant).
class WebProductWidget extends StatelessWidget {
  final Product? product;
  final Restaurant? restaurant;
  final bool isRestaurant;
  final int index;
  final int? length;
  final bool inRestaurant;
  final bool isCampaign;
  final bool isFeatured;
  final bool fromCartSuggestion;

  const WebProductWidget({
    super.key,
    required this.product,
    required this.isRestaurant,
    required this.restaurant,
    required this.index,
    required this.length,
    this.inRestaurant = false,
    this.isCampaign = false,
    this.isFeatured = false,
    this.fromCartSuggestion = false,
  });

  @override
  Widget build(BuildContext context) {
    return OnHoverWidget(
      isItem: true,
      child: isRestaurant
          ? _WebRestaurantTile(
              restaurant: restaurant!,
            )
          : _WebFoodTile(
              product: product!,
              inRestaurant: inRestaurant,
              isCampaign: isCampaign,
            ),
    );
  }
}

class _WebFoodTile extends StatelessWidget {
  const _WebFoodTile({
    required this.product,
    required this.inRestaurant,
    required this.isCampaign,
  });

  final Product product;
  final bool inRestaurant;
  final bool isCampaign;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final discount = (product.restaurantDiscount == 0 || isCampaign)
        ? (product.discount ?? 0)
        : (product.restaurantDiscount ?? 0);
    final discountType = (product.restaurantDiscount == 0 || isCampaign)
        ? product.discountType
        : 'percent';
    final hasDiscount = discount > 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: AppRadius.xlAll,
        onTap: () {
          if (product.restaurantStatus == 1) {
            ResponsiveHelper.isMobile(context)
                ? Get.bottomSheet(
                    ProductBottomSheetWidget(
                      product: product,
                      inRestaurantPage: inRestaurant,
                      isCampaign: isCampaign,
                    ),
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                  )
                : Get.dialog(
                    Dialog(
                      child: ProductBottomSheetWidget(
                        product: product,
                        inRestaurantPage: inRestaurant,
                      ),
                    ),
                  );
          } else {
            showCustomSnackBar('item_is_not_available'.tr);
          }
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: AppRadius.xlAll,
            boxShadow: AppShadows.of(context, 3),
          ),
          child: ClipRRect(
            borderRadius: AppRadius.xlAll,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomImageWidget(
                  image: product.imageFullUrl ?? '',
                  fit: BoxFit.cover,
                  isFood: true,
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 1],
                        colors: [
                          Colors.transparent,
                          colors.ink.withValues(alpha: 0.78),
                        ],
                      ),
                    ),
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: AppSpacing.md,
                    left: AppSpacing.md,
                    child: AppTag.discount(
                      label: discountType == 'percent'
                          ? '-${discount.toStringAsFixed(0)}%'
                          : PriceConverter.convertPrice(discount),
                    ),
                  ),
                Positioned(
                  left: AppSpacing.md,
                  right: AppSpacing.md,
                  bottom: AppSpacing.md,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!inRestaurant &&
                          (product.restaurantName?.isNotEmpty ?? false))
                        Text(
                          product.restaurantName!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSm(
                            colors.onAccent.withValues(alpha: 0.75),
                          ),
                        ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        product.name ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.titleSm(colors.onAccent),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        children: [
                          Expanded(
                            child: Row(
                              children: [
                                Text(
                                  PriceConverter.convertPrice(
                                    product.price,
                                    discount: discount,
                                    discountType: discountType,
                                  ),
                                  style: AppTypography.price(colors.onAccent),
                                ),
                                if (hasDiscount) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(
                                    PriceConverter.convertPrice(product.price),
                                    style: AppTypography.priceStrike(
                                      colors.onAccent.withValues(alpha: 0.55),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if ((product.ratingCount ?? 0) > 0)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 14, color: colors.rating),
                                const SizedBox(width: 2),
                                Text(
                                  product.avgRating!.toStringAsFixed(1),
                                  style:
                                      AppTypography.labelSm(colors.onAccent),
                                ),
                              ],
                            ),
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

class _WebRestaurantTile extends StatelessWidget {
  const _WebRestaurantTile({required this.restaurant});
  final Restaurant restaurant;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final open = restaurant.open == 1 && (restaurant.active ?? false);
    final discount = restaurant.discount?.discount ?? 0;
    final discountType = restaurant.discount?.discountType ?? 'percent';
    final cover = (restaurant.coverPhotoFullUrl?.isNotEmpty ?? false)
        ? restaurant.coverPhotoFullUrl!
        : (restaurant.logoFullUrl ?? '');

    return Material(
      color: colors.surface,
      borderRadius: AppRadius.xlAll,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (restaurant.restaurantStatus == 1) {
            Get.toNamed(
              RouteHelper.getRestaurantRoute(restaurant.id),
              arguments: RestaurantScreen(restaurant: restaurant),
            );
          } else {
            showCustomSnackBar('restaurant_is_not_available'.tr);
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CustomImageWidget(
                    image: cover,
                    fit: BoxFit.cover,
                    isRestaurant: true,
                  ),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          colors.ink.withValues(alpha: 0.0),
                          colors.ink.withValues(alpha: 0.4),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: AppSpacing.sm,
                    top: AppSpacing.sm,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: open ? colors.success : colors.danger,
                        borderRadius: AppRadius.pillAll,
                      ),
                      child: Text(
                        open ? 'open_now'.tr : 'closed_now'.tr,
                        style: AppTypography.labelSm(colors.onAccent),
                      ),
                    ),
                  ),
                  if (discount > 0 || (restaurant.freeDelivery ?? false))
                    Positioned(
                      left: AppSpacing.sm,
                      bottom: AppSpacing.sm,
                      child: AppTag.discount(
                        label: (restaurant.freeDelivery ?? false)
                            ? 'free_delivery'.tr
                            : discountType == 'percent'
                                ? '-${discount.toStringAsFixed(0)}%'
                                : PriceConverter.convertPrice(discount),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleSm(colors.ink),
                    ),
                    if (restaurant.address?.isNotEmpty ?? false) ...[
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        restaurant.address!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.bodySm(colors.inkMuted),
                      ),
                    ],
                    const Spacer(),
                    if ((restaurant.ratingCount ?? 0) > 0)
                      Row(
                        children: [
                          Icon(Icons.star_rounded,
                              size: 14, color: colors.rating),
                          const SizedBox(width: 2),
                          Text(
                            '${restaurant.avgRating!.toStringAsFixed(1)} (${restaurant.ratingCount})',
                            style: AppTypography.labelSm(colors.ink),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
