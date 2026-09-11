import 'package:toto_user/common/widgets/confirmation_dialog_widget.dart';
import 'package:toto_user/common/widgets/custom_favourite_widget.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/product_bottom_sheet_widget.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/cart/domain/models/cart_model.dart';
import 'package:toto_user/features/checkout/domain/models/place_order_body_model.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/features/favourite/controllers/favourite_controller.dart';
import 'package:toto_user/features/product/controllers/product_controller.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Lumen Atelier food tile — full-bleed media + glass metadata dock.
class ItemCardWidget extends StatelessWidget {
  final Product product;
  final bool? isBestItem;
  final bool? isPopularNearbyItem;
  final bool isCampaignItem;
  final double width;

  const ItemCardWidget({
    super.key,
    required this.product,
    this.isBestItem,
    this.isPopularNearbyItem = false,
    this.isCampaignItem = false,
    this.width = 190,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final price = product.price!;
    final discount = product.discount!;
    final discountType = product.discountType!;
    final discountPrice =
        PriceConverter.convertWithDiscount(price, discount, discountType)!;
    final isAvailable = DateConverter.isAvailable(
      product.availableTimeStarts,
      product.availableTimeEnds,
    );
    final cardWidth = isPopularNearbyItem! ? double.infinity : width;

    final cartModel = CartModel(
      null,
      price,
      discountPrice,
      (price - discountPrice),
      1,
      [],
      [],
      isCampaignItem,
      product,
      [],
      product.cartQuantityLimit,
      [],
    );

    return SizedBox(
      width: cardWidth,
      height: ResponsiveHelper.isDesktop(context) ? 260 : 240,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppRadius.xlAll,
          onTap: () {
            ResponsiveHelper.isMobile(context)
                ? Get.bottomSheet(
                    ProductBottomSheetWidget(
                      product: product,
                      isCampaign: isCampaignItem,
                    ),
                    backgroundColor: Colors.transparent,
                    isScrollControlled: true,
                  )
                : Get.dialog(
                    Dialog(
                      child: ProductBottomSheetWidget(
                        product: product,
                        isCampaign: isCampaignItem,
                      ),
                    ),
                  );
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
                          stops: const [0.35, 1],
                          colors: [
                            Colors.transparent,
                            colors.ink.withValues(alpha: 0.78),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (discount > 0)
                    Positioned(
                      top: AppSpacing.md,
                      left: AppSpacing.md,
                      child: AppTag.discount(
                        label: discountType == 'percent'
                            ? '-${discount.toStringAsFixed(0)}%'
                            : '-${PriceConverter.convertPrice(discount)}',
                      ),
                    ),
                  if (!isCampaignItem)
                    Positioned(
                      top: AppSpacing.md,
                      right: AppSpacing.md,
                      child: GetBuilder<FavouriteController>(
                        builder: (favouriteController) {
                          final wished = favouriteController.wishProductIdList
                              .contains(product.id);
                          return Container(
                            decoration: BoxDecoration(
                              color: colors.glass,
                              shape: BoxShape.circle,
                            ),
                            child: CustomFavouriteWidget(
                              product: product,
                              isRestaurant: false,
                              isWished: wished,
                            ),
                          );
                        },
                      ),
                    ),
                  if (!isAvailable)
                    Positioned.fill(
                      child: ColoredBox(
                        color: colors.overlay,
                        child: Center(
                          child: Text(
                            'not_available_now'.tr,
                            style: AppTypography.labelLg(colors.onAccent),
                          ),
                        ),
                      ),
                    ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (product.restaurantName?.isNotEmpty ?? false)
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
                                          discountPrice),
                                      style:
                                          AppTypography.price(colors.onAccent),
                                    ),
                                    if (discountPrice < price) ...[
                                      const SizedBox(width: AppSpacing.xs),
                                      Text(
                                        PriceConverter.convertPrice(price),
                                        style: AppTypography.priceStrike(
                                          colors.onAccent
                                              .withValues(alpha: 0.55),
                                        ),
                                      ),
                                    ],
                                    if ((product.ratingCount ?? 0) > 0) ...[
                                      const SizedBox(width: AppSpacing.sm),
                                      Icon(Icons.star_rounded,
                                          size: 14, color: colors.rating),
                                      Text(
                                        product.avgRating!.toStringAsFixed(1),
                                        style: AppTypography.labelSm(
                                            colors.onAccent),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              _AddDock(
                                product: product,
                                isCampaignItem: isCampaignItem,
                                cartModel: cartModel,
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
          ),
        ),
      ),
    );
  }
}

class _AddDock extends StatelessWidget {
  const _AddDock({
    required this.product,
    required this.isCampaignItem,
    required this.cartModel,
  });

  final Product product;
  final bool isCampaignItem;
  final CartModel cartModel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GetBuilder<ProductController>(builder: (productController) {
      return GetBuilder<CartController>(builder: (cartController) {
        final cartQty = cartController.cartQuantity(product.id!);

        if (cartQty != 0) {
          return Container(
            decoration: BoxDecoration(
              color: colors.glass,
              borderRadius: AppRadius.pillAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _QtyIcon(
                  icon: cartQty > 1
                      ? Icons.remove_rounded
                      : Icons.delete_outline_rounded,
                  onTap: cartController.isProductUpdating(product.id)
                      ? null
                      : () {
                          final i =
                              cartController.isExistInCart(product.id, null);
                          if (i >= 0 && i < cartController.cartList.length) {
                            final item = cartController.cartList[i];
                            if (item.quantity! > 1) {
                              cartController.setQuantity(false, item,
                                  cartIndex: i);
                            } else {
                              cartController.removeFromCart(i);
                            }
                          }
                        },
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  child: Text(
                    '$cartQty',
                    style: AppTypography.labelLg(colors.ink),
                  ),
                ),
                _QtyIcon(
                  icon: Icons.add_rounded,
                  filled: true,
                  onTap: cartController.isProductUpdating(product.id)
                      ? null
                      : () {
                          final i =
                              cartController.isExistInCart(product.id, null);
                          if (i >= 0 && i < cartController.cartList.length) {
                            cartController.setQuantity(
                              true,
                              cartController.cartList[i],
                              cartIndex: i,
                            );
                          }
                        },
                ),
              ],
            ),
          );
        }

        return Material(
          color: colors.accent,
          borderRadius: AppRadius.smAll,
          child: InkWell(
            borderRadius: AppRadius.smAll,
            onTap: () => _onAdd(context, productController, cartController),
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(Icons.add_rounded, color: colors.onAccent),
            ),
          ),
        );
      });
    });
  }

  void _onAdd(
    BuildContext context,
    ProductController productController,
    CartController cartController,
  ) {
    if (isCampaignItem) {
      ResponsiveHelper.isMobile(context)
          ? Get.bottomSheet(
              ProductBottomSheetWidget(product: product, isCampaign: true),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            )
          : Get.dialog(
              Dialog(
                child: ProductBottomSheetWidget(
                  product: product,
                  isCampaign: true,
                ),
              ),
            );
      return;
    }

    if (product.variations == null ||
        (product.variations != null && product.variations!.isEmpty)) {
      productController.setExistInCart(product);
      final onlineCart = OnlineCart(
        null,
        product.id,
        null,
        product.price!.toString(),
        [],
        1,
        [],
        [],
        [],
        'Food',
        variationOptionIds: [],
      );

      if (cartController
          .existAnotherRestaurantProduct(cartModel.product!.restaurantId)) {
        Get.dialog(
          ConfirmationDialogWidget(
            icon: Images.warning,
            title: 'are_you_sure_to_reset'.tr,
            description: 'if_you_continue'.tr,
            onYesPressed: () {
              cartController.clearCartOnline().then((success) async {
                if (success) {
                  await cartController.addToCartOnline(onlineCart);
                  Get.back();
                }
              });
            },
          ),
          barrierDismissible: false,
        );
      } else {
        cartController.addToCartOnline(onlineCart);
      }
    } else {
      ResponsiveHelper.isMobile(context)
          ? Get.bottomSheet(
              ProductBottomSheetWidget(product: product, isCampaign: false),
              backgroundColor: Colors.transparent,
              isScrollControlled: true,
            )
          : Get.dialog(
              Dialog(
                child: ProductBottomSheetWidget(
                  product: product,
                  isCampaign: false,
                ),
              ),
            );
    }
  }
}

class _QtyIcon extends StatelessWidget {
  const _QtyIcon({required this.icon, this.onTap, this.filled = false});
  final IconData icon;
  final VoidCallback? onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: filled ? colors.accent : Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 32,
          height: 32,
          child: Icon(
            icon,
            size: 16,
            color: filled ? colors.onAccent : colors.ink,
          ),
        ),
      ),
    );
  }
}

class ItemCardShimmer extends StatelessWidget {
  final bool? isPopularNearbyItem;
  const ItemCardShimmer({super.key, this.isPopularNearbyItem});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final count =
        (isPopularNearbyItem! && ResponsiveHelper.isMobile(context)) ? 1 : 5;
    return SizedBox(
      height: 240,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: AppSpacing.xl),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, __) => Container(
          width: ResponsiveHelper.isDesktop(context) ? 200 : 180,
          decoration: BoxDecoration(
            color: colors.line,
            borderRadius: AppRadius.xlAll,
          ),
          child: const AppSkeleton(height: 240, radius: AppRadius.xl),
        ),
      ),
    );
  }
}
