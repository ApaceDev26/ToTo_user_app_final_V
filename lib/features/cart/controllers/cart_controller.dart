import 'package:toto_user/api/api_checker.dart';
import 'package:toto_user/common/models/online_cart_model.dart';
import 'package:toto_user/common/models/restaurant_model.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/common/widgets/cart_snackbar_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/features/checkout/domain/models/place_order_body_model.dart';
import 'package:toto_user/features/cart/domain/models/cart_model.dart';
import 'package:toto_user/features/cart/domain/services/cart_service_interface.dart';
import 'package:toto_user/features/product/controllers/product_controller.dart';
import 'package:toto_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:toto_user/helper/auth_helper.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:toto_user/helper/route_helper.dart';

class CartController extends GetxController implements GetxService {
  final CartServiceInterface cartServiceInterface;

  CartController({required this.cartServiceInterface});

  List<CartModel> _cartList = [];
  List<CartModel> get cartList => _cartList;

  double _subTotal = 0;
  double get subTotal => _subTotal;

  double _itemPrice = 0;
  double get itemPrice => _itemPrice;

  double _itemDiscountPrice = 0;
  double get itemDiscountPrice => _itemDiscountPrice;

  /// Discount computed with same formula as checkout (for cart screen display).
  /// Use this when restaurant is loaded so value matches checkout.
  double get displayDiscount {
    final restaurant = Get.find<RestaurantController>().restaurant;
    if (restaurant == null || _cartList.isEmpty) {
      return _itemDiscountPrice;
    }
    return _getDiscountLikeCheckout(
      restaurant: restaurant,
      price: _itemPrice + _variationPrice,
      addOns: _addOnsPrice,
    );
  }

  double _addOnsPrice = 0;
  double get addOns => _addOnsPrice;

  List<List<AddOns>> _addOnsList = [];
  List<List<AddOns>> get addOnsList => _addOnsList;

  List<bool> _availableList = [];
  List<bool> get availableList => _availableList;

  bool _addCutlery = false;
  bool get addCutlery => _addCutlery;

  int _notAvailableIndex = -1;
  int get notAvailableIndex => _notAvailableIndex;

  List<String> notAvailableList = [
    'Remove it from my cart',
    'I’ll wait until it’s restocked',
    'Please cancel the order',
    'Call me ASAP',
    'Notify me when it’s back'
  ];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  int? _quantityUpdatingProductId;
  int? get quantityUpdatingProductId => _quantityUpdatingProductId;

  // Track products currently being updated to prevent race conditions
  final Set<int> _updatingProductIds = <int>{};

  // Flag to prevent cart refresh while updates are in progress
  bool _isUpdatingCart = false;

  // Track products with detected race conditions (to show loading indicator)
  final Set<int> _raceConditionProductIds = <int>{};

  // Map to store expected quantities for race condition detection
  final Map<int, int> _expectedQuantities = <int, int>{};

  bool _isClearCartLoading = false;
  bool get isClearCartLoading => _isClearCartLoading;

  double _variationPrice = 0;
  double get variationPrice => _variationPrice;

  bool _needExtraPackage = true;
  bool get needExtraPackage => _needExtraPackage;

  bool _isExpanded = true;
  bool get isExpanded => _isExpanded;

  void toggleExtraPackage({bool willUpdate = true}) {
    _needExtraPackage = !_needExtraPackage;
    if (willUpdate) {
      update();
    }
  }

  void setNeedExtraPackage(bool needExtraPackage) {
    _needExtraPackage = needExtraPackage;
    update();
  }

  /// Check if product has variations and all of them are required
  bool _hasAllRequiredVariations(Product product) {
    if (product.variations == null || product.variations!.isEmpty) {
      return false;
    }
    // Check if all variations are required
    for (var variation in product.variations!) {
      if (variation.required != true) {
        return false;
      }
    }
    return true;
  }

