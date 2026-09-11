import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/checkout/controllers/checkout_controller.dart';
import 'package:toto_user/features/checkout/widgets/condition_check_box.dart';
import 'package:toto_user/features/checkout/widgets/coupon_section.dart';
import 'package:toto_user/features/checkout/widgets/order_place_button.dart';
import 'package:toto_user/features/checkout/widgets/payment_section.dart';
import 'package:toto_user/features/coupon/controllers/coupon_controller.dart';
import 'package:toto_user/features/profile/controllers/profile_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/cart/domain/models/cart_model.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/location/controllers/location_controller.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/common/widgets/custom_text_field_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _AdditionalChargeTooltipWidget extends StatefulWidget {
  const _AdditionalChargeTooltipWidget();

  @override
  State<_AdditionalChargeTooltipWidget> createState() =>
      _AdditionalChargeTooltipWidgetState();
}

class _AdditionalChargeTooltipWidgetState
    extends State<_AdditionalChargeTooltipWidget> {
  late final JustTheController tooltipController;

  @override
  void initState() {
    super.initState();
    tooltipController = JustTheController();
  }

  @override
  void dispose() {
    tooltipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return JustTheTooltip(
      backgroundColor: colors.ink,
      controller: tooltipController,
      preferredDirection: AxisDirection.right,
      tailLength: 14,
      tailBaseWidth: 20,
      content: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Text(
          'We take this fee to make your user experience better and serve you a good service',
          style: AppTypography.bodySm(colors.onAccent),
        ),
      ),
      child: InkWell(
        onTap: () => tooltipController.showTooltip(),
        child: Icon(
          Icons.info_outline,
          size: 16,
          color: colors.inkMuted,
        ),
      ),
    );
  }
}

class BottomSectionWidget extends StatelessWidget {
  final bool isCashOnDeliveryActive;
  final bool isDigitalPaymentActive;
  final bool isOfflinePaymentActive;
  final bool isWalletActive;
  final double total;
  final double subTotal;
  final double discount;
  final CouponController couponController;
  final bool taxIncluded;
  final double tax;
  final double deliveryCharge;
  final double charge;
  final CheckoutController checkoutController;
  final LocationController locationController;
  final bool todayClosed;
  final bool tomorrowClosed;
  final double orderAmount;
  final double? maxCodOrderAmount;
  final int subscriptionQty;
  final double taxPercent;
  final bool fromCart;
  final List<CartModel>? cartList;
  final double price;
  final double addOns;
  final TextEditingController guestNameTextEditingController;
  final TextEditingController guestNumberTextEditingController;
  final TextEditingController guestEmailController;
  final FocusNode guestNumberNode;
  final FocusNode guestEmailNode;
  final ExpansionTileController expansionTileController;
  final JustTheController serviceFeeTooltipController;
  final double referralDiscount;
  final double extraPackagingAmount;
  const BottomSectionWidget({
    super.key,
    required this.isCashOnDeliveryActive,
    required this.isDigitalPaymentActive,
    required this.isWalletActive,
    required this.total,
    required this.subTotal,
    required this.discount,
    required this.couponController,
    required this.taxIncluded,
    required this.tax,
    required this.deliveryCharge,
    required this.checkoutController,
    required this.locationController,
    required this.todayClosed,
    required this.tomorrowClosed,
    required this.orderAmount,
    this.maxCodOrderAmount,
    required this.subscriptionQty,
    required this.taxPercent,
    required this.fromCart,
    required this.cartList,
    required this.price,
    required this.addOns,
    required this.charge,
    required this.guestNameTextEditingController,
    required this.guestNumberTextEditingController,
    required this.guestNumberNode,
    required this.isOfflinePaymentActive,
    required this.guestEmailController,
    required this.guestEmailNode,
    required this.expansionTileController,
    required this.serviceFeeTooltipController,
    required this.referralDiscount,
    required this.extraPackagingAmount,
  });

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isGuestLoggedIn = Get.find<AuthController>().isGuestLoggedIn();
    final colors = AppColors.of(context);
    return Container(
      decoration: isDesktop
          ? BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.mdAll,
              boxShadow: AppShadows.of(context, 1),
              border: Border.all(color: colors.line, width: 1),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        /// Coupon
        isDesktop && !isGuestLoggedIn
            ? CouponSection(
                checkoutController: checkoutController,
                price: price,
                charge: charge,
                discount: discount,
                addOns: addOns,
                deliveryCharge: deliveryCharge,
                total: total,
                margin: EdgeInsets.zero,
              )
            : const SizedBox(),

        isDesktop
            ? Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: pricingView(context, isDesktop),
              )
            : const SizedBox(),

