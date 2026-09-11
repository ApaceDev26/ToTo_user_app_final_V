import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/common/widgets/confirmation_dialog_widget.dart';
import 'package:toto_user/common/widgets/custom_favourite_widget.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/product_bottom_sheet_widget.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/cart/domain/models/cart_model.dart';
import 'package:toto_user/features/checkout/domain/models/place_order_body_model.dart';
import 'package:toto_user/features/favourite/controllers/favourite_controller.dart';
import 'package:toto_user/features/product/controllers/product_controller.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Vertical best-reviewed card — rating-forward, keeps cart + favourite.
class BestReviewedItemCardWidget extends StatelessWidget {
  final Product product;
  final int rank;
  final double width;

  const BestReviewedItemCardWidget({
    super.key,
    required this.product,
    this.rank = 0,
    this.width = 168,
  });

  static const double cardHeight = 268;

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
    final rating = product.avgRating ?? 0;
    final ratingCount = product.ratingCount ?? 0;

    final cartModel = CartModel(
      null,
      price,
      discountPrice,
      (price - discountPrice),
      1,
      [],
      [],
      false,
      product,
      [],
      product.cartQuantityLimit,
      [],
    );

    return SizedBox(
      width: width,
      height: cardHeight,
      child: Material(
        color: colors.surface,
        elevation: 4,
        shadowColor: colors.ink.withValues(alpha: 0.14),
        borderRadius: AppRadius.mdAll,
        clipBehavior: Clip.none,
        child: InkWell(
          onTap: () => _openDetails(context),
          borderRadius: AppRadius.mdAll,
          child: ClipRRect(
            borderRadius: AppRadius.mdAll,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 148,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CustomImageWidget(
                        image: product.imageFullUrl ?? '',
                        fit: BoxFit.cover,
                        isFood: true,
                      ),
                      if (rank > 0)
                        Positioned(
                          left: AppSpacing.sm,
                          top: AppSpacing.sm,
                          child: Container(
                            width: 28,
                            height: 28,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: colors.accent,
                              borderRadius: AppRadius.smAll,
                            ),
                            child: Text(
                              '#$rank',
                              style: AppTypography.labelSm(colors.surface),
                            ),
                          ),
                        ),
                      Positioned(
                        top: AppSpacing.xs,
                        right: AppSpacing.xs,
                        child: GetBuilder<FavouriteController>(
                          builder: (fav) {
                            return CustomFavouriteWidget(
                              product: product,
                              isRestaurant: false,
                              isWished:
                                  fav.wishProductIdList.contains(product.id),
                            );
                          },
                        ),
                      ),
                      if (rating > 0 || ratingCount > 0)
                        Positioned(
                          left: AppSpacing.sm,
                          bottom: AppSpacing.sm,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xs,
                            ),
                            decoration: BoxDecoration(
                              color: colors.surface.withValues(alpha: 0.94),
                              borderRadius: AppRadius.pillAll,
                              border: Border.all(color: colors.line),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.star_rounded,
                                    size: 14, color: colors.rating),
                                const SizedBox(width: 2),
                                Text(
                                  rating.toStringAsFixed(1),
                                  style: AppTypography.labelMd(colors.ink),
                                ),
                                if (ratingCount > 0)
                                  Text(
                                    ' ($ratingCount)',
                                    style:
                                        AppTypography.labelSm(colors.inkMuted),
                                  ),
                              ],
                            ),
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
                  ),
                ),
                Expanded(
                  child: ColoredBox(
                    color: colors.surface,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.sm,
                        AppSpacing.md,
                        AppSpacing.sm,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.restaurantName?.isNotEmpty ?? false)
                            Text(
                              product.restaurantName!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style:
                                  AppTypography.catalogBodySm(colors.inkMuted),
                            ),
                          Text(
                            product.name ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.catalogTitleSm(colors.ink),
                          ),
                          const Spacer(),
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(
                                      PriceConverter.convertPrice(
                                          discountPrice),
                                      style:
                                          AppTypography.labelLg(colors.accent),
                                    ),
                                    if (discountPrice < price) ...[
                                      const SizedBox(width: AppSpacing.xs),
                                      Flexible(
                                        child: Text(
                                          PriceConverter.convertPrice(price),
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.priceStrike(
                                              colors.inkFaint),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              _AddControl(
                                product: product,
                                cartModel: cartModel,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openDetails(BuildContext context) {
    ResponsiveHelper.isMobile(context)
        ? Get.bottomSheet(
            ProductBottomSheetWidget(product: product),
            backgroundColor: Colors.transparent,
            isScrollControlled: true,
          )
        : Get.dialog(
            Dialog(child: ProductBottomSheetWidget(product: product)),
          );
  }
}

class _AddControl extends StatelessWidget {
  const _AddControl({
    required this.product,
    required this.cartModel,
  });

  final Product product;
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

class BestReviewedItemCardShimmer extends StatelessWidget {
  const BestReviewedItemCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: BestReviewedItemCardWidget.cardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        padding:
            const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (_, __) => const SizedBox(
          width: 168,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(height: 148, radius: AppRadius.md),
              SizedBox(height: AppSpacing.sm),
              AppSkeleton(width: 100, height: 12),
              SizedBox(height: AppSpacing.xs),
              AppSkeleton(width: 140, height: 14),
              Spacer(),
              AppSkeleton(width: 80, height: 14),
            ],
          ),
        ),
      ),
    );
  }
}
