import 'package:get/get_connect/http/src/response/response.dart';
import 'package:toto_user/common/models/online_cart_model.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/features/checkout/domain/models/place_order_body_model.dart';
import 'package:toto_user/features/cart/domain/models/cart_model.dart';
import 'package:toto_user/features/cart/domain/repositories/cart_repository_interface.dart';
import 'package:toto_user/features/cart/domain/services/cart_service_interface.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:get/get_utils/get_utils.dart';

class CartService implements CartServiceInterface {
  final CartRepositoryInterface cartRepositoryInterface;
  CartService({required this.cartRepositoryInterface});

  @override
  Future<Response> addMultipleCartItemOnline(List<OnlineCart> carts) async {
    return cartRepositoryInterface.addMultipleCartItemOnline(carts);
  }

  @override
  List<CartModel> formatOnlineCartToLocalCart(
      {required List<OnlineCartModel> onlineCartModel}) {
    List<CartModel> cartList = [];
    for (OnlineCartModel cart in onlineCartModel) {
      double price = cart.price!;
      double? discount = cart.product!.restaurantDiscount == 0
          ? cart.product!.discount!
          : cart.product!.restaurantDiscount!;
      String? discountType = (cart.product!.restaurantDiscount == 0)
          ? cart.product!.discountType
          : 'percent';
      int? quantity = cart.quantity ?? 1;

      // For 'amount' discount: discount is per unit, so total discount = discount * quantity
      // API price is typically the total (unit price * quantity)
      double discountedPrice;
      if (discountType == 'amount') {
        double totalDiscount = discount! * quantity;
        discountedPrice = price - totalDiscount;
      } else {
        discountedPrice =
            PriceConverter.convertWithDiscount(price, discount, discountType)!;
      }

      double? discountAmount = price - discountedPrice;

      List<List<bool?>> selectedFoodVariations = [];
      List<List<int?>> variationsStock = [];
      List<bool> collapsVariation = [];

      for (int index = 0; index < cart.product!.variations!.length; index++) {
        selectedFoodVariations.add([]);
        collapsVariation.add(true);
        variationsStock.add([]);
        for (int i = 0;
            i < cart.product!.variations![index].variationValues!.length;
            i++) {
          variationsStock[index].add(cart
              .product!.variations![index].variationValues![i].currentStock);
          if (cart.product!.variations![index].variationValues![i].isSelected ??
              false) {
            selectedFoodVariations[index].add(true);
          } else {
            selectedFoodVariations[index].add(false);
          }
        }
      }

      List<AddOn> addOnIdList = [];
      List<AddOns> addOnsList = [];
      for (int index = 0; index < cart.addOnIds!.length; index++) {
        addOnIdList.add(
            AddOn(id: cart.addOnIds![index], quantity: cart.addOnQtys![index]));
        for (int i = 0; i < cart.product!.addOns!.length; i++) {
          if (cart.addOnIds![index] == cart.product!.addOns![i].id) {
            addOnsList.add(AddOns(
                id: cart.product!.addOns![i].id,
                name: cart.product!.addOns![i].name,
                price: cart.product!.addOns![i].price));
          }
        }
      }
      int? quantityLimit = cart.product!.cartQuantityLimit;

      // Check if this cart item is a duplicate of an existing one
      int? duplicateIndex = _findDuplicateCartItem(
          cartList, cart.product!.id, selectedFoodVariations, addOnIdList);

      if (duplicateIndex != null) {
        // Merge with existing item: combine quantities and recalculate prices
        CartModel existingCart = cartList[duplicateIndex];
        int combinedQuantity = (existingCart.quantity ?? 0) + (quantity ?? 0);

        // Calculate unit price from existing cart (which already includes variations and addons)
        // Since both items have same product, variations, and addons, unit price should be consistent
        double unitPrice = existingCart.price! / (existingCart.quantity ?? 1);
        double combinedPrice = unitPrice * combinedQuantity;

        // Use discount from existing cart for consistency
        double? existingDiscount = existingCart.product!.restaurantDiscount == 0
            ? existingCart.product!.discount
            : existingCart.product!.restaurantDiscount;
        String? existingDiscountType =
            (existingCart.product!.restaurantDiscount == 0)
                ? existingCart.product!.discountType
                : 'percent';
        double combinedDiscountedPrice;
        if (existingDiscountType == 'amount') {
          double totalDiscount = (existingDiscount ?? 0) * combinedQuantity;
          combinedDiscountedPrice = combinedPrice - totalDiscount;
        } else {
          combinedDiscountedPrice = PriceConverter.convertWithDiscount(
              combinedPrice, existingDiscount, existingDiscountType)!;
        }
        double combinedDiscountAmount = combinedPrice - combinedDiscountedPrice;

        // Update the existing cart item with merged data
        cartList[duplicateIndex] = CartModel(
          existingCart.id, // Keep the first cart ID
          combinedPrice,
          combinedDiscountedPrice,
          combinedDiscountAmount,
          combinedQuantity,
          existingCart.addOnIds ??
              [], // Keep existing addons (they should be the same)
          existingCart.addOns ?? [],
          existingCart.isCampaign ?? false,
          existingCart.product,
          existingCart.variations ??
              [], // Keep existing variations (they should be the same)
          quantityLimit,
          existingCart.variationsStock ?? [],
        );
      } else {
        // Add as new item
        cartList.add(
          CartModel(
            cart.id,
            price,
            discountedPrice,
            discountAmount,
            quantity,
            addOnIdList,
            addOnsList,
            false,
            cart.product,
            selectedFoodVariations,
            quantityLimit,
            variationsStock,
          ),
        );
      }
    }
    return cartList;
  }

