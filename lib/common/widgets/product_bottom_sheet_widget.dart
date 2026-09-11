import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/common/widgets/confirmation_dialog_widget.dart';
import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/common/widgets/custom_favourite_widget.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/discount_tag_widget.dart';
import 'package:toto_user/common/widgets/product_bottom_sheet_shimmer.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/cart/domain/models/cart_model.dart';
import 'package:toto_user/features/checkout/domain/models/place_order_body_model.dart';
import 'package:toto_user/features/favourite/controllers/favourite_controller.dart';
import 'package:toto_user/features/product/controllers/product_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/cart_helper.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/images.dart';

class ProductBottomSheetWidget extends StatefulWidget {
  final Product? product;
  final bool isCampaign;
  final CartModel? cart;
  final int? cartIndex;
  final bool inRestaurantPage;
  final bool? fromReview;
  const ProductBottomSheetWidget({
    super.key,
    required this.product,
    this.isCampaign = false,
    this.cart,
    this.cartIndex,
    this.inRestaurantPage = false,
    this.fromReview = false,
  });

  @override
  State<ProductBottomSheetWidget> createState() =>
      _ProductBottomSheetWidgetState();
}

class _ProductBottomSheetWidgetState extends State<ProductBottomSheetWidget> {
  final ScrollController scrollController = ScrollController();

  Product? product;

  bool _isCartButtonLoading = false;
  bool _isCheckoutButtonLoading = false;

  @override
  void initState() {
    super.initState();
    _initCall();
  }

