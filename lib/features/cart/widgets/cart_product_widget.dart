import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:toto_user/common/widgets/custom_ink_well_widget.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/language/controllers/localization_controller.dart';
import 'package:toto_user/features/cart/domain/models/cart_model.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/helper/cart_helper.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/styles.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/product_bottom_sheet_widget.dart';
import 'package:toto_user/common/widgets/quantity_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get/get.dart';

class CartProductWidget extends StatelessWidget {
  final CartModel cart;
  final int cartIndex;
  final List<AddOns> addOns;
  final bool isAvailable;
  final bool isRestaurantOpen;
  const CartProductWidget(
      {super.key,
      required this.cart,
      required this.cartIndex,
      required this.isAvailable,
      required this.addOns,
      required this.isRestaurantOpen});

  @override
  Widget build(BuildContext context) {
    String addOnText = CartHelper.setupAddonsText(cart: cart) ?? '';
    String variationText = CartHelper.setupVariationText(cart: cart);

    double? discount = cart.product!.discount;
    String? discountType = cart.product!.discountType;

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.only(
              bottom: ResponsiveHelper.isDesktop(context)
                  ? Dimensions.paddingSizeExtraSmall
                  : Dimensions.paddingSizeDefault),
          child: GetBuilder<CartController>(builder: (cartController) {
            return Slidable(
              key: UniqueKey(),
              enabled: !cartController.isLoading,
              endActionPane: ActionPane(
                motion: const ScrollMotion(),
                extentRatio: 0.2,
                children: [
                  SlidableAction(
                    onPressed: (context) =>
                        cartController.removeFromCart(cartIndex),
                    backgroundColor: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(
                            Get.find<LocalizationController>().isLtr
                                ? Dimensions.radiusDefault
                                : 0),
                        left: Radius.circular(
                            Get.find<LocalizationController>().isLtr
                                ? 0
                                : Dimensions.radiusDefault)),
                    foregroundColor: Colors.white,
                    icon: CupertinoIcons.trash,
                  ),
                ],
              ),
              child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius:
                        BorderRadius.circular(Dimensions.radiusDefault),
                    boxShadow: ResponsiveHelper.isDesktop(context)
                        ? []
                        : [
                            BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 5,
                                spreadRadius: 1)
                          ],
                  ),
                  child: CustomInkWellWidget(
                    onTap: () {
                      ResponsiveHelper.isMobile(context)
                          ? showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (con) => ProductBottomSheetWidget(
                                  product: cart.product,
                                  cartIndex: cartIndex,
                                  cart: cart),
                            ).then(
                              (value) => Get.find<CartController>()
                                  .getCartDataOnline(),
                            )
                          : showDialog(
                              context: context,
                              builder: (con) => Dialog(
                                    child: ProductBottomSheetWidget(
                                        product: cart.product,
                                        cartIndex: cartIndex,
                                        cart: cart),
                                  )).then((value) =>
                              Get.find<CartController>().getCartDataOnline());
                    },
                    radius: Dimensions.radiusDefault,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: Dimensions.paddingSizeExtraSmall,
                          horizontal: Dimensions.paddingSizeExtraSmall),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                cart.product!.imageFullUrl != null
                                    ? Stack(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                Dimensions.radiusDefault),
                                            child: CustomImageWidget(
                                              image:
                                                  '${cart.product!.imageFullUrl}',
                                              height: 60,
                                              width: 60,
                                              fit: BoxFit.cover,
                                              isFood: true,
                                            ),
                                          ),
                                          isAvailable
                                              ? const SizedBox()
                                              : Positioned(
                                                  top: 0,
                                                  left: 0,
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Container(
                                                    alignment: Alignment.center,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius
                                                            .circular(Dimensions
                                                                .radiusSmall),
                                                        color: Colors.black
                                                            .withValues(
                                                                alpha: 0.6)),
                                                    child: Text(
                                                        'not_available_now_break'
                                                            .tr,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: robotoRegular
                                                            .copyWith(
                                                          color: Colors.white,
                                                          fontSize: 8,
                                                        )),
                                                  ),
                                                ),
                                        ],
                                      )
                                    : const SizedBox(),
                                SizedBox(
                                    width: cart.product!.imageFullUrl != null
                                        ? Dimensions.paddingSizeSmall
                                        : 0),
                                Expanded(
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Row(children: [
                                          Flexible(
                                            child: Text(
                                              cart.product!.name!,
                                              style: robotoMedium.copyWith(
                                                  fontSize:
                                                      Dimensions.fontSizeSmall),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          const SizedBox(
                                              width: Dimensions
                                                  .paddingSizeExtraSmall),

                                          // CustomAssetImageWidget(
                                          //   cart.product!.veg == 0 ? Images.nonVegImage : Images.vegImage,
                                          //   height: 11, width: 11,
                                          // ),

                                          // SizedBox(width: cart.product!.isRestaurantHalalActive! && cart.product!.isHalalFood! ? Dimensions.paddingSizeExtraSmall : 0),

                                          // cart.product!.isRestaurantHalalActive! && cart.product!.isHalalFood! ? const CustomAssetImageWidget(
                                          //  Images.halalIcon, height: 13, width: 13) : const SizedBox(),
                                        ]),
                                        const SizedBox(height: 5),
                                        GetBuilder<CartController>(
                                            builder: (cartController) {
                                          // Find the current cart item by ID to ensure we have the latest data
                                          final int? cartId = cart.id;
                                          final CartModel? currentCart =
                                              cartId != null
                                                  ? cartController.cartList
                                                      .firstWhereOrNull(
                                                          (item) =>
                                                              item.id == cartId)
                                                  : null;

                                          // Fallback to index if ID lookup fails (for backward compatibility)
                                          final CartModel? fallbackCart =
                                              (cartIndex >= 0 &&
                                                      cartIndex <
                                                          cartController
                                                              .cartList.length)
                                                  ? cartController
                                                      .cartList[cartIndex]
                                                  : null;

                                          final CartModel? displayCartForPrice =
                                              currentCart ?? fallbackCart;

                                          // CartModel.price and discountedPrice from API are already totals (unit price * quantity)
                                          // Do NOT multiply by quantity - that causes 10x error when adding from bottom sheet with qty > 1
                                          final double totalPrice =
                                              displayCartForPrice
                                                      ?.discountedPrice ??
                                                  cart.discountedPrice ??
                                                  0.0;
                                          final double originalTotalPrice =
                                              displayCartForPrice?.price ??
                                                  cart.price ??
                                                  0.0;

                                          return Wrap(
                                            children: [
                                              Text(
                                                PriceConverter.convertPrice(
                                                    totalPrice),
                                                style: robotoMedium.copyWith(
                                                    fontSize: Dimensions
                                                        .fontSizeSmall),
                                                textDirection:
                                                    TextDirection.ltr,
                                              ),
                                              SizedBox(
                                                  width: discount! > 0
                                                      ? Dimensions
                                                          .paddingSizeExtraSmall
                                                      : 0),
                                              discount > 0
                                                  ? Text(
                                                      PriceConverter.convertPrice(
                                                          originalTotalPrice),
                                                      textDirection:
                                                          TextDirection.ltr,
                                                      style: robotoMedium.copyWith(
                                                          color: Theme.of(
                                                                  context)
                                                              .disabledColor,
                                                          fontSize: Dimensions
                                                              .fontSizeSmall,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough),
                                                    )
                                                  : const SizedBox(),
                                            ],
                                          );
                                        }),
                                        addOnText.isNotEmpty
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: Dimensions
                                                        .paddingSizeExtraSmall),
                                                child: Row(children: [
                                                  Text('${'addons'.tr}: ',
                                                      style: robotoMedium.copyWith(
                                                          fontSize: Dimensions
                                                              .fontSizeSmall)),
                                                  Flexible(
                                                      child: Text(
                                                    addOnText,
                                                    style:
                                                        robotoRegular.copyWith(
                                                            fontSize: Dimensions
                                                                .fontSizeSmall,
                                                            color: Theme.of(
                                                                    context)
                                                                .disabledColor),
                                                  )),
                                                ]),
                                              )
                                            : const SizedBox(),
                                        variationText.isNotEmpty
                                            ? Padding(
                                                padding: const EdgeInsets.only(
                                                    top: Dimensions
                                                        .paddingSizeExtraSmall),
                                                child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          '${'variations'.tr}: ',
                                                          style: robotoMedium
                                                              .copyWith(
                                                                  fontSize:
                                                                      Dimensions
                                                                          .fontSizeExtraSmall)),
                                                    ]),
                                              )
                                            : const SizedBox(),
                                      ]),
                                ),
                                GetBuilder<CartController>(
                                    builder: (cartController) {
                                  // Find the current cart item by ID to ensure we have the latest data
                                  final int? cartId = cart.id;
                                  final CartModel? currentCart = cartId != null
                                      ? cartController.cartList
                                          .firstWhereOrNull(
                                              (item) => item.id == cartId)
                                      : null;

                                  // Fallback to index if ID lookup fails (for backward compatibility)
                                  final CartModel? fallbackCart = (cartIndex >=
                                              0 &&
                                          cartIndex <
                                              cartController.cartList.length)
                                      ? cartController.cartList[cartIndex]
                                      : null;

                                  final CartModel? displayCart =
                                      currentCart ?? fallbackCart;

                                  if (displayCart == null) {
                                    // Cart item not found, return empty widget
                                    return const SizedBox.shrink();
                                  }

                                  final bool isQuantityUpdating =
                                      cartController.isProductUpdating(
                                          displayCart.product?.id ??
                                              displayCart.id);

                                  final bool hasRaceCondition =
                                      cartController.hasRaceCondition(
                                          displayCart.product?.id ??
                                              displayCart.id);

                                  return Padding(
                                    padding: EdgeInsets.only(
                                        top: displayCart
                                                    .product!.imageFullUrl ==
                                                null
                                            ? Dimensions.paddingSizeSmall - 2
                                            : Dimensions.paddingSizeDefault +
                                                2),
                                    child: Row(children: [
                                      QuantityButton(
                                        onTap: isQuantityUpdating
                                            ? () {}
                                            : () {
                                                // Find fresh cart item by ID to ensure we have latest quantity
                                                if (cartId != null) {
                                                  final int freshIndex =
                                                      cartController.cartList
                                                          .indexWhere((item) =>
                                                              item.id ==
                                                              cartId);

                                                  if (freshIndex >= 0 &&
                                                      freshIndex <
                                                          cartController
                                                              .cartList
                                                              .length) {
                                                    final CartModel freshCart =
                                                        cartController.cartList[
                                                            freshIndex];

                                                    if (freshCart.quantity! >
                                                        1) {
                                                      cartController
                                                          .setQuantity(
                                                              false, freshCart,
                                                              cartIndex:
                                                                  freshIndex);
                                                    } else {
                                                      cartController
                                                          .removeFromCart(
                                                              freshIndex);
                                                    }
                                                  }
                                                }
                                              },
                                        isIncrement: false,
                                        showRemoveIcon:
                                            displayCart.quantity! == 1,
                                        color: isQuantityUpdating
                                            ? Theme.of(context).disabledColor
                                            : null,
                                      ),
                                      // Show loading indicator if race condition detected, otherwise show counter
                                      // hasRaceCondition
                                      //     ? SizedBox(
                                      //         width: 22,
                                      //         height: 22,
                                      //         child: CircularProgressIndicator(
                                      //           strokeWidth: 2,
                                      //           valueColor:
                                      //               AlwaysStoppedAnimation<
                                      //                       Color>(
                                      //                   Theme.of(context)
                                      //                       .primaryColor),
                                      //         ),
                                      //       )
                                      //     :
                                      AnimatedFlipCounter(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        value: displayCart.quantity!.toDouble(),
                                        textStyle: robotoMedium.copyWith(
                                            fontSize:
                                                Dimensions.fontSizeExtraLarge),
                                      ),
                                      QuantityButton(
                                        onTap: isQuantityUpdating
                                            ? () {}
                                            : () {
                                                // Find fresh cart item by ID to ensure we have latest data
                                                if (cartId != null) {
                                                  final int freshIndex =
                                                      cartController.cartList
                                                          .indexWhere((item) =>
                                                              item.id ==
                                                              cartId);

                                                  if (freshIndex >= 0 &&
                                                      freshIndex <
                                                          cartController
                                                              .cartList
                                                              .length) {
                                                    final CartModel freshCart =
                                                        cartController.cartList[
                                                            freshIndex];

                                                    cartController.setQuantity(
                                                        true, freshCart,
                                                        cartIndex: freshIndex);
                                                  }
                                                }
                                              },
                                        isIncrement: true,
                                        color: isQuantityUpdating
                                            ? Theme.of(context).disabledColor
                                            : null,
                                      ),
                                    ]),
                                  );
                                }),
                              ]),
                          ResponsiveHelper.isDesktop(context)
                              ? const Padding(
                                  padding: EdgeInsets.only(
                                      top: Dimensions.paddingSizeSmall),
                                  child: Divider(),
                                )
                              : const SizedBox(),
                          variationText.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      top: Dimensions.paddingSizeExtraSmall),
                                  child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(width: 70),
                                        Flexible(
                                            child: Text(
                                          variationText,
                                          style: robotoRegular.copyWith(
                                              fontSize:
                                                  Dimensions.fontSizeSmall,
                                              color:
                                                  Theme.of(context).hintColor),
                                        )),
                                      ]),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  )),
            );
          }),
        ),
        isRestaurantOpen
            ? const SizedBox()
            : Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                top: 0,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        ResponsiveHelper.isDesktop(context)
                            ? 0
                            : Dimensions.radiusDefault),
                    color: Theme.of(context).disabledColor.withValues(
                        alpha: ResponsiveHelper.isDesktop(context) ? 0.1 : 0.3),
                  ),
                  margin: EdgeInsets.only(
                      bottom: ResponsiveHelper.isDesktop(context)
                          ? 0
                          : Dimensions.paddingSizeDefault),
                ),
              )
      ],
    );
  }
}
