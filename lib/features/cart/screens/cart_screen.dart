import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/cupertino.dart';
import 'package:toto_user/common/widgets/custom_ink_well_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_icons.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/cart/widgets/cart_product_widget.dart';
import 'package:toto_user/features/cart/widgets/cart_suggested_item_view_widget.dart';
import 'package:toto_user/features/cart/widgets/checkout_button_widget.dart';
import 'package:toto_user/features/cart/widgets/pricing_view_widget.dart';
import 'package:toto_user/features/checkout/controllers/checkout_controller.dart';
import 'package:toto_user/features/profile/controllers/profile_controller.dart';
import 'package:toto_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:toto_user/common/models/restaurant_model.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/in_app_messaging_helper.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/no_data_screen_widget.dart';
import 'package:toto_user/common/widgets/web_constrained_box.dart';
import 'package:toto_user/common/widgets/web_page_title_widget.dart';
import 'package:toto_user/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatefulWidget {
  final bool fromNav;
  final bool fromReorder;
  final bool fromDineIn;
  const CartScreen(
      {super.key,
      required this.fromNav,
      this.fromReorder = false,
      this.fromDineIn = false});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final ScrollController scrollController = ScrollController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  final GlobalKey _widgetKey = GlobalKey();
  double _height = 0;
  bool _initialLoadComplete = false;

  @override
  void initState() {
    super.initState();

    initCall();
  }

  Future<void> initCall() async {
    _initialBottomSheetShowHide();
    Get.find<RestaurantController>().makeEmptyRestaurant(willUpdate: false);
    Get.find<CartController>().setAvailableIndex(-1, willUpdate: false);
    Get.find<CheckoutController>().setInstruction(-1, willUpdate: false);
    await Get.find<CartController>().getCartDataOnline();
    setState(() {
      _initialLoadComplete = true;
    });
    if (Get.find<CartController>().cartList.isNotEmpty) {
      await Get.find<RestaurantController>().getRestaurantDetails(
          Restaurant(
              id: Get.find<CartController>().cartList[0].product!.restaurantId,
              name: null),
          fromCart: true);
      Get.find<CartController>().calculationCart();
      if (Get.find<CartController>().addCutlery) {
        Get.find<CartController>().updateCutlery(isUpdate: false);
      }
      if (Get.find<CartController>().needExtraPackage) {
        Get.find<CartController>().toggleExtraPackage(willUpdate: false);
      }
      Get.find<RestaurantController>().getCartRestaurantSuggestedItemList(
          Get.find<CartController>().cartList[0].product!.restaurantId);
      showReferAndEarnSnackBar();
    }

    // Trigger in-app messages for cart screen
    Future.delayed(const Duration(milliseconds: 800), () {
      InAppMessagingHelper.triggerForScreen('cart');
      // Also check for immediate messages
      InAppMessagingHelper.checkForImmediateMessages();
    });
  }

  void _initialBottomSheetShowHide() {
    Future.delayed(const Duration(milliseconds: 600), () {
      key.currentState!.expand();
    }).then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        key.currentState!.contract();
      });
    });
  }

  void _getExpandedBottomSheetHeight() {
    if (_widgetKey.currentContext != null) {
      final RenderBox renderBox =
          _widgetKey.currentContext!.findRenderObject() as RenderBox;
      final size = renderBox.size;

      setState(() {
        _height = size.height;
      });
    }
  }

  void _onExpanded() {
    _getExpandedBottomSheetHeight();
  }

  void _onContracted() {
    setState(() {
      _height = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBarWidget(
          title: 'my_cart'.tr,
          isBackButtonExist: (isDesktop || !widget.fromNav)),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<RestaurantController>(builder: (restaurantController) {
        return GetBuilder<CartController>(
          builder: (cartController) {
            bool isRestaurantOpen = true;

            if (restaurantController.restaurant != null) {
              isRestaurantOpen = restaurantController.isRestaurantOpenNow(
                  restaurantController.restaurant!.active!,
                  restaurantController.restaurant!.schedules);
            }

            bool suggestionEmpty =
                (restaurantController.suggestedItems != null &&
                    restaurantController.suggestedItems!.isEmpty);
            // Only show full-screen loader during initial load from reorder, not during quantity updates
            return (cartController.isLoading &&
                    widget.fromReorder &&
                    !_initialLoadComplete)
                ? Center(
                    child: SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.accent,
                        )),
                  )
                : cartController.cartList.isNotEmpty
                    ? Column(
                        children: [
                          Expanded(
                            child: ExpandableBottomSheet(
                              key: key,
                              persistentHeader: isDesktop
                                  ? const SizedBox()
                                  : InkWell(
                                      onTap: () {
                                        if (cartController.isExpanded) {
                                          cartController.setExpanded(false);
                                          setState(() {
                                            key.currentState!.contract();
                                          });
                                        } else {
                                          cartController.setExpanded(true);
                                          setState(() {
                                            key.currentState!.expand();
                                          });
                                        }
                                      },
                                      child: Container(
                                        color: colors.surface,
                                        child: Container(
                                          constraints:
                                              const BoxConstraints.expand(
                                                  height: 28),
                                          decoration: BoxDecoration(
                                            color: colors.surfaceElevated,
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(
                                                        AppRadius.md)),
                                          ),
                                          child: Icon(Icons.drag_handle_rounded,
                                              color: colors.inkFaint,
                                              size: AppIcons.md),
                                        ),
                                      ),
                                    ),
                              background: Column(
                                children: [
                                  WebScreenTitleWidget(title: 'my_cart'.tr),
                                  Expanded(
                                    child: SingleChildScrollView(
                                      controller: scrollController,
                                      padding: isDesktop
                                          ? const EdgeInsets.only(
                                              top: AppSpacing.sm)
                                          : EdgeInsets.zero,
                                      child: FooterViewWidget(
                                        child: Center(
                                          child: SizedBox(
                                            width: Dimensions.webMaxWidth,
                                            child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Expanded(
                                                          flex: 6,
                                                          child: Column(
                                                              children: [
                                                                Container(
                                                                  decoration: isDesktop
                                                                      ? BoxDecoration(
                                                                          borderRadius: AppRadius.mdAll,
                                                                          color: colors.surface,
                                                                          boxShadow: AppShadows.of(context, 1),
                                                                          border: Border.all(color: colors.line),
                                                                        )
                                                                      : BoxDecoration(
                                                                          color: colors.surface,
                                                                        ),
                                                                  child: Column(
                                                                      crossAxisAlignment:
                                                                          CrossAxisAlignment
                                                                              .start,
                                                                      children: [
                                                                        WebConstrainedBox(
                                                                          dataLength: cartController
                                                                              .cartList
                                                                              .length,
                                                                          minLength:
                                                                              5,
                                                                          minHeight: suggestionEmpty
                                                                              ? 0.6
                                                                              : 0.3,
                                                                          child: Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                !isRestaurantOpen && restaurantController.restaurant != null
                                                                                    ? !isDesktop
                                                                                        ? Center(
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(top: AppSpacing.sm),
                                                                                              child: RichText(
                                                                                                textAlign: TextAlign.center,
                                                                                                text: TextSpan(children: [
                                                                                                  TextSpan(text: 'currently_the_restaurant_is_unavailable_the_restaurant_will_be_available_at'.tr, style: AppTypography.bodySm(colors.inkMuted)),
                                                                                                  const TextSpan(text: ' '),
                                                                                                  TextSpan(
                                                                                                    text: restaurantController.restaurant!.restaurantOpeningTime == 'closed' ? 'tomorrow'.tr : DateConverter.timeStringToTime(restaurantController.restaurant!.restaurantOpeningTime!),
                                                                                                    style: AppTypography.labelMd(colors.accent),
                                                                                                  ),
                                                                                                ]),
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        : Container(
                                                                                            padding: const EdgeInsets.all(AppSpacing.sm),
                                                                                            decoration: BoxDecoration(
                                                                                              color: colors.accentSoft,
                                                                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                                                                                            ),
                                                                                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                                                                              Expanded(
                                                                                                child: RichText(
                                                                                                  textAlign: TextAlign.start,
                                                                                                  text: TextSpan(children: [
                                                                                                    TextSpan(text: 'currently_the_restaurant_is_unavailable_the_restaurant_will_be_available_at'.tr, style: AppTypography.bodySm(colors.inkMuted)),
                                                                                                    const TextSpan(text: ' '),
                                                                                                    TextSpan(
                                                                                                      text: restaurantController.restaurant!.restaurantOpeningTime == 'closed' ? 'tomorrow'.tr : DateConverter.timeStringToTime(restaurantController.restaurant!.restaurantOpeningTime!),
                                                                                                      style: AppTypography.labelMd(colors.accent),
                                                                                                    ),
                                                                                                  ]),
                                                                                                ),
                                                                                              ),
                                                                                              !isRestaurantOpen
                                                                                                  ? Align(
                                                                                                      alignment: Alignment.center,
                                                                                                      child: InkWell(
                                                                                                        onTap: () {
                                                                                                          cartController.clearCartOnline();
                                                                                                        },
                                                                                                        borderRadius: AppRadius.xsAll,
                                                                                                        child: Container(
                                                                                                          padding: const EdgeInsets.all(AppSpacing.sm),
                                                                                                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                                                                                                          decoration: BoxDecoration(
                                                                                                            color: colors.surface,
                                                                                                            borderRadius: AppRadius.xsAll,
                                                                                                            border: Border.all(width: 1, color: colors.line),
                                                                                                          ),
                                                                                                          child: !cartController.isClearCartLoading
                                                                                                              ? Row(mainAxisSize: MainAxisSize.min, children: [
                                                                                                                  Icon(CupertinoIcons.delete_solid, color: colors.danger, size: AppIcons.sm),
                                                                                                                  const SizedBox(width: AppSpacing.sm),
                                                                                                                  Text(
                                                                                                                    cartController.cartList.length > 1 ? 'remove_all_from_cart'.tr : 'remove_from_cart'.tr,
                                                                                                                    style: AppTypography.labelMd(colors.inkMuted),
                                                                                                                  ),
                                                                                                                ])
                                                                                                              : SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.accent)),
                                                                                                        ),
                                                                                                      ),
                                                                                                    )
                                                                                                  : const SizedBox(),
                                                                                            ]),
                                                                                          )
                                                                                    : const SizedBox(),
                                                                                ConstrainedBox(
                                                                                  constraints: BoxConstraints(maxHeight: isDesktop ? MediaQuery.of(context).size.height * 0.4 : double.infinity),
                                                                                  child: ListView.builder(
                                                                                    physics: isDesktop ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
                                                                                    shrinkWrap: true,
                                                                                    padding: const EdgeInsets.only(
                                                                                      left: AppSpacing.lg,
                                                                                      right: AppSpacing.lg,
                                                                                      top: AppSpacing.lg,
                                                                                    ),
                                                                                    itemCount: cartController.cartList.length,
                                                                                    itemBuilder: (context, index) {
                                                                                      return CartProductWidget(
                                                                                        cart: cartController.cartList[index],
                                                                                        cartIndex: index,
                                                                                        addOns: cartController.addOnsList[index],
                                                                                        isAvailable: cartController.availableList[index],
                                                                                        isRestaurantOpen: isRestaurantOpen,
                                                                                      );
                                                                                    },
                                                                                  ),
                                                                                ),
                                                                                !isRestaurantOpen
                                                                                    ? !isDesktop
                                                                                        ? Align(
                                                                                            alignment: Alignment.center,
                                                                                            child: Padding(
                                                                                              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                                                                                              child: CustomInkWellWidget(
                                                                                                onTap: () {
                                                                                                  cartController.clearCartOnline();
                                                                                                },
                                                                                                child: Container(
                                                                                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                                                                                  decoration: BoxDecoration(
                                                                                                    color: colors.surface,
                                                                                                    borderRadius: AppRadius.xsAll,
                                                                                                    border: Border.all(width: 1, color: colors.line),
                                                                                                  ),
                                                                                                  child: !cartController.isClearCartLoading
                                                                                                      ? Row(mainAxisSize: MainAxisSize.min, children: [
                                                                                                          Icon(CupertinoIcons.delete_solid, color: colors.danger, size: AppIcons.sm),
                                                                                                          const SizedBox(width: AppSpacing.sm),
                                                                                                          Text(cartController.cartList.length > 1 ? 'remove_all_from_cart'.tr : 'remove_from_cart'.tr, style: AppTypography.labelMd(colors.danger)),
                                                                                                        ])
                                                                                                      : SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colors.accent)),
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          )
                                                                                        : const SizedBox()
                                                                                    : const SizedBox(),
                                                                                SizedBox(height: isDesktop ? AppSpacing.x4l : 0),
                                                                                Container(
                                                                                  alignment: Alignment.center,
                                                                                  color: colors.canvas.withValues(alpha: 0.6),
                                                                                  child: TextButton.icon(
                                                                                    onPressed: () {
                                                                                      if (isRestaurantOpen) {
                                                                                        Get.toNamed(
                                                                                          RouteHelper.getRestaurantRoute(cartController.cartList[0].product!.restaurantId),
                                                                                          arguments: RestaurantScreen(restaurant: Restaurant(id: cartController.cartList[0].product!.restaurantId)),
                                                                                        );
                                                                                      } else {
                                                                                        Get.offAllNamed(RouteHelper.getInitialRoute(fromSplash: true));
                                                                                      }
                                                                                    },
                                                                                    icon: Icon(Icons.add_circle_outline_rounded, color: colors.accent, size: AppIcons.sm),
                                                                                    label: Text(
                                                                                      isRestaurantOpen ? 'add_more_items'.tr : 'add_from_another_restaurants'.tr,
                                                                                      style: AppTypography.labelLg(colors.accent),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                SizedBox(height: !isDesktop ? 0 : AppSpacing.sm),
                                                                                !isDesktop ? CartSuggestedItemViewWidget(cartList: cartController.cartList) : const SizedBox(),
                                                                              ]),
                                                                        ),
                                                                        const SizedBox(
                                                                            height:
                                                                                AppSpacing.sm),
                                                                        !isDesktop
                                                                            ? PricingViewWidget(
                                                                                cartController: cartController,
                                                                                isRestaurantOpen: isRestaurantOpen,
                                                                                fromDineIn: widget.fromDineIn,
                                                                              )
                                                                            : const SizedBox(),
                                                                      ]),
                                                                ),
                                                                const SizedBox(
                                                                    height: AppSpacing.sm),
                                                                isDesktop
                                                                    ? CartSuggestedItemViewWidget(
                                                                        cartList:
                                                                            cartController.cartList)
                                                                    : const SizedBox(),
                                                              ]),
                                                        ),
                                                        SizedBox(
                                                            width: isDesktop
                                                                ? AppSpacing.xl
                                                                : 0),
                                                        isDesktop
                                                            ? Expanded(
                                                                flex: 4,
                                                                child: PricingViewWidget(
                                                                    cartController:
                                                                        cartController,
                                                                    isRestaurantOpen:
                                                                        isRestaurantOpen,
                                                                    fromDineIn:
                                                                        widget
                                                                            .fromDineIn))
                                                            : const SizedBox(),
                                                      ]),
                                                ]),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: _height),
                                ],
                              ),
                              onIsExtendedCallback: _onExpanded,
                              onIsContractedCallback: _onContracted,
                              expandableContent: isDesktop
                                  ? const SizedBox()
                                  : Container(
                                      width: context.width,
                                      key:
                                          _widgetKey,
                                      decoration: BoxDecoration(
                                        color: colors.surface,
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(AppRadius.md)),
                                      ),
                                      child: Column(children: [
                                        Container(
                                          padding: const EdgeInsets.only(
                                            left: AppSpacing.lg,
                                            right: AppSpacing.lg,
                                            top: AppSpacing.sm,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colors.surface,
                                            borderRadius: const BorderRadius.vertical(
                                                top: Radius.circular(AppRadius.md)),
                                          ),
                                          child: Column(children: [
                                            _CartSummaryRow(
                                              label: 'item_price'.tr,
                                              value: PriceConverter
                                                  .convertAnimationPrice(
                                                      cartController.itemPrice,
                                                      textStyle: AppTypography.bodyMd(colors.ink)),
                                            ),
                                            const SizedBox(height: AppSpacing.sm),
                                            cartController.variationPrice > 0
                                                ? _CartSummaryRow(
                                                    label: 'variations'.tr,
                                                    value: Text(
                                                        '(+) ${PriceConverter.convertPrice(cartController.variationPrice)}',
                                                        style: AppTypography.bodyMd(colors.ink),
                                                        textDirection: TextDirection.ltr),
                                                  )
                                                : const SizedBox(),
                                            SizedBox(
                                                height: cartController
                                                            .variationPrice >
                                                        0
                                                    ? AppSpacing.sm
                                                    : 0),
                                            _CartSummaryRow(
                                              label: 'discount'.tr,
                                              value: restaurantController
                                                          .restaurant !=
                                                      null
                                                  ? Row(children: [
                                                      Text('(-) ',
                                                          style: AppTypography.bodyMd(colors.ink)),
                                                      PriceConverter
                                                          .convertAnimationPrice(
                                                              cartController
                                                                  .displayDiscount,
                                                              textStyle: AppTypography.bodyMd(colors.ink)),
                                                    ])
                                                  : Text('calculating'.tr,
                                                      style: AppTypography.bodyMd(colors.inkMuted)),
                                            ),
                                            const SizedBox(height: AppSpacing.sm),
                                            _CartSummaryRow(
                                              label: 'addons'.tr,
                                              value: Row(children: [
                                                Text('(+)',
                                                    style: AppTypography.bodyMd(colors.ink)),
                                                PriceConverter
                                                    .convertAnimationPrice(
                                                        cartController.addOns,
                                                        textStyle: AppTypography.bodyMd(colors.ink)),
                                              ]),
                                            ),
                                          ]),
                                        ),
                                      ]),
                                    ),
                            ),
                          ),
                          isDesktop
                              ? const SizedBox.shrink()
                              : CheckoutButtonWidget(
                                  cartController: cartController,
                                  availableList: cartController.availableList,
                                  isRestaurantOpen: isRestaurantOpen,
                                  fromDineIn: widget.fromDineIn,
                                ),
                        ],
                      )
                    : SingleChildScrollView(
                        child: FooterViewWidget(
                            child: NoDataScreen(
                                isEmptyCart: true,
                                title: 'you_have_not_add_to_cart_yet'.tr)));
          },
        );
      }),
    );
  }

  Future<void> showReferAndEarnSnackBar() async {
    String text = 'your_referral_discount_added_on_your_first_order'.tr;
    if (Get.find<ProfileController>().userInfoModel != null &&
        Get.find<ProfileController>().userInfoModel!.isValidForDiscount!) {
      showCustomSnackBar(text, isError: false);
    }
  }
}

class _CartSummaryRow extends StatelessWidget {
  const _CartSummaryRow({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTypography.bodyMd(colors.inkMuted)),
        value,
      ],
    );
  }
}
