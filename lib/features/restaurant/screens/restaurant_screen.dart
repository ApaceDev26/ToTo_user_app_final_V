import 'dart:async';

import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/coupon/controllers/coupon_controller.dart';
import 'package:toto_user/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:toto_user/features/home/widgets/restaurant_page_new_item_card_widget.dart';
import 'package:toto_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:toto_user/common/models/restaurant_model.dart';
import 'package:toto_user/features/category/controllers/category_controller.dart';
import 'package:toto_user/features/restaurant/widgets/restaurant_info_section_widget.dart';
import 'package:toto_user/features/restaurant/widgets/restaurant_screen_shimmer_widget.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/util/styles.dart';
import 'package:toto_user/common/widgets/bottom_cart_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/paginated_list_view_widget.dart';
import 'package:toto_user/common/widgets/product_view_widget.dart';
import 'package:toto_user/common/widgets/grouped_product_view_widget.dart';
import 'package:toto_user/common/widgets/veg_filter_widget.dart';
import 'package:toto_user/common/widgets/web_menu_bar.dart';
import 'package:toto_user/helper/in_app_messaging_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RestaurantScreen extends StatefulWidget {
  final Restaurant? restaurant;
  final String slug;
  final bool fromDineIn;
  const RestaurantScreen(
      {super.key,
      required this.restaurant,
      this.slug = '',
      this.fromDineIn = false});

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  final ScrollController scrollController = ScrollController();
  final ScrollController categoryTabsScrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int _lastUpdatedCategoryIndex = -1;
  final Map<int, GlobalKey> _categoryKeys = {};
  final Map<int, GlobalKey> _categoryTabKeys = {};
  bool _isManuallyScrolling = false;
  DateTime? _lastManualScrollTime;
  Timer? _scrollDebounceTimer;
  bool _didApplyInitialVisibleCategory = false;

  @override
  void initState() {
    super.initState();

    // Must not call GetX update() during the first build — that aborts product loading.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _initDataCall();
    });

    // Trigger in-app messages for restaurant screen
    Future.delayed(const Duration(milliseconds: 800), () {
      InAppMessagingHelper.triggerForScreen('restaurant');
      // Also check for immediate messages
      InAppMessagingHelper.checkForImmediateMessages();
    });

    // Add scroll listener for auto-highlighting categories
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      scrollController.addListener(_onScroll);
    });
  }

  @override
  void dispose() {
    _scrollDebounceTimer?.cancel();
    scrollController.removeListener(_onScroll);
    scrollController.dispose();
    categoryTabsScrollController.dispose();
    super.dispose();
  }

  void _scrollActiveCategoryTabIntoView(RestaurantController restController) {
    final index = restController.categoryIndex;
    if (index < 0 ||
        index >= restController.categoryList!.length ||
        !_categoryTabKeys.containsKey(index)) return;
    final key = _categoryTabKeys[index]!;
    if (key.currentContext == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted ||
          key.currentContext == null ||
          !categoryTabsScrollController.hasClients) return;
      final renderObject = key.currentContext!.findRenderObject();
      if (renderObject == null) return;
      // Use the tabs' ScrollController so we scroll only the horizontal tabs,
      // not the main body
      categoryTabsScrollController.position.ensureVisible(
        renderObject,
        alignment: 0.5,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  List<int> _getVisibleCategoryIndices(RestaurantController restController) {
    final categories = restController.categoryList;
    if (categories == null || categories.isEmpty) {
      return [];
    }

    // Show only categories that have at least one active product.
    final products = restController.restaurantProducts;
    if (products == null) {
      return [];
    }

    final productCategoryIds = products
        .where((product) => product.categoryId != null)
        .map((product) => product.categoryId!)
        .toSet();

    final visibleIndices = <int>[];
    for (int index = 0; index < categories.length; index++) {
      final categoryId = categories[index].id;
      if (categoryId != null && productCategoryIds.contains(categoryId)) {
        visibleIndices.add(index);
      }
    }
    return visibleIndices;
  }

  void _syncCategoryIndexWithVisibleCategories(
      RestaurantController restController) {
    if (restController.restaurantProducts == null) {
      _didApplyInitialVisibleCategory = false;
      return;
    }

    final visibleCategoryIndices = _getVisibleCategoryIndices(restController);
    if (visibleCategoryIndices.isEmpty) return;

    final firstVisibleCategoryIndex = visibleCategoryIndices.first;
    final shouldForceInitialSelection = !_didApplyInitialVisibleCategory;
    final currentSelectionIsHidden =
        !visibleCategoryIndices.contains(restController.categoryIndex);
    if (shouldForceInitialSelection || currentSelectionIsHidden) {
      _didApplyInitialVisibleCategory = true;
      _lastUpdatedCategoryIndex = firstVisibleCategoryIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        restController.updateCategoryIndexFromScroll(firstVisibleCategoryIndex);
        _scrollActiveCategoryTabIntoView(restController);
      });
    }
  }

  void _onScroll() {
    // Don't auto-update if we just manually scrolled
    if (_isManuallyScrolling ||
        (_lastManualScrollTime != null &&
            DateTime.now().difference(_lastManualScrollTime!).inMilliseconds <
                500)) {
      return;
    }

    // Cancel any pending debounce timer and start a new one
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 100), () {
      if (!mounted || !scrollController.hasClients) return;

      // Check again after delay
      if (_isManuallyScrolling ||
          (_lastManualScrollTime != null &&
              DateTime.now().difference(_lastManualScrollTime!).inMilliseconds <
                  500)) {
        return;
      }

      final restController = Get.find<RestaurantController>();

      if (restController.isSearching ||
          restController.restaurantProducts == null ||
          restController.restaurantProducts!.isEmpty ||
          restController.categoryList == null ||
          restController.categoryList!.isEmpty) {
        return;
      }

      _updateCategoryFromScroll(restController);
    });
  }

  void _scrollToCategory(int index, RestaurantController restController) {
    if (restController.categoryList == null ||
        index < 0 ||
        index >= restController.categoryList!.length) {
      return;
    }

    final category = restController.categoryList![index];
    if (category.id == null) return;

    // Check if this category actually has products (exists in grouped view)
    if (!_categoryKeys.containsKey(category.id)) {
      return; // Category doesn't have products
    }

    // Set flag to prevent auto-update during scroll
    _isManuallyScrolling = true;
    _lastManualScrollTime = DateTime.now();

    // Update category index
    restController.updateCategoryIndexFromScroll(index);
    _scrollActiveCategoryTabIntoView(restController);

    final categoryKey = _categoryKeys[category.id];
    if (categoryKey?.currentContext != null) {
      // Get the category's render box to calculate its position
      final RenderBox? renderBox =
          categoryKey!.currentContext!.findRenderObject() as RenderBox?;

      if (renderBox != null && scrollController.hasClients) {
        // Get the category's current screen position
        final position = renderBox.localToGlobal(Offset.zero);

        // Calculate where we need to scroll to
        // Account for the sticky header (approximately 250px from top)
        const stickyHeaderOffset = 250.0;

        // Calculate the target scroll offset
        final currentOffset = scrollController.offset;
        final categoryScreenY = position.dy;

        // The target is: scroll so that the category header is just below the sticky header
        final targetOffset =
            currentOffset + categoryScreenY - stickyHeaderOffset;

        scrollController
            .animateTo(
          targetOffset.clamp(0.0, scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        )
            .then((_) {
          // Re-enable auto-update after scroll completes
          Future.delayed(const Duration(milliseconds: 500), () {
            _isManuallyScrolling = false;
          });
        });
      } else {
        _isManuallyScrolling = false;
      }
    } else {
      _isManuallyScrolling = false;
    }
  }

  void _updateCategoryFromScroll(RestaurantController restController) {
    if (restController.restaurantProducts == null ||
        restController.restaurantProducts!.isEmpty ||
        restController.categoryList == null ||
        restController.categoryList!.isEmpty ||
        !mounted) {
      return;
    }

    // When scrolled to the top (recommend section visible), always select first category and scroll tabs to start
    const topSectionThreshold = 400.0;
    if (scrollController.hasClients &&
        scrollController.offset <= topSectionThreshold) {
      final visibleCategoryIndices = _getVisibleCategoryIndices(restController);
      final firstVisibleCategoryIndex =
          visibleCategoryIndices.isNotEmpty ? visibleCategoryIndices.first : 0;
      if (restController.categoryIndex != firstVisibleCategoryIndex ||
          _lastUpdatedCategoryIndex != firstVisibleCategoryIndex) {
        _lastUpdatedCategoryIndex = firstVisibleCategoryIndex;
        restController.updateCategoryIndexFromScroll(firstVisibleCategoryIndex);
        _scrollActiveCategoryTabIntoView(restController);
        // Scroll the horizontal category tabs to the very start
        if (categoryTabsScrollController.hasClients) {
          categoryTabsScrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      }
      return;
    }
    int? visibleCategoryIndex;
    int? firstBelowIndex;
    double minDistanceBelow = double.infinity;

    // The sticky header position (where category tabs stick)
    const stickyHeaderY = 250.0;

    // Single pass through categories
    for (int i = 0; i < restController.categoryList!.length; i++) {
      final category = restController.categoryList![i];
      if (category.id == null) continue;

      // Only check categories that have products (exist in grouped view)
      final categoryKey = _categoryKeys[category.id];
      if (categoryKey?.currentContext == null) continue;

      final RenderBox? renderBox =
          categoryKey!.currentContext!.findRenderObject() as RenderBox?;
      if (renderBox == null || !renderBox.hasSize) continue;

      try {
        final position = renderBox.localToGlobal(Offset.zero);
        final categoryTop = position.dy;
        final categoryBottom = categoryTop + renderBox.size.height;

        // If category header is at or above sticky header, and content is still visible
        if (categoryTop <= stickyHeaderY && categoryBottom > stickyHeaderY) {
          visibleCategoryIndex = i;
          break; // Found the active category
        }

        // Track the first category below sticky header (fallback)
        if (categoryTop > stickyHeaderY) {
          final distance = categoryTop - stickyHeaderY;
          if (distance < minDistanceBelow) {
            minDistanceBelow = distance;
            firstBelowIndex = i;
          }
        }
      } catch (e) {
        continue;
      }
    }

    // Use first below if no active category found
    visibleCategoryIndex ??= firstBelowIndex;
    if (visibleCategoryIndex == null) {
      final visibleCategoryIndices = _getVisibleCategoryIndices(restController);
      visibleCategoryIndex =
          visibleCategoryIndices.isNotEmpty ? visibleCategoryIndices.first : 0;
    }

    // Update the index if changed
    if (visibleCategoryIndex != restController.categoryIndex &&
        visibleCategoryIndex != _lastUpdatedCategoryIndex) {
      _lastUpdatedCategoryIndex = visibleCategoryIndex;
      restController.updateCategoryIndexFromScroll(visibleCategoryIndex);
      _scrollActiveCategoryTabIntoView(restController);
    }
  }

  Future<void> _initDataCall() async {
    if (!mounted) return;

    final restController = Get.find<RestaurantController>();
    if (restController.isSearching) {
      restController.changeSearchStatus(isUpdate: false);
    }

    final seed = widget.restaurant;
    final restaurantId = seed?.id ?? restController.restaurant?.id;
    if (restaurantId == null) return;

    // Seed from list/card without notifying mid-frame, then fetch full details.
    if (seed != null && seed.name != null) {
      await restController.getRestaurantDetails(
        seed,
        slug: widget.slug,
        notify: false,
      );
    }
    await restController.getRestaurantDetails(
      Restaurant(id: restaurantId),
      slug: widget.slug,
    );

    if (!mounted) return;

    if (Get.find<CategoryController>().categoryList == null) {
      await Get.find<CategoryController>().getCategoryList(true);
    }

    if (!mounted) return;

    Get.find<CouponController>()
        .getRestaurantCouponList(restaurantId: restaurantId);
    restController.getRestaurantRecommendedItemList(restaurantId, false);
    await restController.getRestaurantProductList(restaurantId, 1, 'all', true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
        appBar: isDesktop ? WebMenuBar(fromDineIn: widget.fromDineIn) : null,
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        backgroundColor: colors.canvas,
        body: GetBuilder<RestaurantController>(builder: (restController) {
          return GetBuilder<CouponController>(builder: (couponController) {
            return GetBuilder<CategoryController>(
                builder: (categoryController) {
              Restaurant? restaurant;
              if (restController.restaurant != null &&
                  restController.restaurant!.name != null) {
                restaurant = restController.restaurant;
              }
              restController.setCategoryList();
              _syncCategoryIndexWithVisibleCategories(restController);
              bool hasCoupon = (couponController.couponList != null &&
                  couponController.couponList!.isNotEmpty);

              return (restaurant != null)
                  ? RefreshIndicator(
                      onRefresh: _initDataCall,
                      child: CustomScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        controller: scrollController,
                        slivers: [
                          RestaurantInfoSectionWidget(
                              restaurant: restaurant!,
                              restController: restController,
                              hasCoupon: hasCoupon),
                          SliverToBoxAdapter(
                              child: Center(
                                  child: Container(
                            width: Dimensions.webMaxWidth,
                            color: colors.canvas,
                            child: Column(children: [
                              // isDesktop ? const SizedBox() : RestaurantDescriptionView(restaurant: restaurant),
                              restaurant.discount != null
                                  ? Container(
                                      width: context.width,
                                      margin: const EdgeInsets.symmetric(
                                          vertical: AppSpacing.sm,
                                          horizontal: AppSpacing.xl),
                                      decoration: BoxDecoration(
                                          borderRadius: AppRadius.smAll,
                                          color: colors.accent),
                                      padding:
                                          const EdgeInsets.all(AppSpacing.sm),
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              restaurant.discount!
                                                          .discountType ==
                                                      'percent'
                                                  ? '${restaurant.discount!.discount}% ${'off'.tr}'
                                                  : '${PriceConverter.convertPrice(restaurant.discount!.discount)} ${'off'.tr}',
                                              style: AppTypography.titleSm(
                                                  colors.onAccent),
                                            ),
                                            Text(
                                              restaurant.discount!
                                                          .discountType ==
                                                      'percent'
                                                  ? '${'enjoy'.tr} ${restaurant.discount!.discount}% ${'off_on_all_categories'.tr}'
                                                  : '${'enjoy'.tr} ${PriceConverter.convertPrice(restaurant.discount!.discount)}'
                                                      ' ${'off_on_all_categories'.tr}',
                                              style: AppTypography.bodySm(
                                                  colors.onAccent),
                                            ),
                                            SizedBox(
                                                height: (restaurant.discount!
                                                                .minPurchase !=
                                                            0 ||
                                                        restaurant.discount!
                                                                .maxDiscount !=
                                                            0)
                                                    ? 5
                                                    : 0),
                                            restaurant.discount!.minPurchase !=
                                                    0
                                                ? Text(
                                                    '[ ${'minimum_purchase'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.minPurchase)} ]',
                                                    style:
                                                        AppTypography.labelSm(
                                                            colors.onAccent),
                                                  )
                                                : const SizedBox(),
                                            restaurant.discount!.maxDiscount !=
                                                    0
                                                ? Text(
                                                    '[ ${'maximum_discount'.tr}: ${PriceConverter.convertPrice(restaurant.discount!.maxDiscount)} ]',
                                                    style:
                                                        AppTypography.labelSm(
                                                            colors.onAccent),
                                                  )
                                                : const SizedBox(),
                                            Text(
                                              '[ ${'daily_time'.tr}: ${DateConverter.convertTimeToTime(restaurant.discount!.startTime!)} '
                                              '- ${DateConverter.convertTimeToTime(restaurant.discount!.endTime!)} ]',
                                              style: AppTypography.labelSm(
                                                  colors.onAccent),
                                            ),
                                          ]),
                                    )
                                  : const SizedBox(),
                              SizedBox(
                                  height: (restaurant.announcementActive! &&
                                          restaurant.announcementMessage !=
                                              null)
                                      ? 0
                                      : AppSpacing.sm),

                              ResponsiveHelper.isMobile(context)
                                  ? (restaurant.announcementActive! &&
                                          restaurant.announcementMessage !=
                                              null)
                                      ? Container(
                                          decoration: BoxDecoration(
                                              color: colors.success),
                                          padding: const EdgeInsets.symmetric(
                                              vertical: AppSpacing.sm,
                                              horizontal: AppSpacing.xl),
                                          margin: const EdgeInsets.only(
                                              bottom: AppSpacing.sm),
                                          child: Row(children: [
                                            Image.asset(Images.announcement,
                                                height: 26, width: 26),
                                            const SizedBox(
                                                width: AppSpacing.sm),
                                            Flexible(
                                                child: Text(
                                              restaurant.announcementMessage ??
                                                  '',
                                              style: AppTypography.labelMd(
                                                  colors.onAccent),
                                            )),
                                          ]),
                                        )
                                      : const SizedBox()
                                  : const SizedBox(),

                              restController.recommendedProductModel != null &&
                                      restController.recommendedProductModel!
                                          .products!.isNotEmpty
                                  ? Container(
                                      color: colors.accentSoft,
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                top:
                                                    Dimensions.paddingSizeLarge,
                                                left:
                                                    Dimensions.paddingSizeLarge,
                                                bottom:
                                                    Dimensions.paddingSizeSmall,
                                                right:
                                                    Dimensions.paddingSizeLarge,
                                              ),
                                              child: Row(children: [
                                                Expanded(
                                                  child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                            'recommend_for_you'
                                                                .tr,
                                                            style: robotoMedium.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeLarge,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700)),
                                                        const SizedBox(
                                                            height: Dimensions
                                                                .paddingSizeExtraSmall),
                                                        Text('here_is_what_you_might_like_to_test'.tr,
                                                            style: robotoRegular.copyWith(
                                                                fontSize: Dimensions
                                                                    .fontSizeSmall,
                                                                color: Theme.of(
                                                                        context)
                                                                    .disabledColor)),
                                                      ]),
                                                ),
                                                ArrowIconButtonWidget(
                                                  onTap: () => Get.toNamed(
                                                      RouteHelper.getPopularFoodRoute(
                                                          false,
                                                          fromIsRestaurantFood:
                                                              true,
                                                          restaurantId: widget
                                                                  .restaurant!
                                                                  .id ??
                                                              Get.find<
                                                                      RestaurantController>()
                                                                  .restaurant!
                                                                  .id!)),
                                                ),
                                              ]),
                                            ),
                                            SizedBox(
                                              height:
                                                  ResponsiveHelper.isDesktop(
                                                          context)
                                                      ? 307
                                                      : 200,
                                              width: context.width,
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: restController
                                                    .recommendedProductModel!
                                                    .products!
                                                    .length,
                                                physics:
                                                    const BouncingScrollPhysics(),
                                                padding: const EdgeInsets.only(
                                                    top: Dimensions
                                                        .paddingSizeExtraSmall,
                                                    bottom: Dimensions
                                                        .paddingSizeExtraSmall,
                                                    right: Dimensions
                                                        .paddingSizeDefault),
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .only(
                                                        left: Dimensions
                                                            .paddingSizeDefault),
                                                    child:
                                                        RestaurantPageNewItemCardWidget(
                                                      product: restController
                                                          .recommendedProductModel!
                                                          .products![index],
                                                      isBestItem: false,
                                                      isPopularNearbyItem:
                                                          false,
                                                      width: ResponsiveHelper
                                                              .isDesktop(
                                                                  context)
                                                          ? (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  60) /
                                                              6
                                                          : (MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width -
                                                                  0) /
                                                              3,
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                            const SizedBox(
                                                height: Dimensions
                                                    .paddingSizeSmall),
                                          ]),
                                    )
                                  : const SizedBox(),
                            ]),
                          ))),
                          ((restController.categoryList?.isNotEmpty ?? false))
                              ? isDesktop
                                  ? SliverPersistentHeader(
                                      pinned: isDesktop ? false : true,
                                      floating: isDesktop ? true : false,
                                      delegate: SliverDelegate(
                                        height: 98,
                                        child: Center(
                                          child: Container(
                                            width: Dimensions.webMaxWidth,
                                            decoration: BoxDecoration(
                                              color: colors.canvas,
                                              boxShadow: isDesktop
                                                  ? []
                                                  : [
                                                      BoxShadow(
                                                          color: Colors.grey
                                                              .withValues(
                                                                  alpha: 0.1),
                                                          spreadRadius: 1,
                                                          blurRadius: 10,
                                                          offset: const Offset(
                                                              0, 1))
                                                    ],
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimensions
                                                    .paddingSizeExtraSmall),
                                            child: Column(children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: Dimensions
                                                        .paddingSizeDefault,
                                                    right: Dimensions
                                                        .paddingSizeDefault,
                                                    top: Dimensions
                                                        .paddingSizeSmall),
                                                child: Row(children: [
                                                  Text('all_food_items'.tr,
                                                      style: AppTypography
                                                              .displayMd(
                                                                  colors.ink)
                                                          .copyWith(
                                                        fontSize:
                                                            isDesktop ? 26 : 22,
                                                        height: 1.2,
                                                        letterSpacing: -0.4,
                                                      )),
                                                  const Expanded(
                                                      child: SizedBox()),
                                                  isDesktop
                                                      ? Container(
                                                          padding: const EdgeInsets
                                                              .all(Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          height: 35,
                                                          width: 320,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                            color: Theme.of(
                                                                    context)
                                                                .cardColor,
                                                            border: Border.all(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                width: 0.3),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextField(
                                                                  controller:
                                                                      _searchController,
                                                                  textInputAction:
                                                                      TextInputAction
                                                                          .search,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    contentPadding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            0,
                                                                        vertical:
                                                                            0),
                                                                    hintText:
                                                                        'search_for_your_food'
                                                                            .tr,
                                                                    hintStyle: robotoRegular.copyWith(
                                                                        fontSize:
                                                                            Dimensions
                                                                                .fontSizeSmall,
                                                                        color: Theme.of(context)
                                                                            .disabledColor),
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(Dimensions
                                                                                .radiusSmall),
                                                                        borderSide:
                                                                            BorderSide.none),
                                                                    filled:
                                                                        true,
                                                                    fillColor: Theme.of(
                                                                            context)
                                                                        .cardColor,
                                                                    isDense:
                                                                        true,
                                                                    prefixIcon:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        if (!restController
                                                                            .isSearching) {
                                                                          Get.find<RestaurantController>()
                                                                              .getRestaurantSearchProductList(
                                                                            _searchController.text.trim(),
                                                                            Get.find<RestaurantController>().restaurant!.id.toString(),
                                                                            1,
                                                                            restController.type,
                                                                          );
                                                                        } else {
                                                                          _searchController.text =
                                                                              '';
                                                                          restController
                                                                              .initSearchData();
                                                                          restController
                                                                              .changeSearchStatus();
                                                                        }
                                                                      },
                                                                      child: Icon(
                                                                          restController.isSearching
                                                                              ? Icons.clear
                                                                              : CupertinoIcons.search,
                                                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.50)),
                                                                    ),
                                                                  ),
                                                                  onSubmitted:
                                                                      (String?
                                                                          value) {
                                                                    if (value!
                                                                        .isNotEmpty) {
                                                                      restController
                                                                          .getRestaurantSearchProductList(
                                                                        _searchController
                                                                            .text
                                                                            .trim(),
                                                                        Get.find<RestaurantController>()
                                                                            .restaurant!
                                                                            .id
                                                                            .toString(),
                                                                        1,
                                                                        restController
                                                                            .type,
                                                                      );
                                                                    }
                                                                  },
                                                                  onChanged:
                                                                      (String?
                                                                          value) {},
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeSmall),
                                                            ],
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () async {
                                                            await Get.toNamed(RouteHelper
                                                                .getSearchRestaurantProductRoute(
                                                                    restaurant!
                                                                        .id));
                                                            if (restController
                                                                .isSearching) {
                                                              restController
                                                                  .changeSearchStatus();
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusDefault),
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.1),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                            .paddingSizeSmall -
                                                                        2),
                                                            child: Image.asset(
                                                                Images.search,
                                                                height: 20,
                                                                width: 20,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                        ),
                                                  restController.type.isNotEmpty
                                                      ? VegFilterWidget(
                                                          type: restController
                                                              .type,
                                                          iconColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          onSelected:
                                                              (String type) {
                                                            restController
                                                                .getRestaurantProductList(
                                                                    restController
                                                                        .restaurant!
                                                                        .id,
                                                                    1,
                                                                    type,
                                                                    true);
                                                          },
                                                        )
                                                      : const SizedBox(),
                                                ]),
                                              ),
                                              const Divider(
                                                  thickness: 0.2, height: 10),
                                              SizedBox(
                                                height: 32,
                                                child: Builder(
                                                  builder: (context) {
                                                    final visibleCategoryIndices =
                                                        _getVisibleCategoryIndices(
                                                            restController);
                                                    return ListView.builder(
                                                      controller:
                                                          categoryTabsScrollController,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          visibleCategoryIndices
                                                              .length,
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: Dimensions
                                                              .paddingSizeDefault),
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        final categoryIndex =
                                                            visibleCategoryIndices[
                                                                index];
                                                        _categoryTabKeys[
                                                                categoryIndex] ??=
                                                            GlobalKey();
                                                        return InkWell(
                                                          key: _categoryTabKeys[
                                                              categoryIndex],
                                                          onTap: () {
                                                            _lastUpdatedCategoryIndex =
                                                                -1; // Reset auto-highlight state
                                                            _scrollToCategory(
                                                                categoryIndex,
                                                                restController);
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            margin: const EdgeInsets
                                                                .only(
                                                                right: Dimensions
                                                                    .paddingSizeSmall),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusDefault),
                                                              color: categoryIndex ==
                                                                      restController
                                                                          .categoryIndex
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.1)
                                                                  : Colors
                                                                      .transparent,
                                                            ),
                                                            child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    restController
                                                                        .categoryList![
                                                                            categoryIndex]
                                                                        .name!,
                                                                    style: categoryIndex ==
                                                                            restController
                                                                                .categoryIndex
                                                                        ? robotoMedium.copyWith(
                                                                            fontSize: Dimensions
                                                                                .fontSizeSmall,
                                                                            color: Theme.of(context)
                                                                                .primaryColor)
                                                                        : robotoRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeSmall),
                                                                  ),
                                                                ]),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ),
                                    )
                                  : SliverPersistentHeader(
                                      pinned: isDesktop ? false : true,
                                      floating: isDesktop ? true : false,
                                      delegate: SliverDelegate(
                                        height: 98,
                                        child: Center(
                                          child: Container(
                                            width: Dimensions.webMaxWidth,
                                            decoration: BoxDecoration(
                                              color: colors.canvas,
                                              boxShadow: isDesktop
                                                  ? []
                                                  : [
                                                      BoxShadow(
                                                          color: Colors.grey
                                                              .withValues(
                                                                  alpha: 0.1),
                                                          spreadRadius: 1,
                                                          blurRadius: 10,
                                                          offset: const Offset(
                                                              0, 1))
                                                    ],
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: Dimensions
                                                    .paddingSizeExtraSmall),
                                            child: Column(children: [
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    left: Dimensions
                                                        .paddingSizeDefault,
                                                    right: Dimensions
                                                        .paddingSizeDefault,
                                                    top: Dimensions
                                                        .paddingSizeSmall),
                                                child: Row(children: [
                                                  Text('all_food_items'.tr,
                                                      style: AppTypography
                                                              .displayMd(
                                                                  colors.ink)
                                                          .copyWith(
                                                        fontSize:
                                                            isDesktop ? 26 : 22,
                                                        height: 1.2,
                                                        letterSpacing: -0.4,
                                                      )),
                                                  const Expanded(
                                                      child: SizedBox()),
                                                  isDesktop
                                                      ? Container(
                                                          padding: const EdgeInsets
                                                              .all(Dimensions
                                                                  .paddingSizeExtraSmall),
                                                          height: 35,
                                                          width: 320,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        25),
                                                            color: Theme.of(
                                                                    context)
                                                                .cardColor,
                                                            border: Border.all(
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                width: 0.3),
                                                          ),
                                                          child: Row(
                                                            children: [
                                                              Expanded(
                                                                child:
                                                                    TextField(
                                                                  controller:
                                                                      _searchController,
                                                                  textInputAction:
                                                                      TextInputAction
                                                                          .search,
                                                                  decoration:
                                                                      InputDecoration(
                                                                    contentPadding: const EdgeInsets
                                                                        .symmetric(
                                                                        horizontal:
                                                                            0,
                                                                        vertical:
                                                                            0),
                                                                    hintText:
                                                                        'search_for_your_food'
                                                                            .tr,
                                                                    hintStyle: robotoRegular.copyWith(
                                                                        fontSize:
                                                                            Dimensions
                                                                                .fontSizeSmall,
                                                                        color: Theme.of(context)
                                                                            .disabledColor),
                                                                    border: OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(Dimensions
                                                                                .radiusSmall),
                                                                        borderSide:
                                                                            BorderSide.none),
                                                                    filled:
                                                                        true,
                                                                    fillColor: Theme.of(
                                                                            context)
                                                                        .cardColor,
                                                                    isDense:
                                                                        true,
                                                                    prefixIcon:
                                                                        InkWell(
                                                                      onTap:
                                                                          () {
                                                                        if (!restController
                                                                            .isSearching) {
                                                                          Get.find<RestaurantController>()
                                                                              .getRestaurantSearchProductList(
                                                                            _searchController.text.trim(),
                                                                            Get.find<RestaurantController>().restaurant!.id.toString(),
                                                                            1,
                                                                            restController.type,
                                                                          );
                                                                        } else {
                                                                          _searchController.text =
                                                                              '';
                                                                          restController
                                                                              .initSearchData();
                                                                          restController
                                                                              .changeSearchStatus();
                                                                        }
                                                                      },
                                                                      child: Icon(
                                                                          restController.isSearching
                                                                              ? Icons.clear
                                                                              : CupertinoIcons.search,
                                                                          color: Theme.of(context).primaryColor.withValues(alpha: 0.50)),
                                                                    ),
                                                                  ),
                                                                  onSubmitted:
                                                                      (String?
                                                                          value) {
                                                                    if (value!
                                                                        .isNotEmpty) {
                                                                      restController
                                                                          .getRestaurantSearchProductList(
                                                                        _searchController
                                                                            .text
                                                                            .trim(),
                                                                        Get.find<RestaurantController>()
                                                                            .restaurant!
                                                                            .id
                                                                            .toString(),
                                                                        1,
                                                                        restController
                                                                            .type,
                                                                      );
                                                                    }
                                                                  },
                                                                  onChanged:
                                                                      (String?
                                                                          value) {},
                                                                ),
                                                              ),
                                                              const SizedBox(
                                                                  width: Dimensions
                                                                      .paddingSizeSmall),
                                                            ],
                                                          ),
                                                        )
                                                      : InkWell(
                                                          onTap: () async {
                                                            await Get.toNamed(RouteHelper
                                                                .getSearchRestaurantProductRoute(
                                                                    restaurant!
                                                                        .id));
                                                            if (restController
                                                                .isSearching) {
                                                              restController
                                                                  .changeSearchStatus();
                                                            }
                                                          },
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusDefault),
                                                              color: Theme.of(
                                                                      context)
                                                                  .primaryColor
                                                                  .withValues(
                                                                      alpha:
                                                                          0.1),
                                                            ),
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(
                                                                    Dimensions
                                                                            .paddingSizeSmall -
                                                                        2),
                                                            child: Image.asset(
                                                                Images.search,
                                                                height: 20,
                                                                width: 20,
                                                                color: Theme.of(
                                                                        context)
                                                                    .primaryColor,
                                                                fit: BoxFit
                                                                    .cover),
                                                          ),
                                                        ),
                                                  restController.type.isNotEmpty
                                                      ? VegFilterWidget(
                                                          type: restController
                                                              .type,
                                                          iconColor:
                                                              Theme.of(context)
                                                                  .primaryColor,
                                                          onSelected:
                                                              (String type) {
                                                            restController
                                                                .getRestaurantProductList(
                                                                    restController
                                                                        .restaurant!
                                                                        .id,
                                                                    1,
                                                                    type,
                                                                    true);
                                                          },
                                                        )
                                                      : const SizedBox(),
                                                ]),
                                              ),
                                              const Divider(
                                                  thickness: 0.2, height: 10),
                                              SizedBox(
                                                height: 32,
                                                child: Builder(
                                                  builder: (context) {
                                                    final visibleCategoryIndices =
                                                        _getVisibleCategoryIndices(
                                                            restController);
                                                    return ListView.builder(
                                                      controller:
                                                          categoryTabsScrollController,
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          visibleCategoryIndices
                                                              .length,
                                                      padding: const EdgeInsets
                                                          .only(
                                                          left: Dimensions
                                                              .paddingSizeDefault),
                                                      physics:
                                                          const BouncingScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        final categoryIndex =
                                                            visibleCategoryIndices[
                                                                index];
                                                        _categoryTabKeys[
                                                                categoryIndex] ??=
                                                            GlobalKey();
                                                        return InkWell(
                                                          key: _categoryTabKeys[
                                                              categoryIndex],
                                                          onTap: () {
                                                            _lastUpdatedCategoryIndex =
                                                                -1; // Reset auto-highlight state
                                                            _scrollToCategory(
                                                                categoryIndex,
                                                                restController);
                                                          },
                                                          child: Container(
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                    Dimensions
                                                                        .paddingSizeSmall,
                                                                vertical: Dimensions
                                                                    .paddingSizeExtraSmall),
                                                            margin: const EdgeInsets
                                                                .only(
                                                                right: Dimensions
                                                                    .paddingSizeSmall),
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius.circular(
                                                                      Dimensions
                                                                          .radiusDefault),
                                                              color: categoryIndex ==
                                                                      restController
                                                                          .categoryIndex
                                                                  ? Theme.of(
                                                                          context)
                                                                      .primaryColor
                                                                      .withValues(
                                                                          alpha:
                                                                              0.1)
                                                                  : Colors
                                                                      .transparent,
                                                            ),
                                                            child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                    restController
                                                                        .categoryList![
                                                                            categoryIndex]
                                                                        .name!,
                                                                    style: categoryIndex ==
                                                                            restController
                                                                                .categoryIndex
                                                                        ? robotoMedium.copyWith(
                                                                            fontSize: Dimensions
                                                                                .fontSizeSmall,
                                                                            color: Theme.of(context)
                                                                                .primaryColor)
                                                                        : robotoRegular.copyWith(
                                                                            fontSize:
                                                                                Dimensions.fontSizeSmall),
                                                                  ),
                                                                ]),
                                                          ),
                                                        );
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ]),
                                          ),
                                        ),
                                      ),
                                    )
                              : const SliverToBoxAdapter(child: SizedBox()),
                          SliverToBoxAdapter(
                            child:
                                SizedBox(height: Dimensions.paddingSizeLarge),
                          ),
                          SliverToBoxAdapter(
                            child: FooterViewWidget(
                              child: Center(
                                child: Container(
                                  width: Dimensions.webMaxWidth,
                                  decoration: BoxDecoration(
                                    color: colors.canvas,
                                  ),
                                  child: PaginatedListViewWidget(
                                    scrollController: scrollController,
                                    onPaginate: (int? offset) {
                                      if (restController.isSearching) {
                                        restController
                                            .getRestaurantSearchProductList(
                                          restController.searchText,
                                          Get.find<RestaurantController>()
                                              .restaurant!
                                              .id
                                              .toString(),
                                          offset!,
                                          restController.type,
                                        );
                                      } else {
                                        restController.getRestaurantProductList(
                                            Get.find<RestaurantController>()
                                                .restaurant!
                                                .id,
                                            offset!,
                                            restController.type,
                                            false);
                                      }
                                    },
                                    totalSize: restController.isSearching
                                        ? restController
                                            .restaurantSearchProductModel
                                            ?.totalSize
                                        : restController.restaurantProducts !=
                                                null
                                            ? restController.foodPageSize
                                            : null,
                                    offset: restController.isSearching
                                        ? restController
                                            .restaurantSearchProductModel
                                            ?.offset
                                        : restController.restaurantProducts !=
                                                null
                                            ? restController.foodPageOffset
                                            : null,
                                    productView: restController.isSearching
                                        ? ProductViewWidget(
                                            isRestaurant: false,
                                            restaurants: null,
                                            products: restController
                                                .restaurantSearchProductModel
                                                ?.products,
                                            inRestaurantPage: true,
                                          )
                                        : (restController
                                                    .categoryList?.isNotEmpty ??
                                                false)
                                            ? isDesktop
                                                ? ProductViewWidget(
                                                    isRestaurant: false,
                                                    restaurants: null,
                                                    products: restController
                                                        .restaurantProducts,
                                                    inRestaurantPage: true,
                                                  )
                                                : GroupedProductViewWidget(
                                                    products: restController
                                                        .restaurantProducts,
                                                    categoryList: restController
                                                        .categoryList,
                                                    categoryKeys: _categoryKeys,
                                                    inRestaurantPage: true,
                                                  )
                                            : ProductViewWidget(
                                                isRestaurant: false,
                                                restaurants: null,
                                                products: restController
                                                    .restaurantProducts,
                                                inRestaurantPage: true,
                                              ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const RestaurantScreenShimmerWidget();
            });
          });
        }),
        bottomNavigationBar:
            GetBuilder<CartController>(builder: (cartController) {
          return cartController.cartList.isNotEmpty && !isDesktop
              ? BottomCartWidget(
                  restaurantId:
                      cartController.cartList[0].product!.restaurantId!,
                  fromDineIn: widget.fromDineIn)
              : const SizedBox();
        }));
  }
}

class SliverDelegate extends SliverPersistentHeaderDelegate {
  Widget child;
  double height;

  SliverDelegate({required this.child, this.height = 100});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(SliverDelegate oldDelegate) {
    return oldDelegate.maxExtent != height ||
        oldDelegate.minExtent != height ||
        child != oldDelegate.child;
  }
}

// class CategoryProduct {
//   CategoryModel category;
//   List<Product> products;
//   CategoryProduct(this.category, this.products);
// }
