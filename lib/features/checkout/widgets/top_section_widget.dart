import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/auth/widgets/auth_dialog_widget.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/cart/widgets/new_cart_product_widget.dart';
import 'package:toto_user/features/checkout/controllers/checkout_controller.dart';
import 'package:toto_user/features/checkout/widgets/delivery_man_tips_section.dart';
import 'package:toto_user/features/checkout/widgets/delivery_option_button.dart';
import 'package:toto_user/features/checkout/widgets/delivery_section.dart';
import 'package:toto_user/features/checkout/widgets/estimated_arrival_time_widget.dart';
import 'package:toto_user/features/checkout/widgets/guest_login_widget.dart';
import 'package:toto_user/features/checkout/widgets/order_type_widget.dart';
import 'package:toto_user/features/checkout/widgets/payment_section.dart';
import 'package:toto_user/features/checkout/widgets/subscription_view.dart';
import 'package:toto_user/features/checkout/widgets/time_slot_section.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/location/controllers/location_controller.dart';
import 'package:toto_user/helper/auth_helper.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_text_field_widget.dart';
import 'package:toto_user/common/widgets/product_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';

class TopSectionWidget extends StatelessWidget {
  final double charge;
  final double deliveryCharge;
  final LocationController locationController;
  final bool tomorrowClosed;
  final bool todayClosed;
  final double price;
  final double discount;
  final double addOns;
  final bool restaurantSubscriptionActive;
  final bool showTips;
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final bool fromCart;
  final double total;
  final JustTheController tooltipController3;
  final JustTheController tooltipController2;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final JustTheController loginTooltipController;
  final Function() callBack;
  final String deliveryChargeForView;
  final JustTheController deliveryFeeTooltipController;
  final double badWeatherCharge;
  final double extraChargeForToolTip;
  final ScrollController deliveryOptionScrollController;

  const TopSectionWidget(
      {super.key,
      required this.charge,
      required this.deliveryCharge,
      required this.locationController,
      required this.tomorrowClosed,
      required this.todayClosed,
      required this.price,
      required this.discount,
      required this.addOns,
      required this.restaurantSubscriptionActive,
      required this.showTips,
      required this.isCashOnDeliveryActive,
      required this.isDigitalPaymentActive,
      required this.isWalletActive,
      required this.fromCart,
      required this.total,
      required this.tooltipController3,
      required this.tooltipController2,
      required this.guestNameTextEditingController,
      required this.guestNumberTextEditingController,
      required this.guestNumberNode,
      required this.isOfflinePaymentActive,
      required this.guestEmailController,
      required this.guestEmailNode,
      required this.loginTooltipController,
      required this.callBack,
      required this.deliveryChargeForView,
      required this.deliveryFeeTooltipController,
      required this.badWeatherCharge,
      required this.extraChargeForToolTip,
      required this.deliveryOptionScrollController});