        !isDesktop
            ? Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 0, horizontal: AppSpacing.lg),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      pricingView(context, isDesktop),
                      const SizedBox(height: AppSpacing.xl),
                      PaymentSection(
                        isCashOnDeliveryActive: isCashOnDeliveryActive,
                        isDigitalPaymentActive: isDigitalPaymentActive,
                        isWalletActive: isWalletActive,
                        total: total,
                        checkoutController: checkoutController,
                        isOfflinePaymentActive: isOfflinePaymentActive,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      CouponSection(
                        charge: charge,
                        checkoutController: checkoutController,
                        price: price,
                        discount: discount,
                        addOns: addOns,
                        deliveryCharge: deliveryCharge,
                        total: total,
                        margin: EdgeInsets.zero,
                      ),
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
                      const CheckoutCondition(),
                    ]),
              )
            : const SizedBox(),
        isDesktop
            ? const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: CheckoutCondition(),
              )
            : const SizedBox(),

        isDesktop
            ? Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xl),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'total_amount'.tr,
                              style: AppTypography.labelLg(colors.accent),
                            ),
                            PriceConverter.convertAnimationPrice(
                              total,
                              textStyle: AppTypography.price(colors.accent),
                            ),
                          ]),
                    ),
                    OrderPlaceButton(
                      checkoutController: checkoutController,
                      locationController: locationController,
                      todayClosed: todayClosed,
                      tomorrowClosed: tomorrowClosed,
                      orderAmount: orderAmount,
                      deliveryCharge: deliveryCharge,
                      tax: tax,
                      discount: discount,
                      total: total,
                      maxCodOrderAmount: maxCodOrderAmount,
                      subscriptionQty: subscriptionQty,
                      cartList: cartList,
                      isCashOnDeliveryActive: isCashOnDeliveryActive,
                      isDigitalPaymentActive: isDigitalPaymentActive,
                      isWalletActive: isWalletActive,
                      fromCart: fromCart,
                      guestNumberTextEditingController:
                          guestNumberTextEditingController,
                      guestNameTextEditingController:
                          guestNameTextEditingController,
                      guestNumberNode: guestNumberNode,
                      isOfflinePaymentActive: isOfflinePaymentActive,
                      guestEmailController: guestEmailController,
                      guestEmailNode: guestEmailNode,
                      couponController: couponController,
                      subTotal: subTotal,
                      taxIncluded: taxIncluded,
                      taxPercent: taxPercent,
                      extraPackagingAmount: extraPackagingAmount,
                    ),
                  ],
                ),
              )
            : const SizedBox(),
      ]),
    );
  }

  Widget pricingView(BuildContext context, bool isDesktop) {
    final colors = AppColors.of(context);
    return Container(
      decoration: !isDesktop
          ? BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.mdAll,
              boxShadow: AppShadows.of(context, 1),
              border: Border.all(color: colors.line, width: 1),
            )
          : null,
      padding: !isDesktop
          ? const EdgeInsets.symmetric(horizontal: AppSpacing.sm)
          : EdgeInsets.zero,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          controller: expansionTileController,
          title: Text('order_summary'.tr,
              style: AppTypography.titleSm(colors.ink)),
          trailing: Icon(
              checkoutController.isExpanded
                  ? Icons.arrow_drop_up_rounded
                  : Icons.arrow_drop_down_rounded,
              size: 34,
              color: colors.ink),
          tilePadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          onExpansionChanged: (value) =>
              checkoutController.expandedUpdate(value),
          initiallyExpanded: !isDesktop ? true : true,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Divider(
                  thickness: 0.5,
                  color: colors.line),
              SizedBox(height: !isDesktop ? AppSpacing.sm : 0),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(
                    !checkoutController.subscriptionOrder
                        ? 'subtotal'.tr
                        : 'item_price'.tr,
                    style: AppTypography.bodyMd(colors.inkMuted)),
                Text(PriceConverter.convertPrice(subTotal),
                    style: AppTypography.bodyMd(colors.ink),
                    textDirection: TextDirection.ltr),
              ]),
              const SizedBox(height: AppSpacing.sm),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('discount'.tr,
                    style: AppTypography.bodyMd(colors.inkMuted)),
                Row(children: [
                  Text('(-) ', style: AppTypography.bodyMd(colors.ink)),
                  PriceConverter.convertAnimationPrice(discount,
                      textStyle: AppTypography.bodyMd(colors.ink))
                ]),
              ]),
              const SizedBox(height: AppSpacing.sm),
              (couponController.discount! > 0 || couponController.freeDelivery)
                  ? Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('coupon_discount'.tr,
                                style: AppTypography.bodyMd(colors.inkMuted)),
                            (couponController.coupon != null &&
                                    couponController.coupon!.couponType ==
                                        'free_delivery')
                                ? Text(
                                    'free_delivery'.tr,
                                    style:
                                        AppTypography.bodyMd(colors.accent),
                                  )
                                : Row(children: [
                                    Text('(-) ',
                                        style:
                                            AppTypography.bodyMd(colors.ink)),
                                    Text(
                                      PriceConverter.convertPrice(
                                          couponController.discount),
                                      style: AppTypography.bodyMd(colors.ink),
                                      textDirection: TextDirection.ltr,
                                    )
                                  ]),
                          ]),
                      const SizedBox(height: AppSpacing.sm),
                    ])
                  : const SizedBox(),
              referralDiscount > 0
                  ? Column(children: [
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('referral_discount'.tr,
                                style: AppTypography.bodyMd(colors.inkMuted)),
                            Text(
                              '(-) ${PriceConverter.convertPrice(referralDiscount)}',
                              style: AppTypography.bodyMd(colors.ink),
                              textDirection: TextDirection.ltr,
                            ),
                          ]),
                      const SizedBox(height: AppSpacing.sm),
                    ])
                  : const SizedBox(),
              ((checkoutController.taxIncluded == null) ||
                      taxIncluded ||
                      (checkoutController.orderTax == 0))
                  ? const SizedBox()
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Text('vat_tax'.tr,
                              style: AppTypography.bodyMd(colors.inkMuted)),
                          Text(('(+) ') + PriceConverter.convertPrice(tax),
                              style: AppTypography.bodyMd(colors.ink),
                              textDirection: TextDirection.ltr),
                        ]),
              SizedBox(
                  height: ((checkoutController.taxIncluded == null) ||
                          taxIncluded ||
                          (checkoutController.orderTax == 0))
                      ? 0
                      : AppSpacing.sm),
              (checkoutController.orderType != 'take_away' &&
                      checkoutController.orderType != 'dine_in' &&
                      Get.find<SplashController>().configModel!.dmTipsStatus ==
                          1 &&
                      !checkoutController.subscriptionOrder)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('delivery_man_tips'.tr,
                            style: AppTypography.bodyMd(colors.inkMuted)),
                        Row(children: [
                          Text('(+) ',
                              style: AppTypography.bodyMd(colors.ink)),
                          PriceConverter.convertAnimationPrice(
                              checkoutController.tips,
                              textStyle: AppTypography.bodyMd(colors.ink))
                        ]),
                      ],
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                  height: checkoutController.orderType != 'take_away' &&
                          checkoutController.orderType != 'dine_in' &&
                          Get.find<SplashController>()
                                  .configModel!
                                  .dmTipsStatus ==
                              1 &&
                          !checkoutController.subscriptionOrder
                      ? AppSpacing.sm
                      : 0.0),
              (extraPackagingAmount > 0)
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('extra_packaging'.tr,
                            style: AppTypography.bodyMd(colors.inkMuted)),
                        Text(
                            '(+) ${PriceConverter.convertPrice(checkoutController.restaurant!.extraPackagingAmount!)}',
                            style: AppTypography.bodyMd(colors.ink),
                            textDirection: TextDirection.ltr),
                      ],
                    )
                  : const SizedBox.shrink(),
              SizedBox(
                  height: extraPackagingAmount > 0 ? AppSpacing.sm : 0),
              checkoutController.orderType != 'take_away' &&
                      checkoutController.orderType != 'dine_in'
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Text('delivery_fee'.tr,
                              style: AppTypography.bodyMd(colors.inkMuted)),
                          checkoutController.distance == -1
                              ? Text(
                                  'calculating'.tr,
                                  style: AppTypography.bodyMd(colors.danger),
                                )
                              : (deliveryCharge == 0 ||
                                      (couponController.coupon != null &&
                                          couponController.coupon!.couponType ==
                                              'free_delivery'))
                                  ? Text(
                                      'free'.tr,
                                      style:
                                          AppTypography.bodyMd(colors.accent),
                                    )
                                  : Row(children: [
                                      Text('(+) ',
                                          style: AppTypography.bodyMd(
                                              colors.ink)),
                                      Text(
                                        PriceConverter.convertPrice(
                                            deliveryCharge),
                                        style:
                                            AppTypography.bodyMd(colors.ink),
                                        textDirection: TextDirection.ltr,
                                      )
                                    ]),
                        ])
                  : const SizedBox(),
              SizedBox(
                  height: checkoutController.orderType != 'take_away' &&
                          checkoutController.orderType != 'dine_in'
                      ? AppSpacing.sm
                      : 0),
              Get.find<SplashController>().configModel!.additionalChargeStatus!
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Row(children: [
                            Text(
                                Get.find<SplashController>()
                                    .configModel!
                                    .additionalChargeName!,
                                style: AppTypography.bodyMd(colors.inkMuted)),
                            const SizedBox(width: AppSpacing.xs),
                            const _AdditionalChargeTooltipWidget(),
                          ]),
                          Text(
                            '(+) ${PriceConverter.convertPrice(Get.find<SplashController>().configModel!.additionCharge)}',
                            style: AppTypography.bodyMd(colors.ink),
                            textDirection: TextDirection.ltr,
                          ),
                        ])
                  : const SizedBox(),
              SizedBox(
                  height: Get.find<SplashController>()
                          .configModel!
                          .additionalChargeStatus!
                      ? AppSpacing.sm
                      : 0),
              (isDesktop || checkoutController.isPartialPay) &&
                      checkoutController.subscriptionOrder
                  ? Column(
                      children: [
                        Divider(thickness: 1, color: colors.line),
                        Row(children: [
                          Text(
                            checkoutController.subscriptionOrder
                                ? 'subtotal'.tr
                                : 'total_amount'.tr,
                            style: AppTypography.labelLg(
                                checkoutController.isPartialPay
                                    ? colors.ink
                                    : colors.accent),
                          ),
                          (checkoutController.taxIncluded == 1)
                              ? Text(' ${'vat_tax_inc'.tr}',
                                  style: AppTypography.labelSm(colors.accent))
                              : const SizedBox(),
                          const Expanded(child: SizedBox()),
                          PriceConverter.convertAnimationPrice(
                            total,
                            textStyle: AppTypography.price(
                                checkoutController.isPartialPay
                                    ? colors.ink
                                    : colors.accent),
                          ),
                        ]),
                      ],
                    )
                  : const SizedBox(),
              !isDesktop && checkoutController.subscriptionOrder
                  ? Column(
                      children: [
                        Divider(thickness: 1, color: colors.line),
                        Row(children: [
                          Text(
                            'subtotal'.tr,
                            style: AppTypography.labelLg(
                                checkoutController.isPartialPay
                                    ? colors.ink
                                    : colors.accent),
                          ),
                          const Expanded(child: SizedBox()),
                          PriceConverter.convertAnimationPrice(
                            total,
                            textStyle: AppTypography.price(
                                checkoutController.isPartialPay
                                    ? colors.ink
                                    : colors.accent),
                          ),
                        ]),
                      ],
                    )
                  : const SizedBox(),
              checkoutController.subscriptionOrder
                  ? Column(children: [
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('subscription_order_count'.tr,
                                style: AppTypography.labelLg(colors.ink)),
                            Text(subscriptionQty.toString(),
                                style: AppTypography.labelLg(colors.ink)),
                          ]),
                      Padding(
                        padding:
                            const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                        child: Divider(thickness: 1, color: colors.line),
                      ),
                    ])
                  : const SizedBox(),
              SizedBox(
                  height: checkoutController.isPartialPay ? AppSpacing.sm : 0),
              checkoutController.isPartialPay &&
                      !checkoutController.subscriptionOrder
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Text('paid_by_wallet'.tr,
                              style: AppTypography.bodyMd(colors.inkMuted)),
                          Text(
                              '(-) ${PriceConverter.convertPrice(Get.find<ProfileController>().userInfoModel!.walletBalance!)}',
                              style: AppTypography.bodyMd(colors.ink),
                              textDirection: TextDirection.ltr),
                        ])
                  : const SizedBox(),
              SizedBox(
                  height: checkoutController.isPartialPay ? AppSpacing.sm : 0),
              checkoutController.isPartialPay &&
                      !checkoutController.subscriptionOrder
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                          Text(
                            'due_payment'.tr,
                            style: AppTypography.labelLg(
                                !isDesktop ? colors.ink : colors.accent),
                          ),
                          PriceConverter.convertAnimationPrice(
                            checkoutController.viewTotalPrice,
                            textStyle: AppTypography.price(
                                !isDesktop ? colors.ink : colors.accent),
                          )
                        ])
                  : const SizedBox(),
              isDesktop && !checkoutController.subscriptionOrder
                  ? Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Divider(thickness: 1, color: colors.line),
                    )
                  : const SizedBox(),
              const SizedBox(height: AppSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(
                    top: AppSpacing.xs, bottom: AppSpacing.sm),
                child: Text(
                  'N.B. Prices may be rounded to the nearest taka for calculation convenience.',
                  style: AppTypography.bodySm(colors.inkFaint)
                      .copyWith(fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}