  Future<void> _initCall() async {
    final controller = Get.find<ProductController>();
    final seed = widget.product;

    if (seed != null) {
      seed.variations ??= [];
      seed.addOns ??= [];
      controller.product = seed;
      try {
        controller.initData(seed, widget.cart);
      } catch (e, s) {
        debugPrint('ProductBottomSheet seed init failed: $e\n$s');
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) controller.update();
      });
    }

    if (widget.fromReview!) {
      product = seed;
      return;
    }

    Product? detailed;
    try {
      detailed = await controller.getProductDetails(
        seed!.id!,
        widget.cart,
        isCampaign: widget.isCampaign,
      );
    } catch (e, s) {
      debugPrint('ProductBottomSheet details failed: $e\n$s');
    }

    product = detailed ?? seed;
    if (product != null) {
      product!.variations ??= [];
      product!.addOns ??= [];
      if (detailed == null && seed != null) {
        controller.product = seed;
        try {
          controller.initData(seed, widget.cart);
        } catch (e, s) {
          debugPrint('ProductBottomSheet fallback init failed: $e\n$s');
        }
        controller.update();
      }
    }

    if (product == null) return;

    String? warning =
        controller.checkOutOfStockVariationSelected(product?.variations);
    if (warning != null) {
      showCustomSnackBar(warning);
    }
    if (product!.variations!.isEmpty) {
      controller.setExistInCart(product!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.92;

    return Container(
      width: 550,
      height: ResponsiveHelper.isMobile(context) ? sheetHeight : null,
      constraints: ResponsiveHelper.isMobile(context)
          ? null
          : BoxConstraints(maxHeight: sheetHeight),
      margin: EdgeInsets.only(top: GetPlatform.isWeb ? 0 : 30),
      decoration: BoxDecoration(
        color: colors.canvas,
        borderRadius: ResponsiveHelper.isMobile(context)
            ? AppRadius.sheetTop
            : AppRadius.xlAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: GetBuilder<ProductController>(
        builder: (productController) {
          product = productController.product ?? widget.product;
          if (product == null) {
            return const ProductBottomSheetShimmer();
          }
          product!.variations ??= [];
          product!.addOns ??= [];

          final double price = product!.price!;
          final double? discount = product!.discount;
          final String? discountType = product!.discountType;
          final double variationPrice =
              _getVariationPrice(product!, productController);
          final bool hasAllRequiredVariations =
              _hasAllRequiredVariations(product!);
          final double basePrice = hasAllRequiredVariations ? 0 : price;
          final double basePriceWithDiscount = hasAllRequiredVariations
              ? 0
              : PriceConverter.convertWithDiscount(
                  price,
                  discount,
                  discountType,
                )!;

          final double priceWithDiscount = basePriceWithDiscount;
          final double addonsCost = _getAddonCost(product!, productController);
          final List<AddOn> addOnIdList =
              _getAddonIdList(product!, productController);
          final List<AddOns> addOnsList =
              _getAddonList(product!, productController);

          final double priceWithAddonsVariationWithDiscount = addonsCost +
              (PriceConverter.convertWithDiscount(
                    variationPrice + basePrice,
                    discount,
                    discountType,
                  )! *
                  productController.quantity!);
          final double priceWithAddonsVariation =
              ((basePrice + variationPrice) * productController.quantity!) +
                  addonsCost;
          final double priceWithVariation = basePrice + variationPrice;
          final bool isAvailable = DateConverter.isAvailable(
            product!.availableTimeStarts,
            product!.availableTimeEnds,
          );

          return Column(
            children: [
              _SheetChrome(
                product: product!,
                isCampaign: widget.isCampaign,
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _HeroCircle(
                        product: product!,
                        discount: discount,
                        discountType: discountType,
                        isCampaign: widget.isCampaign,
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      Text(
                        product!.name ?? '',
                        style: AppTypography.catalogDisplayMd(colors.ink),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _MetaRow(
                        product: product!,
                        inRestaurantPage: widget.inRestaurantPage,
                      ),
                      if (!hasAllRequiredVariations &&
                          (discount == null || discount <= 0) &&
                          !widget.isCampaign &&
                          product!.stockType != 'unlimited' &&
                          product!.itemStock! <= 0) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          ' (${'out_of_stock'.tr})',
                          style: AppTypography.bodySm(colors.danger),
                          textAlign: TextAlign.center,
                        ),
                      ],
                      if (product!.variations != null &&
                          product!.variations!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.x3l),
                        ...List.generate(product!.variations!.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < product!.variations!.length - 1
                                  ? AppSpacing.x2l
                                  : 0,
                            ),
                            child: _VariationSection(
                              product: product!,
                              productController: productController,
                              variationIndex: index,
                              discount: discount,
                              discountType: discountType,
                              price: price,
                              priceWithDiscount: priceWithDiscount,
                            ),
                          );
                        }),
                      ],
                      if (product!.addOns!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.x3l),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'addons'.tr,
                              style: AppTypography.titleSm(colors.ink),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs,
                              ),
                              decoration: BoxDecoration(
                                color: colors.surfaceElevated,
                                borderRadius: AppRadius.xsAll,
                              ),
                              child: Text(
                                'optional'.tr,
                                style: AppTypography.labelSm(colors.inkFaint),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        ...List.generate(product!.addOns!.length, (index) {
                          return Padding(
                            padding: EdgeInsets.only(
                              bottom: index < product!.addOns!.length - 1
                                  ? AppSpacing.sm
                                  : 0,
                            ),
                            child: _AddonTile(
                              product: product!,
                              productController: productController,
                              addonIndex: index,
                            ),
                          );
                        }),
                      ],
                      if (product!.description != null &&
                          product!.description!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.x3l),
                        _InfoSection(
                          title: 'description'.tr,
                          trailing: _VegBadge(product: product!),
                          child: Text(
                            product!.description ?? '',
                            style: AppTypography.catalogBodyMd(colors.inkMuted),
                          ),
                        ),
                      ],
                      if (product!.nutritionsName != null &&
                          product!.nutritionsName!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.x2l),
                        _InfoSection(
                          title: 'nutrition_details'.tr,
                          child: Wrap(
                            spacing: AppSpacing.sm,
                            runSpacing: AppSpacing.sm,
                            children: product!.nutritionsName!
                                .map(
                                  (n) => Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: AppSpacing.md,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.accentSoft,
                                      borderRadius: AppRadius.pillAll,
                                    ),
                                    child: Text(
                                      n,
                                      style:
                                          AppTypography.bodySm(colors.inkMuted),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                      if (product!.allergiesName != null &&
                          product!.allergiesName!.isNotEmpty) ...[
                        const SizedBox(height: AppSpacing.x2l),
                        _InfoSection(
                          title: 'allergic_ingredients'.tr,
                          child: Text(
                            product!.allergiesName!.join(', '),
                            style: AppTypography.bodyMd(colors.inkMuted),
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.x6l),
                    ],
                  ),
                ),
              ),
              _StickyActionBar(
                product: product!,
                productController: productController,
                isCampaign: widget.isCampaign,
                cart: widget.cart,
                isAvailable: isAvailable,
                priceWithVariation: priceWithVariation,
                priceWithDiscount: priceWithDiscount,
                basePrice: basePrice,
                discount: discount,
                discountType: discountType,
                addOnIdList: addOnIdList,
                addOnsList: addOnsList,
                priceWithAddonsVariation: priceWithAddonsVariation,
                priceWithAddonsVariationWithDiscount:
                    priceWithAddonsVariationWithDiscount,
                isCartButtonLoading: _isCartButtonLoading,
                isCheckoutButtonLoading: _isCheckoutButtonLoading,
                onCartPressed: () async {
                  setState(() => _isCartButtonLoading = true);
                  await _onButtonPressed(
                    productController,
                    Get.find<CartController>(),
                    priceWithVariation,
                    priceWithDiscount,
                    basePrice,
                    discount,
                    discountType,
                    addOnIdList,
                    addOnsList,
                    priceWithAddonsVariation,
                  );
                  if (mounted) {
                    setState(() => _isCartButtonLoading = false);
                  }
                },
                onCheckoutPressed: () async {
                  setState(() => _isCheckoutButtonLoading = true);
                  await _onCheckoutButtonPressed(
                    productController,
                    Get.find<CartController>(),
                    priceWithVariation,
                    priceWithDiscount,
                    basePrice,
                    discount,
                    discountType,
                    addOnIdList,
                    addOnsList,
                    priceWithAddonsVariation,
                  );
                  if (mounted) {
                    setState(() => _isCheckoutButtonLoading = false);
                  }
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onButtonPressed(
    ProductController productController,
    CartController cartController,
    double priceWithVariation,
    double priceWithDiscount,
    double basePrice,
    double? discount,
    String? discountType,
    List<AddOn> addOnIdList,
    List<AddOns> addOnsList,
    double priceWithAddonsVariation,
  ) async {
    _processVariationWarning(productController);

    if (productController.canAddToCartProduct) {
      double discountAmount = basePrice -
          PriceConverter.convertWithDiscount(
            basePrice,
            discount,
            discountType,
          )!;

      CartModel cartModel = CartModel(
        null,
        priceWithVariation,
        priceWithDiscount,
        discountAmount,
        productController.quantity,
        addOnIdList,
        addOnsList,
        widget.isCampaign,
        product,
        productController.selectedVariations,
        product!.cartQuantityLimit,
        productController.variationsStock,
      );

      OnlineCart onlineCart = await _processOnlineCart(
        productController,
        cartController,
        addOnIdList,
        addOnsList,
        priceWithAddonsVariation,
      );

      debugPrint('-------checkout online cart body : ${onlineCart.toJson()}');
      debugPrint('-------checkout cart : ${cartModel.toJson()}');

      if (widget.isCampaign) {
        Get.find<CartController>().setNeedExtraPackage(false);
        Get.back();
        if (cartController.existAnotherRestaurantProduct(
          cartModel.product!.restaurantId,
        )) {
          Get.dialog(
            ConfirmationDialogWidget(
              icon: Images.warning,
              title: 'are_you_sure_to_reset'.tr,
              description: 'if_you_continue'.tr,
              onYesPressed: () {
                Get.back();
                cartController.clearCartOnline().then((success) async {
                  if (success) {
                    await cartController.addToCartOnline(
                      onlineCart,
                      existCartData: widget.cart,
                    );
                    Get.toNamed(RouteHelper.getCartRoute());
                  }
                });
              },
            ),
            barrierDismissible: false,
          );
        } else {
          await cartController.addToCartOnline(
            onlineCart,
            existCartData: widget.cart,
          );
          Get.toNamed(RouteHelper.getCartRoute());
        }
      } else {
        await _executeActions(
          cartController,
          productController,
          cartModel,
          onlineCart,
        );
      }
    }
  }

  Future<void> _onCheckoutButtonPressed(
    ProductController productController,
    CartController cartController,
    double priceWithVariation,
    double priceWithDiscount,
    double basePrice,
    double? discount,
    String? discountType,
    List<AddOn> addOnIdList,
    List<AddOns> addOnsList,
    double priceWithAddonsVariation,
  ) async {
    _processVariationWarning(productController);

    if (productController.canAddToCartProduct) {
      double discountAmount = basePrice -
          PriceConverter.convertWithDiscount(
            basePrice,
            discount,
            discountType,
          )!;

      CartModel cartModel = CartModel(
        null,
        priceWithVariation,
        priceWithDiscount,
        discountAmount,
        productController.quantity,
        addOnIdList,
        addOnsList,
        widget.isCampaign,
        product,
        productController.selectedVariations,
        product!.cartQuantityLimit,
        productController.variationsStock,
      );

      OnlineCart onlineCart = await _processOnlineCart(
        productController,
        cartController,
        addOnIdList,
        addOnsList,
        priceWithAddonsVariation,
      );

      debugPrint('-------checkout online cart body : ${onlineCart.toJson()}');
      debugPrint('-------checkout cart : ${cartModel.toJson()}');

      if (widget.isCampaign) {
        Get.find<CartController>().setNeedExtraPackage(false);
        Get.back();
        if (cartController.existAnotherRestaurantProduct(
          cartModel.product!.restaurantId,
        )) {
          Get.dialog(
            ConfirmationDialogWidget(
              icon: Images.warning,
              title: 'are_you_sure_to_reset'.tr,
              description: 'if_you_continue'.tr,
              onYesPressed: () {
                Get.back();
                cartController.clearCartOnline().then((success) async {
                  if (success) {
                    await cartController.addToCartOnline(
                      onlineCart,
                      existCartData: widget.cart,
                    );
                    Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
                  }
                });
              },
            ),
            barrierDismissible: false,
          );
        } else {
          await cartController.addToCartOnline(
            onlineCart,
            existCartData: widget.cart,
          );
          Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
        }
      } else {
        await _executeActionsForCheckout(
          cartController,
          productController,
          cartModel,
          onlineCart,
        );
      }
    }
  }

  Future<void> _executeActionsForCheckout(
    CartController cartController,
    ProductController productController,
    CartModel cartModel,
    OnlineCart onlineCart,
  ) async {
    if (cartController.existAnotherRestaurantProduct(
      cartModel.product!.restaurantId,
    )) {
      Get.dialog(
        ConfirmationDialogWidget(
          icon: Images.warning,
          title: 'are_you_sure_to_reset'.tr,
          description: 'if_you_continue'.tr,
          onYesPressed: () {
            Get.back();
            cartController.clearCartOnline().then((success) async {
              if (success) {
                await cartController.addToCartOnline(
                  onlineCart,
                  existCartData: widget.cart,
                );
                Get.back();
                Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
              }
            });
          },
        ),
        barrierDismissible: false,
      );
    } else {
      await cartController.addToCartOnline(
        onlineCart,
        existCartData: widget.cart,
      );
      Get.back();
      Get.toNamed(RouteHelper.getCheckoutRoute('cart'));
    }
  }

  void _processVariationWarning(ProductController productController) {
    if (product!.variations != null && product!.variations!.isNotEmpty) {
      for (int index = 0; index < product!.variations!.length; index++) {
        if (!product!.variations![index].multiSelect! &&
            product!.variations![index].required! &&
            !productController.selectedVariations[index].contains(true)) {
          showCustomSnackBar(
            '${'choose_a_variation_from'.tr} ${product!.variations![index].name}',
          );
          productController.changeCanAddToCartProduct(false);
          return;
        } else if (product!.variations![index].multiSelect! &&
            (product!.variations![index].required! ||
                productController.selectedVariations[index].contains(true)) &&
            product!.variations![index].min! >
                productController.selectedVariationLength(
                  productController.selectedVariations,
                  index,
                )) {
          showCustomSnackBar(
            '${'you_need_to_select_minimum'.tr} ${product!.variations![index].min} '
            '${'to_maximum'.tr} ${product!.variations![index].max} ${'options_from'.tr} ${product!.variations![index].name} ${'variation'.tr}',
          );
          productController.changeCanAddToCartProduct(false);
          return;
        } else {
          productController.changeCanAddToCartProduct(true);
        }
      }
    } else if (!widget.isCampaign &&
        (product!.variations == null || product!.variations!.isEmpty) &&
        product!.stockType != 'unlimited' &&
        product!.itemStock! <= 0) {
      showCustomSnackBar('product_is_out_of_stock'.tr);
      productController.changeCanAddToCartProduct(false);
      return;
    }
  }

  Future<OnlineCart> _processOnlineCart(
    ProductController productController,
    CartController cartController,
    List<AddOn> addOnIdList,
    List<AddOns> addOnsList,
    double priceWithAddonsVariation,
  ) async {
    List<OrderVariation> variations = CartHelper.getSelectedVariations(
      productVariations: product!.variations,
      selectedVariations: productController.selectedVariations,
    ).$1;
    List<int?> optionsIdList = CartHelper.getSelectedVariations(
      productVariations: product!.variations,
      selectedVariations: productController.selectedVariations,
    ).$2;
    List<int?> listOfAddOnId = CartHelper.getSelectedAddonIds(
      addOnIdList: addOnIdList,
    );
    List<int?> listOfAddOnQty = CartHelper.getSelectedAddonQtnList(
      addOnIdList: addOnIdList,
    );

    OnlineCart onlineCart = OnlineCart(
      (widget.cart != null || productController.cartIndex != -1)
          ? widget.cart?.id ??
              cartController.cartList[productController.cartIndex].id
          : null,
      widget.isCampaign ? null : product!.id,
      widget.isCampaign ? product!.id : null,
      priceWithAddonsVariation.toString(),
      variations,
      productController.quantity,
      listOfAddOnId,
      addOnsList,
      listOfAddOnQty,
      'Food',
      variationOptionIds: optionsIdList,
    );
    return onlineCart;
  }

  Future<void> _executeActions(
    CartController cartController,
    ProductController productController,
    CartModel cartModel,
    OnlineCart onlineCart,
  ) async {
    if (cartController.existAnotherRestaurantProduct(
      cartModel.product!.restaurantId,
    )) {
      Get.dialog(
        ConfirmationDialogWidget(
          icon: Images.warning,
          title: 'are_you_sure_to_reset'.tr,
          description: 'if_you_continue'.tr,
          onYesPressed: () {
            Get.back();
            cartController.clearCartOnline().then((success) async {
              if (success) {
                await cartController.addToCartOnline(
                  onlineCart,
                  existCartData: widget.cart,
                );
              }
            });
          },
        ),
        barrierDismissible: false,
      );
    } else {
      if (widget.cart != null || productController.cartIndex != -1) {
        await cartController.updateCartOnline(
          onlineCart,
          existCartData: widget.cart,
        );
      } else {
        await cartController.addToCartOnline(
          onlineCart,
          existCartData: widget.cart,
        );
      }
    }
  }

  // Kept for cart/pricing parity with legacy sheet.
  // ignore: unused_element
  double _getVariationPriceWithDiscount(
    Product product,
    ProductController productController,
    double? discount,
    String? discountType,
  ) {
    double variationPrice = 0;
    if (product.variations != null) {
      for (int index = 0; index < product.variations!.length; index++) {
        for (int i = 0;
            i < product.variations![index].variationValues!.length;
            i++) {
          if (productController.selectedVariations[index].isNotEmpty &&
              productController.selectedVariations[index][i]!) {
            variationPrice += PriceConverter.convertWithDiscount(
              product.variations![index].variationValues![i].optionPrice!,
              discount,
              discountType,
            )!;
          }
        }
      }
    }
    return variationPrice;
  }

  bool _hasAllRequiredVariations(Product product) {
    if (product.variations == null || product.variations!.isEmpty) {
      return false;
    }
    for (var variation in product.variations!) {
      if (variation.required != true) {
        return false;
      }
    }
    return true;
  }

  double _getVariationPrice(
    Product product,
    ProductController productController,
  ) {
    double variationPrice = 0;
    if (product.variations != null) {
      for (int index = 0; index < product.variations!.length; index++) {
        for (int i = 0;
            i < product.variations![index].variationValues!.length;
            i++) {
          if (productController.selectedVariations[index].isNotEmpty &&
              productController.selectedVariations[index][i]!) {
            variationPrice += PriceConverter.convertWithDiscount(
              product.variations![index].variationValues![i].optionPrice!,
              0,
              'none',
            )!;
          }
        }
      }
    }
    return variationPrice;
  }

  double _getAddonCost(Product product, ProductController productController) {
    double addonsCost = 0;
    for (int index = 0; index < product.addOns!.length; index++) {
      if (productController.addOnActiveList[index]) {
        addonsCost = addonsCost +
            (product.addOns![index].price! *
                productController.addOnQtyList[index]!);
      }
    }
    return addonsCost;
  }

  List<AddOn> _getAddonIdList(
    Product product,
    ProductController productController,
  ) {
    List<AddOn> addOnIdList = [];
    for (int index = 0; index < product.addOns!.length; index++) {
      if (productController.addOnActiveList[index]) {
        addOnIdList.add(
          AddOn(
            id: product.addOns![index].id,
            quantity: productController.addOnQtyList[index],
          ),
        );
      }
    }
    return addOnIdList;
  }

  List<AddOns> _getAddonList(
    Product product,
    ProductController productController,
  ) {
    List<AddOns> addOnsList = [];
    for (int index = 0; index < product.addOns!.length; index++) {
      if (productController.addOnActiveList[index]) {
        addOnsList.add(product.addOns![index]);
      }
    }
    return addOnsList;
  }
}

// ── Private UI widgets ──────────────────────────────────────────────────────

class _SheetChrome extends StatelessWidget {
  const _SheetChrome({
    required this.product,
    required this.isCampaign,
  });

  final Product product;
  final bool isCampaign;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          _ChromeButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: Get.back,
          ),
          const Spacer(),
          if (!isCampaign)
            GetBuilder<FavouriteController>(
              builder: (favouriteController) {
                return _ChromeButton(
                  child: CustomFavouriteWidget(
                    isWished: favouriteController.wishProductIdList
                        .contains(product.id),
                    product: product,
                    isRestaurant: false,
                  ),
                );
              },
            ),
          if (!isCampaign) const SizedBox(width: AppSpacing.sm),
          _ChromeButton(
            icon: Icons.share_outlined,
            onTap: () {
              Share.share(
                '${product.name ?? ''} — ${product.restaurantName ?? ''}',
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ChromeButton extends StatelessWidget {
  const _ChromeButton({
    this.icon,
    this.onTap,
    this.child,
  });

  final IconData? icon;
  final VoidCallback? onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Material(
      color: colors.surface,
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: colors.ink.withValues(alpha: 0.08),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.surface,
            boxShadow: AppShadows.of(context, 1),
          ),
          alignment: Alignment.center,
          child: child ?? Icon(icon, size: 20, color: colors.ink),
        ),
      ),
    );
  }
}

class _HeroCircle extends StatelessWidget {
  const _HeroCircle({
    required this.product,
    required this.discount,
    required this.discountType,
    required this.isCampaign,
  });

  final Product product;
  final double? discount;
  final String? discountType;
  final bool isCampaign;

  static const double _height = 220;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasImage =
        product.imageFullUrl != null && product.imageFullUrl!.isNotEmpty;

    if (!hasImage) return const SizedBox.shrink();

    return GestureDetector(
      onTap: isCampaign
          ? null
          : () => Get.toNamed(RouteHelper.getItemImagesRoute(product)),
      child: Container(
        width: double.infinity,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: AppRadius.lgAll,
          boxShadow: [
            BoxShadow(
              color: colors.ink.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: AppRadius.lgAll,
              child: CustomImageWidget(
                image: product.imageFullUrl!,
                width: double.infinity,
                height: _height,
                fit: BoxFit.cover,
              ),
            ),
            if (discount != null && discount! > 0)
              Positioned(
                top: 12,
                left: 12,
                child: DiscountTagWidget(
                  discount: discount,
                  discountType: discountType,
                  isProductBottomSheet: true,
                  paddingHorizontal: 8,
                  paddingVertical: 4,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.product,
    required this.inRestaurantPage,
  });

  final Product product;
  final bool inRestaurantPage;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: InkWell(
            onTap: () {
              if (inRestaurantPage) {
                Get.back();
              } else {
                Get.offNamed(
                  RouteHelper.getRestaurantRoute(product.restaurantId),
                );
              }
            },
            borderRadius: AppRadius.pillAll,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.storefront_outlined, size: 16, color: colors.accent),
                const SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    product.restaurantName ?? '',
                    style: AppTypography.bodyMd(colors.accent),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (product.avgRating != null && product.avgRating! > 0) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: Text('·', style: AppTypography.bodyMd(colors.inkFaint)),
          ),
          Icon(Icons.star_rounded, size: 18, color: colors.rating),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            product.avgRating!.toStringAsFixed(1),
            style: AppTypography.labelMd(colors.ink),
          ),
          if (product.ratingCount != null && product.ratingCount! > 0) ...[
            const SizedBox(width: AppSpacing.xxs),
            Text(
              '(${product.ratingCount})',
              style: AppTypography.bodySm(colors.inkFaint),
            ),
          ],
        ],
      ],
    );
  }
}

class _VariationSection extends StatelessWidget {
  const _VariationSection({
    required this.product,
    required this.productController,
    required this.variationIndex,
    required this.discount,
    required this.discountType,
    required this.price,
    required this.priceWithDiscount,
  });

  final Product product;
  final ProductController productController;
  final int variationIndex;
  final double? discount;
  final String? discountType;
  final double price;
  final double priceWithDiscount;

  int _selectedCount() {
    int count = 0;
    if (product.variations![variationIndex].required!) {
      for (final value
          in productController.selectedVariations[variationIndex]) {
        if (value == true) count++;
      }
    }
    return count;
  }

  bool _isCompleted(int selectedCount) {
    final variation = product.variations![variationIndex];
    if (!variation.required!) return true;
    final minRequired = variation.multiSelect! ? variation.min! : 1;
    return minRequired <= selectedCount;
  }

  String _helperText(bool isMulti, int selectedCount) {
    final variation = product.variations![variationIndex];
    if (!isMulti) return 'select_one'.tr;
    final range =
        '${'select_minimum'.tr} ${variation.min} ${'and_up_to'.tr} ${variation.max} ${'options'.tr}';
    if (variation.required! && selectedCount > 0) {
      return '$range · $selectedCount/${variation.max}';
    }
    return range;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final variation = product.variations![variationIndex];
    final selectedCount = _selectedCount();
    final completed = _isCompleted(selectedCount);
    final isMulti = variation.multiSelect!;
    final values = variation.variationValues!;
    final needsAttention = variation.required! && !completed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variation.name!,
                    style: AppTypography.catalogTitleSm(colors.ink),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    _helperText(isMulti, selectedCount),
                    style: AppTypography.bodySm(
                      needsAttention ? colors.danger : colors.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            _StatusChip(
              required: variation.required!,
              completed: completed,
              selectedCount: isMulti ? selectedCount : null,
              maxCount: isMulti ? variation.max : null,
            ),
          ],
        ),
        if (needsAttention) ...[
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: LinearProgressIndicator(
              value: isMulti
                  ? (selectedCount /
                          ((variation.min == null || variation.min == 0)
                              ? 1
                              : variation.min!))
                      .clamp(0.0, 1.0)
                  : 0,
              minHeight: 3,
              backgroundColor: colors.line,
              color: colors.danger.withValues(alpha: 0.65),
            ),
          ),
        ] else if (variation.required! && completed) ...[
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: AppRadius.pillAll,
            child: LinearProgressIndicator(
              value: 1,
              minHeight: 3,
              backgroundColor: colors.line,
              color: colors.accent,
            ),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        if (!isMulti)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: values.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.sm,
              crossAxisSpacing: AppSpacing.sm,
              mainAxisExtent: 58,
            ),
            itemBuilder: (context, i) {
              return _VariationOptionCard(
                product: product,
                productController: productController,
                variationIndex: variationIndex,
                optionIndex: i,
                discount: discount,
                discountType: discountType,
                price: price,
                priceWithDiscount: priceWithDiscount,
                horizontal: true,
              );
            },
          )
        else
          DecoratedBox(
            decoration: BoxDecoration(
              color: colors.surfaceElevated,
              borderRadius: AppRadius.mdAll,
              border: Border.all(color: colors.line),
            ),
            child: Column(
              children: List.generate(values.length, (i) {
                return Column(
                  children: [
                    if (i > 0)
                      Divider(height: 1, thickness: 1, color: colors.line),
                    _VariationOptionCard(
                      product: product,
                      productController: productController,
                      variationIndex: variationIndex,
                      optionIndex: i,
                      discount: discount,
                      discountType: discountType,
                      price: price,
                      priceWithDiscount: priceWithDiscount,
                      horizontal: false,
                    ),
                  ],
                );
              }),
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.required,
    required this.completed,
    this.selectedCount,
    this.maxCount,
  });

  final bool required;
  final bool completed;
  final int? selectedCount;
  final int? maxCount;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final String label;
    final Color bg;
    final Color fg;
    IconData? icon;

    if (required) {
      if (completed) {
        label = selectedCount != null
            ? '$selectedCount/${maxCount ?? selectedCount}'
            : 'completed'.tr;
        bg = colors.accentSoft;
        fg = colors.accentHover;
        icon = Icons.check_rounded;
      } else {
        label = 'required'.tr;
        bg = colors.danger.withValues(alpha: 0.1);
        fg = colors.danger;
      }
    } else {
      label = 'optional'.tr;
      bg = colors.surfaceElevated;
      fg = colors.inkFaint;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: fg),
            const SizedBox(width: AppSpacing.xxs),
          ],
          Text(label, style: AppTypography.labelSm(fg)),
        ],
      ),
    );
  }
}