  @override
  Widget build(BuildContext context) {
    bool takeAway = false;
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    CartController cartController = Get.find<CartController>();
    final colors = AppColors.of(context);

    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

    BoxDecoration softCard = BoxDecoration(
      color: colors.surface,
      borderRadius: AppRadius.mdAll,
      boxShadow: AppShadows.of(context, 1),
      border: Border.all(color: colors.line, width: 1),
    );

    return GetBuilder<CheckoutController>(builder: (checkoutController) {
      takeAway = (checkoutController.orderType == 'take_away');
      return Column(children: [
        SizedBox(height: isGuestLoggedIn && !isDesktop ? AppSpacing.sm : 0),

        isGuestLoggedIn
            ? GuestLoginWidget(
                loginTooltipController: loginTooltipController,
                onTap: () async {
                  if (!isDesktop) {
                    await Get.toNamed(
                            RouteHelper.getSignInRoute(Get.currentRoute))!
                        .then((value) {
                      if (AuthHelper.isLoggedIn()) {
                        callBack();
                      }
                    });
                  } else {
                    Get.dialog(const Center(
                            child: AuthDialogWidget(
                                exitFromApp: false, backFromThis: true)))
                        .then((value) {
                      if (AuthHelper.isLoggedIn()) {
                        callBack();
                      }
                    });
                  }
                },
              )
            : const SizedBox(),
        SizedBox(height: isGuestLoggedIn ? AppSpacing.sm : 0),

        SizedBox(
            height: !isDesktop &&
                    isCashOnDeliveryActive &&
                    restaurantSubscriptionActive
                ? AppSpacing.sm
                : 0),

        isCashOnDeliveryActive && restaurantSubscriptionActive && isLoggedIn
            ? Container(
                width: context.width,
                decoration: softCard,
                margin: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 0 : AppSpacing.lg),
                padding: EdgeInsets.symmetric(
                    vertical: AppSpacing.sm, horizontal: AppSpacing.xl),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('order_type'.tr,
                          style: AppTypography.titleSm(colors.ink)),
                      const SizedBox(height: AppSpacing.xs),
                      Row(children: [
                        Expanded(
                            child: OrderTypeWidget(
                          title: 'regular'.tr,
                          icon: Images.regularOrder,
                          isSelected: !checkoutController.subscriptionOrder,
                          onTap: () {
                            checkoutController.setSubscription(false);
                            if (checkoutController.isPartialPay) {
                              checkoutController.changePartialPayment();
                            } else {
                              checkoutController.setPaymentMethod(-1);
                            }
                            checkoutController.updateTips(
                              checkoutController.getDmTipIndex().isNotEmpty
                                  ? int.parse(
                                      checkoutController.getDmTipIndex())
                                  : 1,
                              notify: false,
                            );
                          },
                        )),
                        SizedBox(
                            width: isCashOnDeliveryActive ? AppSpacing.sm : 0),
                        Expanded(
                            child: OrderTypeWidget(
                          title: 'subscription'.tr,
                          icon: Images.subscriptionOrder,
                          isSelected: checkoutController.subscriptionOrder,
                          onTap: () {
                            checkoutController.setSubscription(true);
                            checkoutController.addTips(0);
                            if (checkoutController.isPartialPay) {
                              checkoutController.changePartialPayment();
                            } else {
                              checkoutController.setPaymentMethod(-1);
                            }
                          },
                        )),
                      ]),
                      const SizedBox(height: AppSpacing.lg),
                      checkoutController.subscriptionOrder
                          ? SubscriptionView(
                              checkoutController: checkoutController,
                            )
                          : const SizedBox(),
                      SizedBox(
                          height: checkoutController.subscriptionOrder
                              ? AppSpacing.lg
                              : 0),
                    ]),
              )
            : const SizedBox(),
        SizedBox(
            height: ResponsiveHelper.isMobile(context)
                ? AppSpacing.sm
                : isCashOnDeliveryActive &&
                        restaurantSubscriptionActive &&
                        isLoggedIn
                    ? AppSpacing.sm
                    : 0),
        !isDesktop
            ? Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                decoration: softCard,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                      maxHeight: isDesktop
                          ? MediaQuery.of(context).size.height * 0.4
                          : double.infinity),
                  child: ListView.builder(
                    physics: isDesktop
                        ? const AlwaysScrollableScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: cartController.cartList.length,
                    itemBuilder: (context, index) {
                      final cart = cartController.cartList[index];
                      return Column(
                        children: [
                          NewCartProductWidget(
                            cart: cartController.cartList[index],
                            cartIndex: index,
                            addOns: cartController.addOnsList[index],
                            isAvailable: cartController.availableList[index],
                            // isRestaurantOpen: isRestaurantOpen,
                            isRestaurantOpen: true,
                            onTap: () {
                              ResponsiveHelper.isMobile(context)
                                  ? showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (con) =>
                                          ProductBottomSheetWidget(
                                              product: cart.product,
                                              cartIndex: index,
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
                                                cartIndex: index,
                                                cart: cart),
                                          )).then((value) =>
                                      Get.find<CartController>()
                                          .getCartDataOnline());
                            },
                          ),
                          if (index < cartController.cartList.length - 1)
                            Divider(
                              height: 1,
                              thickness: 1,
                              color: colors.line,
                              indent: AppSpacing.lg,
                              endIndent: AppSpacing.lg,
                            ),
                        ],
                      );
                    },
                  ),
                ),
              )
            : const SizedBox(),
        !isDesktop ? const SizedBox(height: AppSpacing.sm) : const SizedBox(),

        checkoutController.restaurant != null
            ? Container(
                width: context.width,
                decoration: softCard,
                margin: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 0 : AppSpacing.lg),
                padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? AppSpacing.xl : AppSpacing.sm,
                    vertical: AppSpacing.sm),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('delivery_option'.tr,
                          style: AppTypography.titleSm(colors.ink)),
                      const SizedBox(height: AppSpacing.lg),
                      SingleChildScrollView(
                          controller: deliveryOptionScrollController,
                          scrollDirection: Axis.horizontal,
                          child: Row(children: [
                            (Get.find<SplashController>()
                                        .configModel!
                                        .homeDelivery! &&
                                    checkoutController.restaurant!.delivery!)
                                ? DeliveryOptionButton(
                                    value: 'delivery',
                                    deliveryPreference: 'standard',
                                    title: 'downstairs_delivery'.tr,
                                    charge: charge,
                                    isFree: checkoutController
                                        .restaurant!.freeDelivery,
                                    total: total,
                                    chargeForView: deliveryChargeForView,
                                    deliveryFeeTooltipController:
                                        deliveryFeeTooltipController,
                                    badWeatherCharge: badWeatherCharge,
                                    extraChargeForToolTip:
                                        extraChargeForToolTip,
                                  )
                                : const SizedBox(),
                            if (Get.find<SplashController>()
                                    .configModel!
                                    .homeDelivery! &&
                                checkoutController.restaurant!.delivery!)
                              const SizedBox(width: AppSpacing.lg),
                            (Get.find<SplashController>()
                                        .configModel!
                                        .homeDelivery! &&
                                    checkoutController.restaurant!.delivery!)
                                ? DeliveryOptionButton(
                                    value: 'delivery',
                                    deliveryPreference: 'front_door',
                                    title: 'delivery_to_front_door'.tr,
                                    charge: charge,
                                    isFree: checkoutController
                                        .restaurant!.freeDelivery,
                                    total: total,
                                    chargeForView: deliveryChargeForView,
                                    deliveryFeeTooltipController:
                                        deliveryFeeTooltipController,
                                    badWeatherCharge: badWeatherCharge,
                                    extraChargeForToolTip:
                                        extraChargeForToolTip,
                                  )
                                : const SizedBox(),
                            const SizedBox(width: AppSpacing.lg),
                            (Get.find<SplashController>()
                                        .configModel!
                                        .takeAway! &&
                                    checkoutController.restaurant!.takeAway!)
                                ? DeliveryOptionButton(
                                    value: 'take_away',
                                    title: 'take_away'.tr,
                                    charge: deliveryCharge,
                                    isFree: true,
                                    total: total,
                                    badWeatherCharge: badWeatherCharge,
                                    extraChargeForToolTip:
                                        extraChargeForToolTip,
                                  )
                                : const SizedBox(),
                            const SizedBox(width: AppSpacing.lg),
                            (Get.find<SplashController>()
                                        .configModel!
                                        .dineInOrderOption! &&
                                    checkoutController
                                        .restaurant!.isActiveDineIn!)
                                ? DeliveryOptionButton(
                                    value: 'dine_in',
                                    title: 'dine_in'.tr,
                                    charge: deliveryCharge,
                                    isFree: true,
                                    total: total,
                                    badWeatherCharge: badWeatherCharge,
                                    extraChargeForToolTip:
                                        extraChargeForToolTip,
                                    guestNameTextEditingController:
                                        guestNameTextEditingController,
                                    guestNumberTextEditingController:
                                        guestNumberTextEditingController,
                                    guestEmailController: guestEmailController,
                                  )
                                : const SizedBox(),
                          ])),
                      SizedBox(height: isDesktop ? AppSpacing.lg : 0),
                    ]),
              )
            : const SizedBox(),
        const SizedBox(height: AppSpacing.sm),

        ///Dine in Estimated Arrival Time
        EstimatedArrivalTimeWidget(checkoutController: checkoutController),

        /// Time Slot
        TimeSlotSection(
            fromCart: fromCart,
            checkoutController: checkoutController,
            tomorrowClosed: tomorrowClosed,
            todayClosed: todayClosed,
            tooltipController2: tooltipController2),

        ///Delivery Address
        DeliverySection(
          checkoutController: checkoutController,
          locationController: locationController,
          guestNameTextEditingController: guestNameTextEditingController,
          guestNumberTextEditingController: guestNumberTextEditingController,
          guestNumberNode: guestNumberNode,
          guestEmailController: guestEmailController,
          guestEmailNode: guestEmailNode,
        ),
        const SizedBox(height: AppSpacing.sm),

        ///DmTips
        DeliveryManTipsSection(
          takeAway: takeAway,
          tooltipController3: tooltipController3,
          checkoutController: checkoutController,
          totalPrice: total,
          onTotalChange: (double price) => total + price,
        ),

        ///payment..
        Column(children: [
          isDesktop
              ? PaymentSection(
                  isCashOnDeliveryActive: isCashOnDeliveryActive,
                  isDigitalPaymentActive: isDigitalPaymentActive,
                  isWalletActive: isWalletActive,
                  total: total,
                  checkoutController: checkoutController,
                  isOfflinePaymentActive: isOfflinePaymentActive,
                )
              : const SizedBox(),
        ]),

        isDesktop
            ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: AppSpacing.xl),
                Text('additional_note'.tr,
                    style: AppTypography.titleSm(colors.ink)),
                const SizedBox(height: AppSpacing.sm),
                CustomTextFieldWidget(
                  controller: checkoutController.noteController,
                  hintText: 'share_any_specific_delivery_details_here'.tr,
                  showLabelText: false,
                  maxLines: 3,
                  inputType: TextInputType.multiline,
                  inputAction: TextInputAction.done,
                  capitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: AppSpacing.xl),
              ])
            : const SizedBox(),
      ]);
    });
  }
}