  /// Same formula as checkout's _calculateDiscountPrice so cart and checkout show same value.
  double _getDiscountLikeCheckout({
    required Restaurant? restaurant,
    required double price,
    required double addOns,
  }) {
    double discount = 0;
    if (restaurant != null && _cartList.isNotEmpty) {
      for (var cartModel in _cartList) {
        double? dis = (restaurant.discount != null &&
                DateConverter.isAvailable(restaurant.discount!.startTime,
                    restaurant.discount!.endTime))
            ? restaurant.discount!.discount
            : cartModel.product!.discount;
        String? disType = (restaurant.discount != null &&
                DateConverter.isAvailable(restaurant.discount!.startTime,
                    restaurant.discount!.endTime))
            ? 'percent'
            : cartModel.product!.discountType;

        final bool hasAllRequiredVariations =
            _hasAllRequiredVariations(cartModel.product!);
        double d = hasAllRequiredVariations
            ? 0
            : ((cartModel.product!.price! -
                    PriceConverter.convertWithDiscount(
                        cartModel.product!.price!, dis, disType)!) *
                cartModel.quantity!);
        discount = discount + d;
        discount = discount + _getVariationDiscountForItem(restaurant, cartModel);
      }

      if (restaurant.discount != null) {
        if (restaurant.discount!.maxDiscount != 0 &&
            restaurant.discount!.maxDiscount! < discount) {
          discount = restaurant.discount!.maxDiscount!;
        }
        if (restaurant.discount!.minPurchase != 0 &&
            restaurant.discount!.minPurchase! > (price + addOns)) {
          discount = 0;
        }
      }
    }
    return PriceConverter.toFixed(discount);
  }

  /// Same as checkout's _calculateVariationPrice (variation discount part).
  double _getVariationDiscountForItem(Restaurant? restaurant, CartModel? cartModel) {
    double variationPrice = 0;
    double variationDiscount = 0;
    if (restaurant != null && cartModel != null && cartModel.product?.variations != null) {
      double? discount = (restaurant.discount != null &&
              DateConverter.isAvailable(
                  restaurant.discount!.startTime, restaurant.discount!.endTime))
          ? restaurant.discount!.discount
          : cartModel.product!.discount;
      String? discountType = (restaurant.discount != null &&
              DateConverter.isAvailable(
                  restaurant.discount!.startTime, restaurant.discount!.endTime))
          ? 'percent'
          : cartModel.product!.discountType;

      for (int index = 0;
          index < cartModel.product!.variations!.length;
          index++) {
        for (int i = 0;
            i < cartModel.product!.variations![index].variationValues!.length;
            i++) {
          if (cartModel.variations![index][i]!) {
            variationPrice += (PriceConverter.convertWithDiscount(
                    cartModel.product!.variations![index].variationValues![i]
                        .optionPrice!,
                    discount,
                    discountType,
                    isVariation: true)! *
                cartModel.quantity!);
            variationDiscount += (cartModel.product!.variations![index]
                    .variationValues![i].optionPrice! *
                cartModel.quantity!);
          }
        }
      }
    }
    return variationDiscount - variationPrice;
  }