class _VariationOptionCard extends StatelessWidget {
  const _VariationOptionCard({
    required this.product,
    required this.productController,
    required this.variationIndex,
    required this.optionIndex,
    required this.discount,
    required this.discountType,
    required this.price,
    required this.priceWithDiscount,
    required this.horizontal,
  });

  final Product product;
  final ProductController productController;
  final int variationIndex;
  final int optionIndex;
  final double? discount;
  final String? discountType;
  final double price;
  final double priceWithDiscount;
  final bool horizontal;

  void _onTap() {
    productController.setCartVariationIndex(
      variationIndex,
      optionIndex,
      product,
      product.variations![variationIndex].multiSelect!,
    );
    productController.setExistInCartForBottomSheet(
      product,
      productController.selectedVariations,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final variation = product.variations![variationIndex];
    final option = variation.variationValues![optionIndex];
    final selected =
        productController.selectedVariations[variationIndex][optionIndex]!;
    final isOos = option.stockType != 'unlimited' &&
        option.currentStock != null &&
        option.currentStock! <= 0;
    final lowStock =
        selected && productController.quantity == option.currentStock;

    final priceText = variation.required != null && variation.required!
        ? PriceConverter.convertPrice(
            option.optionPrice,
            discount: discount,
            discountType: discountType,
            isVariation: true,
          )
        : '+${PriceConverter.convertPrice(
            option.optionPrice,
            discount: discount,
            discountType: discountType,
            isVariation: true,
          )}';

