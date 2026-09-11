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

/// Quiet food rail card — matches Home/Menu/Cart language.
/// Image → name → meta → price row. No glass, no gradient, no chip stack.
class NewItemCardWidget extends StatelessWidget {
  final Product product;
  final bool? isBestItem;
  final bool? isPopularNearbyItem;
  final bool isCampaignItem;
  final double width;

  const NewItemCardWidget({
    super.key,
    required this.product,
    this.isBestItem,
    this.isPopularNearbyItem = false,
    this.isCampaignItem = false,
    this.width = 168,
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

    return LayoutBuilder(
      builder: (context, constraints) {
        final hasTightHeight = constraints.hasBoundedHeight &&
            constraints.maxHeight < double.infinity;
        final expandImage = isPopularNearbyItem! || hasTightHeight;
        final footerPad = isPopularNearbyItem! ? AppSpacing.md : AppSpacing.sm;

        Widget nameBlock() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (product.restaurantName?.isNotEmpty ?? false)
                Text(
                  product.restaurantName!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.catalogBodySm(colors.inkMuted),
                ),
              Text(
                product.name ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.catalogTitleSm(colors.ink),
              ),
            ],
          );
        }

        Widget priceAndRating() {
          return Row(
            children: [
              Flexible(
                child: Text(
                  PriceConverter.convertPrice(discountPrice),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelLg(colors.accent),
                ),
              ),
              if (discountPrice < price) ...[
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    PriceConverter.convertPrice(price),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.priceStrike(colors.inkFaint),
                  ),
                ),
              ],
              if ((product.ratingCount ?? 0) > 0) ...[
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.star_rounded, size: 14, color: colors.rating),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    product.avgRating!.toStringAsFixed(1),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.labelMd(colors.ink),
                  ),
                ),
              ],
            ],
          );
        }

        // 1) Title  2) Price + rating  3) Cart bottom-right (width can grow).
        Widget footerContent() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              nameBlock(),
              const SizedBox(height: AppSpacing.xs),
              priceAndRating(),
              const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: _AddControl(
                  product: product,
                  isCampaignItem: isCampaignItem,
                  cartModel: cartModel,
                ),
              ),
            ],
          );
        }

        return SizedBox(
          width:
              cardWidth == double.infinity ? constraints.maxWidth : cardWidth,
          height: hasTightHeight ? constraints.maxHeight : null,
          child: Material(
            color: colors.surface,
            borderRadius: AppRadius.mdAll,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openDetails(context),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: AppRadius.mdAll,
                  border: Border.all(color: colors.line),
                  boxShadow: AppShadows.of(context, 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize:
                      hasTightHeight ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    if (hasTightHeight)
                      Expanded(
                        child: _CardImage(
                          product: product,
                          discount: discount,
                          discountType: discountType,
                          isCampaignItem: isCampaignItem,
                          isAvailable: isAvailable,
                          colors: colors,
                        ),
                      )
                    else
                      AspectRatio(
                        aspectRatio: expandImage ? 1.2 : 1.05,
                        child: _CardImage(
                          product: product,
                          discount: discount,
                          discountType: discountType,
                          isCampaignItem: isCampaignItem,
                          isAvailable: isAvailable,
                          colors: colors,
                        ),
                      ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        footerPad,
                        AppSpacing.sm,
                        footerPad,
                        footerPad,
                      ),
                      child: footerContent(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _openDetails(BuildContext context) {
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
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({
    required this.product,
    required this.discount,
    required this.discountType,
    required this.isCampaignItem,
    required this.isAvailable,
    required this.colors,
  });

  final Product product;
  final double discount;
  final String discountType;
  final bool isCampaignItem;
  final bool isAvailable;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        CustomImageWidget(
          image: product.imageFullUrl ?? '',
          fit: BoxFit.cover,
          isFood: true,
        ),
        if (discount > 0)
          Positioned(
            left: AppSpacing.sm,
            top: AppSpacing.sm,
            child: AppTag.discount(
              label: discountType == 'percent'
                  ? '-${discount.toStringAsFixed(0)}%'
                  : '-${PriceConverter.convertPrice(discount)}',
            ),
          ),
        if (!isCampaignItem)
          Positioned(
            top: AppSpacing.xs,
            right: AppSpacing.xs,
            child: GetBuilder<FavouriteController>(
              builder: (fav) {
                return CustomFavouriteWidget(
                  product: product,
                  isRestaurant: false,
                  isWished: fav.wishProductIdList.contains(product.id),
                );
              },
            ),
          ),
        if (!isAvailable)
          ColoredBox(
            color: colors.overlay,
            child: Center(
              child: Text(
                'not_available_now'.tr,
                style: AppTypography.labelSm(colors.onAccent),
              ),
            ),
          ),
      ],
    );
  }
}

class _AddControl extends StatelessWidget {
  const _AddControl({
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
          return AppQtyStepper(
            quantity: cartQty,
            onDecrement: cartController.isProductUpdating(product.id)
                ? () {}
                : () {
                    final i = cartController.isExistInCart(product.id, null);
                    if (i >= 0 && i < cartController.cartList.length) {
                      final item = cartController.cartList[i];
                      if (item.quantity! > 1) {
                        cartController.setQuantity(false, item, cartIndex: i);
                      } else {
                        cartController.removeFromCart(i);
                      }
                    }
                  },
            onIncrement: cartController.isProductUpdating(product.id)
                ? () {}
                : () {
                    final i = cartController.isExistInCart(product.id, null);
                    if (i >= 0 && i < cartController.cartList.length) {
                      cartController.setQuantity(
                        true,
                        cartController.cartList[i],
                        cartIndex: i,
                      );
                    }
                  },
          );
        }

        return Material(
          color: Theme.of(context).primaryColor,
          elevation: 1,
          shadowColor:
              Theme.of(context).primaryColor.withValues(alpha: 0.35),
          borderRadius: AppRadius.smAll,
          child: InkWell(
            borderRadius: AppRadius.smAll,
            onTap: () => _add(context, productController, cartController),
            child: const SizedBox(
              width: 36,
              height: 36,
              child: Icon(Icons.add_rounded, size: 20, color: Colors.white),
            ),
          ),
        );
      });
    });
  }

  void _add(
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

class NewItemCardShimmer extends StatelessWidget {
  final bool? isPopularNearbyItem;
  const NewItemCardShimmer({super.key, this.isPopularNearbyItem});

  @override
  Widget build(BuildContext context) {
    final count =
        (isPopularNearbyItem == true && ResponsiveHelper.isMobile(context))
            ? 1
            : 5;
    return SizedBox(
      height: 260,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(left: AppSpacing.xl),
        itemCount: count,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, __) => const SizedBox(
          width: 168,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(height: 168, radius: AppRadius.md),
              SizedBox(height: AppSpacing.md),
              AppSkeleton(width: 120, height: 14),
              SizedBox(height: AppSpacing.sm),
              AppSkeleton(width: 80, height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