  double calculationCart() {
    _itemPrice = 0;
    _itemDiscountPrice = 0;
    _subTotal = 0;
    _addOnsPrice = 0;
    _availableList = [];
    _addOnsList = [];
    _variationPrice = 0;
    double variationWithoutDiscountPrice = 0;
    double variationPrice = 0;
    for (var cartModel in _cartList) {
      variationWithoutDiscountPrice = 0;
      variationPrice = 0;

      // Use same discount logic as checkout: restaurant time-based discount when available
      final restaurant = Get.find<RestaurantController>().restaurant;
      double? discount = (restaurant != null &&
              restaurant.discount != null &&
              DateConverter.isAvailable(restaurant.discount!.startTime,
                  restaurant.discount!.endTime))
          ? restaurant.discount!.discount
          : (cartModel.product!.restaurantDiscount == 0
              ? cartModel.product!.discount
              : cartModel.product!.restaurantDiscount);
      String? discountType = (restaurant != null &&
              restaurant.discount != null &&
              DateConverter.isAvailable(restaurant.discount!.startTime,
                  restaurant.discount!.endTime))
          ? 'percent'
          : (cartModel.product!.restaurantDiscount == 0
              ? cartModel.product!.discountType
              : 'percent');

      List<AddOns> addOnList = cartServiceInterface.prepareAddonList(cartModel);

      _addOnsList.add(addOnList);
      _availableList.add(DateConverter.isAvailable(
          cartModel.product!.availableTimeStarts,
          cartModel.product!.availableTimeEnds));

      _addOnsPrice = cartServiceInterface.calculateAddonsPrice(
          addOnList, _addOnsPrice, cartModel);

      variationWithoutDiscountPrice =
          cartServiceInterface.calculateVariationWithoutDiscountPrice(
              cartModel, variationWithoutDiscountPrice, discount, discountType);
      variationPrice = cartServiceInterface.calculateVariationPrice(
          cartModel, variationPrice);

      // Check if all variations are required - if so, exclude unit price
      bool hasAllRequiredVariations =
          _hasAllRequiredVariations(cartModel.product!);
      double basePrice = hasAllRequiredVariations
          ? 0
          : (cartModel.product!.price! * cartModel.quantity!);
      double discountPrice = hasAllRequiredVariations
          ? 0
          : (basePrice -
              (PriceConverter.convertWithDiscount(
                      cartModel.product!.price!, discount, discountType)! *
                  cartModel.quantity!));

      _variationPrice += variationPrice;
      _itemPrice = _itemPrice + basePrice;
      _itemDiscountPrice = _itemDiscountPrice +
          discountPrice +
          (variationPrice - variationWithoutDiscountPrice);

      debugPrint(
          '==check : ${_cartList.indexOf(cartModel)} ====> $_itemDiscountPrice = $_itemDiscountPrice + $discountPrice + ($variationPrice - $variationWithoutDiscountPrice)');
    }
    _subTotal =
        (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;

    if (Get.find<RestaurantController>().restaurant != null &&
        Get.find<RestaurantController>().restaurant!.discount != null) {
      if (Get.find<RestaurantController>().restaurant!.discount!.maxDiscount !=
              0 &&
          Get.find<RestaurantController>().restaurant!.discount!.maxDiscount! <
              _itemDiscountPrice) {
        _itemDiscountPrice =
            Get.find<RestaurantController>().restaurant!.discount!.maxDiscount!;
        _subTotal =
            (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;
      }
      if (Get.find<RestaurantController>().restaurant!.discount!.minPurchase !=
              0 &&
          Get.find<RestaurantController>().restaurant!.discount!.minPurchase! >
              _subTotal) {
        _itemDiscountPrice = 0;
        _subTotal =
            (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;
      }
    }

    // When recalculated discount is 0, use actual discount from cart items
    // (e.g. restaurant not loaded yet, or discount came from API)
    double totalDiscountFromItems = 0;
    for (var cartModel in _cartList) {
      totalDiscountFromItems += (cartModel.discountAmount ?? 0);
    }
    if (totalDiscountFromItems > 0 && _itemDiscountPrice == 0) {
      _itemDiscountPrice = totalDiscountFromItems;
      _subTotal =
          (_itemPrice - _itemDiscountPrice) + _addOnsPrice + _variationPrice;
    }
    return _subTotal;
  }

  Future<int?> reorderAddToCart(List<OnlineCart> cartList) async {
    await clearCartList();
    return _addMultipleCartItemOnline(cartList);
  }

  Future<void> setQuantity(bool isIncrement, CartModel cart,
      {int? cartIndex}) async {
    // Get product ID and check if already updating (synchronous check to prevent race condition)
    int productId = cart.product?.id ?? cart.id!;

    // If already updating, ignore this request to prevent conflicts
    // The UI is disabled during updates, so this should rarely happen
    if (_updatingProductIds.contains(productId)) {
      return;
    }

    // Mark as updating immediately (synchronously)
    _updatingProductIds.add(productId);
    _isLoading = true;
    _isUpdatingCart = true;
    _quantityUpdatingProductId = productId;
    update();

    try {
      // Find index by cart ID first (more reliable than using cartIndex or indexOf)
      int index = -1;
      if (cart.id != null) {
        index = _cartList.indexWhere((item) => item.id == cart.id);
      }

      // Fallback to provided cartIndex if ID lookup fails
      if (index < 0 &&
          cartIndex != null &&
          cartIndex >= 0 &&
          cartIndex < _cartList.length) {
        // Verify the cart at this index matches by ID
        if (_cartList[cartIndex].id == cart.id) {
          index = cartIndex;
        }
      }

      // Last resort: use indexOf (but this is less reliable)
      if (index < 0) {
        index = _cartList.indexOf(cart);
      }

      // Validate index
      if (index < 0 || index >= _cartList.length) {
        return; // Invalid index - cart item not found
      }

      // Double-check that the cart at this index matches by ID (if available)
      if (cart.id != null && _cartList[index].id != cart.id) {
        return; // Index mismatch - cart item was moved or removed
      }

      // Read current quantity from the fresh cart item to avoid stale data
      final int currentQuantity = _cartList[index].quantity!;

      // Store expected quantity for race condition detection
      final int expectedQuantity = isIncrement
          ? currentQuantity + 1
          : (currentQuantity > 1 ? currentQuantity - 1 : currentQuantity);
      _expectedQuantities[productId] = expectedQuantity;

      // Use the service method which reads from current cart list state
      // This ensures we always work with the latest quantity
      _cartList[index].quantity = await cartServiceInterface
          .decideProductQuantity(_cartList, isIncrement, index);

      // Only proceed if quantity actually changed
      if (_cartList[index].quantity == currentQuantity) {
        _expectedQuantities.remove(productId);
        return; // Quantity didn't change (likely hit a limit)
      }

      // Recalculate price and discountedPrice for the new quantity so the UI updates immediately
      final int newQuantity = _cartList[index].quantity!;
      final double unitPrice = _cartList[index].price! / currentQuantity;
      final double unitDiscountedPrice =
          (_cartList[index].discountedPrice ?? _cartList[index].price!) /
              currentQuantity;
      final double newPrice = unitPrice * newQuantity;
      final double newDiscountedPrice = unitDiscountedPrice * newQuantity;
      final double newDiscountAmount = newPrice - newDiscountedPrice;
      _cartList[index] = _cartList[index].copyWithPriceAndQuantity(
        price: newPrice,
        discountedPrice: newDiscountedPrice,
        discountAmount: newDiscountAmount,
        quantity: newQuantity,
      );

      cartServiceInterface.addToSharedPrefCartList(_cartList);

      calculationCart();
      update();

      // Update online cart (but don't refresh cart list immediately)
      await updateCartQuantityOnline(_cartList[index].id!,
          _cartList[index].price!, _cartList[index].quantity!,
          skipRefresh: true);
    } finally {
      // Always remove from updating set and reset flags
      _updatingProductIds.remove(productId);
      _isLoading = _updatingProductIds.isNotEmpty;

      // If no more products are updating, refresh cart from server
      if (_updatingProductIds.isEmpty) {
        _isUpdatingCart = false;
        _quantityUpdatingProductId = null;
        // Small delay before refresh to ensure server has processed the update
        await Future.delayed(const Duration(milliseconds: 100));
        // Refresh cart from server to sync with backend
        await getCartDataOnline();

        // Check for race conditions after refresh
        _checkForRaceConditions();
      } else if (_quantityUpdatingProductId == productId) {
        // If we just finished updating this product, clear it
        _quantityUpdatingProductId = null;
      }
      update();
    }
  }

  void removeFromCart(int index) {
    _isLoading = true;
    int cartId = _cartList[index].id!;
    _cartList.removeAt(index);
    update();
    removeCartItemOnline(cartId);
  }

  void removeAddOn(int index, int addOnIndex) {
    _cartList[index].addOnIds!.removeAt(addOnIndex);
    cartServiceInterface.addToSharedPrefCartList(_cartList);
    calculationCart();
    update();
  }

  Future<void> clearCartList() async {
    _cartList = [];
    if (AuthHelper.isLoggedIn() || AuthHelper.isGuestLoggedIn()) {
      await clearCartOnline();
    }
  }

  int isExistInCart(int? productID, int? cartIndex) {
    return cartServiceInterface.isExistInCart(productID, cartIndex, _cartList);
  }

  bool existAnotherRestaurantProduct(int? restaurantID) {
    return cartServiceInterface.existAnotherRestaurantProduct(
        restaurantID, _cartList);
  }

  void updateCutlery({bool isUpdate = true}) {
    _addCutlery = !_addCutlery;
    if (isUpdate) {
      update();
    }
  }

  void setAvailableIndex(int index, {bool willUpdate = true}) {
    _notAvailableIndex =
        cartServiceInterface.setAvailableIndex(index, _notAvailableIndex);
    if (willUpdate) {
      update();
    }
  }

  int cartQuantity(int productID) {
    return cartServiceInterface.cartQuantity(productID, _cartList);
  }

  bool isProductUpdating(int? productId) {
    if (productId == null) return false;
    return _updatingProductIds.contains(productId) ||
        _raceConditionProductIds.contains(productId);
  }

  bool hasRaceCondition(int? productId) {
    if (productId == null) return false;
    return _raceConditionProductIds.contains(productId);
  }

  Future<void> addToCartOnline(OnlineCart onlineCart,
      {CartModel? existCartData, bool fromDirectlyAdd = false}) async {
    _isLoading = true;
    update();
    Response response = await cartServiceInterface.addToCartOnline(
        onlineCart, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());

    if (response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach(
          (cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
          onlineCartModel: onlineCartList));
      calculationCart();
      if (!fromDirectlyAdd) {
        Get.back();
      }
      if (!Get.currentRoute.contains(RouteHelper.restaurant)) {
        showCartSnackBarWidget();
      }
    } else if (response.statusCode == 403 &&
        response.body != null &&
        response.body['errors'] != null &&
        response.body['errors'].isNotEmpty &&
        response.body['errors'][0]['code'] == 'stock_out') {
      showCustomSnackBar(response.body['errors'][0]['message']);
      Get.find<ProductController>()
          .getProductDetails(onlineCart.itemId!, existCartData);
    } else {
      ApiChecker.checkApi(response);
    }

    _isLoading = false;
    update();
  }

  Future<int?> _addMultipleCartItemOnline(List<OnlineCart> cartList) async {
    _isLoading = true;
    update();
    Response response =
        await cartServiceInterface.addMultipleCartItemOnline(cartList);
    if (response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach(
          (cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
          onlineCartModel: onlineCartList));
      calculationCart();
    }
    _isLoading = false;
    update();
    return response.statusCode;
  }

  Future<void> updateCartOnline(OnlineCart onlineCart,
      {CartModel? existCartData}) async {
    _isLoading = true;
    update();
    Response response = await cartServiceInterface.updateCartOnline(onlineCart,
        AuthHelper.isLoggedIn() ? null : int.parse(AuthHelper.getGuestId()));
    if (response.statusCode == 200) {
      List<OnlineCartModel> onlineCartList = [];
      response.body.forEach(
          (cart) => onlineCartList.add(OnlineCartModel.fromJson(cart)));
      _cartList = [];
      _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
          onlineCartModel: onlineCartList));
      calculationCart();
      Get.back();
      if (!Get.currentRoute.contains(RouteHelper.restaurant)) {
        showCartSnackBarWidget();
      }
    } else if (response.statusCode == 403 &&
        response.body != null &&
        response.body['errors'] != null &&
        response.body['errors'].isNotEmpty &&
        response.body['errors'][0]['code'] == 'stock_out') {
      showCustomSnackBar(response.body['errors'][0]['message']);
      Get.find<ProductController>()
          .getProductDetails(onlineCart.itemId!, existCartData);
    } else {
      ApiChecker.checkApi(response);
    }
    _isLoading = false;
    update();
  }

  Future<void> updateCartQuantityOnline(int cartId, double price, int quantity,
      {bool skipRefresh = false}) async {
    bool success = await cartServiceInterface.updateCartQuantityOnline(
        cartId,
        price,
        quantity,
        AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    if (success && !skipRefresh && !_isUpdatingCart) {
      // Only refresh if not currently updating (to avoid conflicts)
      getCartDataOnline();
      calculationCart();
    }
  }

  Future<void> getCartDataOnline() async {
    // Don't refresh if updates are in progress to avoid conflicts
    if (_isUpdatingCart) {
      return;
    }

    _isLoading = true;
    List<OnlineCartModel> onlineCartList =
        await cartServiceInterface.getCartDataOnline(
            AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    _cartList = [];
    _cartList.addAll(cartServiceInterface.formatOnlineCartToLocalCart(
        onlineCartModel: onlineCartList));
    calculationCart();
    _isLoading = false;
    update();
  }

  /// Check for race conditions by comparing expected vs actual quantities
  void _checkForRaceConditions() {
    final List<int> productsToCheck = _expectedQuantities.keys.toList();

    for (final productId in productsToCheck) {
      final int? expectedQty = _expectedQuantities[productId];
      if (expectedQty == null) continue;

      // Find the cart item by product ID
      CartModel? cartItem;
      try {
        cartItem = _cartList
            .firstWhere((item) => (item.product?.id ?? item.id) == productId);
      } catch (e) {
        cartItem = null;
      }

      if (cartItem != null) {
        final int actualQty = cartItem.quantity ?? 0;

        // Detect race condition: expected quantity doesn't match actual
        if (actualQty != expectedQty) {
          debugPrint(
              'Race condition detected for product $productId: expected $expectedQty, got $actualQty');
          _raceConditionProductIds.add(productId);

          // Show loading indicator for 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            _raceConditionProductIds.remove(productId);
            _expectedQuantities.remove(productId);
            update();
          });
        } else {
          // No race condition, remove from expected map
          _expectedQuantities.remove(productId);
        }
      } else {
        // Cart item not found, remove from expected map
        _expectedQuantities.remove(productId);
      }
    }

    if (_raceConditionProductIds.isNotEmpty) {
      update(); // Update UI to show loading indicator
    }
  }

  Future<bool> removeCartItemOnline(int cartId) async {
    _isLoading = true;
    update();
    bool isSuccess = await cartServiceInterface.removeCartItemOnline(
        cartId, AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    getCartDataOnline();
    _isLoading = false;
    update();
    return isSuccess;
  }

  Future<bool> clearCartOnline() async {
    _isLoading = true;
    _isClearCartLoading = true;
    update();
    bool success = await cartServiceInterface.clearCartOnline(
        AuthHelper.isLoggedIn() ? null : AuthHelper.getGuestId());
    if (success) {
      getCartDataOnline();
    }
    _isLoading = false;
    _isClearCartLoading = false;
    update();
    return success;
  }

  void setExpanded(bool setExpand) {
    _isExpanded = setExpand;
    update();
  }
}