  /// Find duplicate cart item based on product ID, variations, and addons
  /// Returns the index of duplicate item if found, null otherwise
  int? _findDuplicateCartItem(
    List<CartModel> cartList,
    int? productId,
    List<List<bool?>> variations,
    List<AddOn> addOnIds,
  ) {
    for (int i = 0; i < cartList.length; i++) {
      CartModel existingCart = cartList[i];

      // Check if same product
      if (existingCart.product?.id != productId) {
        continue;
      }

      // Check if variations match
      if (!_areVariationsEqual(existingCart.variations, variations)) {
        continue;
      }

      // Check if addons match
      if (!_areAddOnsEqual(existingCart.addOnIds, addOnIds)) {
        continue;
      }

      // Found a duplicate
      return i;
    }
    return null;
  }

  /// Check if two variation lists are equal
  bool _areVariationsEqual(
      List<List<bool?>>? variations1, List<List<bool?>>? variations2) {
    if (variations1 == null && variations2 == null) return true;
    if (variations1 == null || variations2 == null) return false;
    if (variations1.length != variations2.length) return false;

    for (int i = 0; i < variations1.length; i++) {
      if (variations1[i].length != variations2[i].length) return false;
      for (int j = 0; j < variations1[i].length; j++) {
        if (variations1[i][j] != variations2[i][j]) return false;
      }
    }
    return true;
  }