    if (horizontal) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isOos ? null : _onTap,
          borderRadius: AppRadius.mdAll,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: selected
                  ? colors.accentSoft
                  : isOos
                      ? colors.surfaceElevated
                      : colors.surface,
              borderRadius: AppRadius.mdAll,
              border: Border.all(
                color: selected
                    ? colors.accent
                    : isOos
                        ? colors.line
                        : colors.lineStrong,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? colors.accent : Colors.transparent,
                    border: Border.all(
                      color: selected
                          ? colors.accent
                          : isOos
                              ? colors.lineStrong
                              : colors.inkFaint,
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded,
                          size: 12, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        option.level!.trim(),
                        style: AppTypography.catalogLabelMd(
                          isOos
                              ? colors.inkFaint
                              : selected
                                  ? colors.ink
                                  : colors.inkMuted,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        isOos ? 'out_of_stock'.tr : priceText,
                        style: AppTypography.bodyMd(
                          isOos
                              ? colors.danger
                              : selected
                                  ? colors.accentHover
                                  : colors.inkFaint,
                        ).copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isOos ? null : _onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          color: selected
              ? colors.accentSoft.withValues(alpha: 0.55)
              : Colors.transparent,
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.xsAll,
                  color: selected ? colors.accent : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? colors.accent
                        : isOos
                            ? colors.lineStrong
                            : colors.inkFaint,
                    width: 1.5,
                  ),
                ),
                child: selected
                    ? Icon(Icons.check_rounded,
                        size: 14, color: colors.onAccent)
                    : null,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.level!.trim(),
                      style: AppTypography.catalogBodyMd(
                        isOos
                            ? colors.inkFaint
                            : selected
                                ? colors.ink
                                : colors.inkMuted,
                      ),
                    ),
                    if (isOos)
                      Text(
                        'out_of_stock'.tr,
                        style: AppTypography.labelSm(colors.danger),
                      )
                    else if (lowStock)
                      Text(
                        '${'only'.tr} ${option.currentStock} ${'item_available'.tr}',
                        style: AppTypography.labelSm(colors.accent),
                      ),
                  ],
                ),
              ),
              Text(
                priceText,
                style: AppTypography.labelMd(
                  selected ? colors.accentHover : colors.inkFaint,
                ),
                textDirection: TextDirection.ltr,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AddonTile extends StatelessWidget {
  const _AddonTile({
    required this.product,
    required this.productController,
    required this.addonIndex,
  });

  final Product product;
  final ProductController productController;
  final int addonIndex;

  void _toggle() {
    if (!productController.addOnActiveList[addonIndex]) {
      productController.addAddOn(
        true,
        addonIndex,
        product.addOns![addonIndex].stockType,
        product.addOns![addonIndex].addonStock,
      );
    } else if (productController.addOnQtyList[addonIndex] == 1) {
      productController.addAddOn(
        false,
        addonIndex,
        product.addOns![addonIndex].stockType,
        product.addOns![addonIndex].addonStock,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final addon = product.addOns![addonIndex];
    final active = productController.addOnActiveList[addonIndex];
    final qty = productController.addOnQtyList[addonIndex]!;
    final isOos = addon.stockType != 'unlimited' &&
        addon.addonStock != null &&
        addon.addonStock! <= 0;

    return InkWell(
      onTap: _toggle,
      borderRadius: AppRadius.mdAll,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: active
              ? colors.accentSoft.withValues(alpha: 0.35)
              : colors.surface,
          borderRadius: AppRadius.mdAll,
          border: Border.all(
            color: active ? colors.accent.withValues(alpha: 0.35) : colors.line,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: colors.accentSoft,
              child: Text(
                '${addonIndex + 1}',
                style: AppTypography.labelLg(colors.accent),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    addon.name ?? '',
                    style: AppTypography.catalogBodyMd(
                      active ? colors.ink : colors.inkMuted,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (isOos)
                    Text(
                      ' (${'out_of_stock'.tr})',
                      style: AppTypography.labelSm(colors.danger),
                    ),
                ],
              ),
            ),
            Text(
              addon.price! > 0
                  ? '+${PriceConverter.convertPrice(addon.price)}'
                  : 'free'.tr,
              style: AppTypography.labelMd(
                active ? colors.accent : colors.inkFaint,
              ),
              textDirection: TextDirection.ltr,
            ),
            const SizedBox(width: AppSpacing.sm),
            if (active && qty > 1)
              _MiniStepper(
                quantity: qty,
                onDecrement: () {
                  if (productController.addOnQtyList[addonIndex]! > 1) {
                    productController.setAddOnQuantity(
                      false,
                      addonIndex,
                      addon.stockType,
                      addon.addonStock,
                    );
                  } else {
                    productController.addAddOn(
                      false,
                      addonIndex,
                      addon.stockType,
                      addon.addonStock,
                    );
                  }
                },
                onIncrement: () => productController.setAddOnQuantity(
                  true,
                  addonIndex,
                  addon.stockType,
                  addon.addonStock,
                ),
              )
            else
              Checkbox(
                value: active,
                activeColor: colors.accent,
                checkColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: AppRadius.xsAll),
                onChanged: (_) => _toggle(),
                visualDensity: VisualDensity.compact,
                side: BorderSide(color: colors.lineStrong, width: 1.5),
              ),
          ],
        ),
      ),
    );
  }
}

class _MiniStepper extends StatelessWidget {
  const _MiniStepper({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: 32,
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: colors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onDecrement,
            borderRadius: AppRadius.pillAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Icon(
                quantity > 1 ? Icons.remove : CupertinoIcons.delete,
                size: 16,
                color: quantity > 1 ? colors.accent : colors.danger,
              ),
            ),
          ),
          Text(
            quantity.toString(),
            style: AppTypography.labelMd(colors.ink),
          ),
          InkWell(
            onTap: onIncrement,
            borderRadius: AppRadius.pillAll,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: Icon(Icons.add, size: 16, color: colors.accent),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  const _InfoSection({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTypography.titleSm(colors.ink)),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class _VegBadge extends StatelessWidget {
  const _VegBadge({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final showVeg =
        Get.find<SplashController>().configModel?.toggleVegNonVeg ?? false;
    if (!showVeg) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: colors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: product.veg == 1 ? colors.success : colors.danger,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            product.veg == 1 ? 'veg'.tr : 'non_veg'.tr,
            style: AppTypography.labelSm(colors.inkMuted),
          ),
        ],
      ),
    );
  }
}

class _StickyActionBar extends StatelessWidget {
  const _StickyActionBar({
    required this.product,
    required this.productController,
    required this.isCampaign,
    required this.cart,
    required this.isAvailable,
    required this.priceWithVariation,
    required this.priceWithDiscount,
    required this.basePrice,
    required this.discount,
    required this.discountType,
    required this.addOnIdList,
    required this.addOnsList,
    required this.priceWithAddonsVariation,
    required this.priceWithAddonsVariationWithDiscount,
    required this.isCartButtonLoading,
    required this.isCheckoutButtonLoading,
    required this.onCartPressed,
    required this.onCheckoutPressed,
  });