  /// Check if two addon lists are equal (same IDs and quantities)
  bool _areAddOnsEqual(List<AddOn>? addOns1, List<AddOn>? addOns2) {
    if (addOns1 == null && addOns2 == null) return true;
    if (addOns1 == null || addOns2 == null) return false;
    if (addOns1.length != addOns2.length) return false;

    // Sort by ID for comparison
    List<AddOn> sorted1 = List.from(addOns1)
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));
    List<AddOn> sorted2 = List.from(addOns2)
      ..sort((a, b) => (a.id ?? 0).compareTo(b.id ?? 0));

    for (int i = 0; i < sorted1.length; i++) {
      if (sorted1[i].id != sorted2[i].id ||
          sorted1[i].quantity != sorted2[i].quantity) {
        return false;
      }
    }
    return true;
  }

  @override
  void addToSharedPrefCartList(List<CartModel> cartProductList) {
    cartRepositoryInterface.addToSharedPrefCartList(cartProductList);
  }

  @override
  Future<bool> clearCartOnline(String? guestId) async {
    return await cartRepositoryInterface.clearCartOnline(guestId);
  }

  @override
  Future<int> decideProductQuantity(
      List<CartModel> cartList, bool isIncrement, int index) async {
    int quantity = cartList[index].quantity!;
    if (isIncrement) {
      quantity = await _quantityLimitCheck(
          cartList[index].variations!,
          cartList[index].variationsStock!,
          cartList[index].product!.cartQuantityLimit,
          quantity,
          cartList[index].product!.stockType,
          cartList[index].product!.itemStock);
    } else {
      quantity = quantity - 1;
    }
    return quantity;
  }

  Future<int> _quantityLimitCheck(
      List<List<bool?>> selectedVariations,
      List<List<int?>> variationsStock,
      int? cartQuantityLimit,
      int quantity,
      String? stockType,
      int? itemStock) async {
    int qty = quantity;
    int? minimumStock;
    if (await _haveSelectedVariation(selectedVariations) &&
        stockType != 'unlimited') {
      minimumStock =
          _minimumVariationStock(selectedVariations, variationsStock);
    }

    if (stockType != 'unlimited' && itemStock != null && qty >= itemStock) {
      showCustomSnackBar('${'maximum_food_quantity_limit'.tr} $itemStock');
    } else if (minimumStock != null && qty >= minimumStock) {
      showCustomSnackBar(
          '${'maximum_variation_quantity_limit'.tr} $minimumStock');
    } else if (cartQuantityLimit != null &&
        qty >= cartQuantityLimit &&
        cartQuantityLimit != 0) {
      showCustomSnackBar(
          '${'maximum_cart_quantity_limit'.tr} $cartQuantityLimit');
    } else {
      qty = qty + 1;
    }
    return qty;
  }

  Future<bool> _haveSelectedVariation(
      List<List<bool?>> selectedVariations) async {
    bool hasSelected = false;
    for (int i = 0; i < selectedVariations.length; i++) {
      for (int j = 0; j < selectedVariations[i].length; j++) {
        if (selectedVariations[i][j]!) {
          hasSelected = true;
        }
      }
    }
    return hasSelected;
  }

  int _minimumVariationStock(
      List<List<bool?>> selectedVariations, List<List<int?>> variationsStock) {
    List<int> stocks = [];
    for (int i = 0; i < selectedVariations.length; i++) {
      for (int j = 0; j < selectedVariations[i].length; j++) {
        if (selectedVariations[i][j]!) {
          stocks.add(variationsStock[i][j]!);
        }
      }
    }
    int minimumStock = stocks.reduce((curr, next) => curr < next ? curr : next);
    return minimumStock;
  }

  @override
  Future<bool> updateCartQuantityOnline(
      int cartId, double price, int quantity, String? guestId) async {
    return await cartRepositoryInterface.updateCartQuantityOnline(
        cartId, price, quantity, guestId);
  }

  @override
  int isExistInCart(int? productID, int? cartIndex, List<CartModel> cartList) {
    for (int index = 0; index < cartList.length; index++) {
      if (cartList[index].product!.id == productID) {
        if ((index == cartIndex)) {
          return -1;
        } else {
          return index;
        }
      }
    }
    return -1;
  }

  @override
  bool existAnotherRestaurantProduct(
      int? restaurantID, List<CartModel> cartList) {
    for (CartModel cartModel in cartList) {
      if (cartModel.product!.restaurantId != restaurantID) {
        return true;
      }
    }
    return false;
  }

  @override
  int setAvailableIndex(int index, int notAvailableIndex) {
    int finalIndex = notAvailableIndex;
    if (notAvailableIndex == index) {
      finalIndex = -1;
    } else {
      finalIndex = index;
    }
    return finalIndex;
  }

  @override
  int cartQuantity(int productID, List<CartModel> cartList) {
    int quantity = 0;
    for (CartModel cart in cartList) {
      if (cart.product!.id == productID) {
        quantity += cart.quantity!;
      }
    }
    return quantity;
  }

  @override
  Future<Response> addToCartOnline(OnlineCart cart, String? guestId) async {
    return await cartRepositoryInterface.addToCartOnline(cart, guestId);
  }

  @override
  Future<Response> updateCartOnline(OnlineCart cart, int? guestId) async {
    return await cartRepositoryInterface.update(cart.toJson(), guestId);
  }

  @override
  Future<List<OnlineCartModel>> getCartDataOnline(String? id) async {
    return await cartRepositoryInterface.get(id);
  }

  @override
  Future<bool> removeCartItemOnline(int? cartId, String? guestId) async {
    return await cartRepositoryInterface.delete(cartId, guestId: guestId);
  }

  @override
  List<AddOns> prepareAddonList(CartModel cartModel) {
    List<AddOns> addOnList = [];
    for (var addOnId in cartModel.addOnIds!) {
      for (AddOns addOns in cartModel.product!.addOns!) {
        if (addOns.id == addOnId.id) {
          addOnList.add(addOns);
          break;
        }
      }
    }
    return addOnList;
  }

  @override
  double calculateAddonsPrice(
      List<AddOns> addOnList, double price, CartModel cartModel) {
    double addOnsPrice = price;
    for (int index = 0; index < addOnList.length; index++) {
      addOnsPrice = addOnsPrice +
          (addOnList[index].price! * cartModel.addOnIds![index].quantity!);
    }
    return addOnsPrice;
  }

  @override
  double calculateVariationWithoutDiscountPrice(CartModel cartModel,
      double price, double? discount, String? discountType) {
    double variationWithoutDiscountPrice = price;
    if (cartModel.product!.variations!.isNotEmpty) {
      for (int index = 0;
          index < cartModel.product!.variations!.length;
          index++) {
        for (int i = 0;
            i < cartModel.product!.variations![index].variationValues!.length;
            i++) {
          if (cartModel.variations![index][i]!) {
            variationWithoutDiscountPrice +=
                (PriceConverter.convertWithDiscount(
                        cartModel.product!.variations![index]
                            .variationValues![i].optionPrice!,
                        discount,
                        discountType,
                        isVariation: true)! *
                    cartModel.quantity!);
          }
        }
      }
    } else {
      variationWithoutDiscountPrice = 0;
    }
    return variationWithoutDiscountPrice;
  }

  @override
  double calculateVariationPrice(CartModel cartModel, double price) {
    double variationPrice = price;
    if (cartModel.product!.variations!.isNotEmpty) {
      for (int index = 0;
          index < cartModel.product!.variations!.length;
          index++) {
        for (int i = 0;
            i < cartModel.product!.variations![index].variationValues!.length;
            i++) {
          if (cartModel.variations![index][i]!) {
            variationPrice += (cartModel.product!.variations![index]
                    .variationValues![i].optionPrice! *
                cartModel.quantity!);
          }
        }
      }
    } else {
      variationPrice = 0;
    }
    return variationPrice;
  }
}