  final Product product;
  final ProductController productController;
  final bool isCampaign;
  final CartModel? cart;
  final bool isAvailable;
  final double priceWithVariation;
  final double priceWithDiscount;
  final double basePrice;
  final double? discount;
  final String? discountType;
  final List<AddOn> addOnIdList;
  final List<AddOns> addOnsList;
  final double priceWithAddonsVariation;
  final double priceWithAddonsVariationWithDiscount;
  final bool isCartButtonLoading;
  final bool isCheckoutButtonLoading;
  final VoidCallback onCartPressed;
  final VoidCallback onCheckoutPressed;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: AppShadows.of(context, 3),
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(
            ResponsiveHelper.isDesktop(context) ? AppRadius.xl : 0,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: GetBuilder<CartController>(
          builder: (cartController) {
            final isDisabled = ((!product.scheduleOrder! && !isAvailable) ||
                    (isCampaign && !isAvailable)) ||
                (cart != null &&
                    productController.checkOutOfStockVariationSelected(
                          product.variations,
                        ) !=
                        null);
            final isUpdateMode =
                cart != null || productController.cartIndex != -1;

            final String cartLabel;
            if ((!product.scheduleOrder! && !isAvailable) ||
                (isCampaign && !isAvailable)) {
              cartLabel = 'not_available_now'.tr;
            } else if (isCampaign) {
              cartLabel = 'order_now'.tr;
            } else if (isUpdateMode) {
              cartLabel = 'update_in_cart'.tr;
            } else {
              cartLabel =
                  '${'add_to_cart'.tr} - ${PriceConverter.convertPrice(priceWithAddonsVariationWithDiscount)}';
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    _QtyPill(
                      quantity: productController.quantity!,
                      onDecrement: () {
                        if (productController.quantity! > 1) {
                          productController.setQuantity(
                            false,
                            product.cartQuantityLimit,
                            product.stockType,
                            product.itemStock,
                            isCampaign,
                          );
                        }
                      },
                      onIncrement: () => productController.setQuantity(
                        true,
                        product.cartQuantityLimit,
                        product.stockType,
                        product.itemStock,
                        isCampaign,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: CustomButtonWidget(
                        radius: AppRadius.pill,
                        height: 52,
                        isLoading: isCartButtonLoading,
                        buttonText: cartLabel,
                        textColor: Colors.white,
                        onPressed: isDisabled ? null : onCartPressed,
                      ),
                    ),
                  ],
                ),
                if (!isUpdateMode && !isCampaign) ...[
                  const SizedBox(height: AppSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    child: CustomButtonWidget(
                      radius: AppRadius.pill,
                      height: 48,
                      transparent: true,
                      isLoading: isCheckoutButtonLoading,
                      buttonText: 'checkout'.tr,
                      onPressed: isDisabled ? null : onCheckoutPressed,
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

class _QtyPill extends StatelessWidget {
  const _QtyPill({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: colors.surfaceElevated,
        borderRadius: AppRadius.pillAll,
        border: Border.all(color: colors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: quantity > 1 ? onDecrement : null,
            icon: Icon(Icons.remove, size: 20, color: colors.ink),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          AnimatedFlipCounter(
            duration: const Duration(milliseconds: 400),
            value: quantity.toDouble(),
            textStyle: AppTypography.titleSm(colors.ink),
          ),
          IconButton(
            onPressed: onIncrement,
            icon: Icon(Icons.add, size: 20, color: colors.accent),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
