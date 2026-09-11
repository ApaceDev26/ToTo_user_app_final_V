import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/checkout/widgets/offline_success_dialog.dart';
import 'package:toto_user/features/order/controllers/order_controller.dart';
import 'package:toto_user/features/order/domain/models/subscription_schedule_model.dart';
import 'package:toto_user/features/order/widgets/bottom_view_widget.dart';
import 'package:toto_user/features/order/widgets/order_info_section.dart';
import 'package:toto_user/features/order/widgets/order_pricing_section.dart';
import 'package:toto_user/features/order/domain/models/order_details_model.dart';
import 'package:toto_user/features/order/domain/models/order_model.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/custom_dialog_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderDetailsScreen extends StatefulWidget {
  final OrderModel? orderModel;
  final int? orderId;
  final bool fromOfflinePayment;
  final String? contactNumber;
  final bool fromGuestTrack;
  final bool fromNotification;
  final bool fromDineIn;
  const OrderDetailsScreen({
    super.key,
    required this.orderModel,
    required this.orderId,
    this.contactNumber,
    this.fromOfflinePayment = false,
    this.fromGuestTrack = false,
    this.fromNotification = false,
    this.fromDineIn = false,
  });

  @override
  OrderDetailsScreenState createState() => OrderDetailsScreenState();
}

class OrderDetailsScreenState extends State<OrderDetailsScreen>
    with WidgetsBindingObserver {
  final ScrollController scrollController = ScrollController();

  void _loadData() async {
    await Get.find<OrderController>()
        .trackOrder(widget.orderId.toString(), widget.orderModel, false,
            contactNumber: widget.contactNumber)
        .then((value) {
      if (widget.fromOfflinePayment) {
        Future.delayed(
            const Duration(seconds: 2),
            () => showAnimatedDialog(
                Get.context!, OfflineSuccessDialog(orderId: widget.orderId)));
      } else if (widget.fromDineIn) {
        Future.delayed(
            const Duration(seconds: 2),
            () => showAnimatedDialog(
                Get.context!,
                OfflineSuccessDialog(
                    orderId: widget.orderId, isDineIn: true)));
      }
    });
    Get.find<OrderController>().getOrderCancelReasons();
    Get.find<OrderController>().getOrderDetails(widget.orderId.toString());
    if (Get.find<OrderController>().trackModel != null) {
      Get.find<OrderController>().callTrackOrderApi(
          orderModel: Get.find<OrderController>().trackModel!,
          orderId: widget.orderId.toString(),
          contactNumber: widget.contactNumber);
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadData();
  }

  @override
  void didChangeAppLifecycleState(final AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      Get.find<OrderController>().callTrackOrderApi(
          orderModel: Get.find<OrderController>().trackModel!,
          orderId: widget.orderId.toString(),
          contactNumber: widget.contactNumber);
    } else if (state == AppLifecycleState.paused) {
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    Get.find<OrderController>().cancelTimer();
    scrollController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (((widget.orderModel == null || widget.fromOfflinePayment) &&
            !widget.fromGuestTrack) ||
        widget.fromNotification) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
    } else if (widget.fromGuestTrack) {
      Get.back();
    } else {
      safeBack();
    }
  }

  Color _statusColor(AppColors colors, String? status) {
    switch (status) {
      case 'delivered':
      case 'refunded':
        return colors.success;
      case 'canceled':
      case 'cancelled':
      case 'failed':
      case 'refund_request_canceled':
        return colors.danger;
      case 'refund_requested':
      case 'pending':
        return colors.warning;
      default:
        return colors.accent;
    }
  }

  String _statusMessage(OrderModel order, {required bool subscription}) {
    if (subscription) {
      return '${'your_order_is'.tr} ${order.orderStatus}';
    }
    switch (order.orderStatus) {
      case 'pending':
      case 'confirmed':
        return '${'your_order_is'.tr} ${order.orderStatus?.tr}';
      case 'processing':
        return 'your_food_is_cooking'.tr;
      case 'handover':
        return 'your_food_is_ready'.tr;
      case 'canceled':
      case 'cancelled':
        return 'your_order_is_canceled'.tr;
      default:
        return 'your_food_is_served'.tr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (((widget.orderModel == null || widget.fromOfflinePayment) &&
                !widget.fromGuestTrack) ||
            widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        }
      },
      child: GetBuilder<OrderController>(builder: (orderController) {
        double? deliveryCharge = 0;
        double itemsPrice = 0;
        double? discount = 0;
        double? couponDiscount = 0;
        double? tax = 0;
        double addOns = 0;
        double? dmTips = 0;
        double additionalCharge = 0;
        double extraPackagingCharge = 0;
        double referrerBonusAmount = 0;
        bool showChatPermission = true;
        bool? taxIncluded = false;
        OrderModel? order = orderController.trackModel;
        bool subscription = false;
        bool isDineIn = false;
        List<String> schedules = [];

        if (orderController.orderDetails != null && order != null) {
          isDineIn = order.orderType == 'dine_in';
          subscription = order.subscription != null;

          if (subscription) {
            if (order.subscription!.type == 'weekly') {
              List<String> weekDays = [
                'sunday',
                'monday',
                'tuesday',
                'wednesday',
                'thursday',
                'friday',
                'saturday'
              ];
              for (SubscriptionScheduleModel schedule
                  in orderController.schedules!) {
                schedules.add(
                    '${weekDays[schedule.day!].tr} (${DateConverter.convertTimeToTime(schedule.time!)})');
              }
            } else if (order.subscription!.type == 'monthly') {
              for (SubscriptionScheduleModel schedule
                  in orderController.schedules!) {
                schedules.add(
                    '${'day_capital'.tr} ${schedule.day} (${DateConverter.convertTimeToTime(schedule.time!)})');
              }
            } else {
              schedules.add(DateConverter.convertTimeToTime(
                  orderController.schedules![0].time!));
            }
          }
          if (order.orderType == 'delivery') {
            deliveryCharge = order.deliveryCharge;
            dmTips = order.dmTips;
          }
          couponDiscount = order.couponDiscountAmount;
          discount = order.restaurantDiscountAmount;
          tax = order.totalTaxAmount;
          taxIncluded = order.taxStatus;
          additionalCharge = order.additionalCharge!;
          extraPackagingCharge = order.extraPackagingAmount!;
          referrerBonusAmount = order.referrerBonusAmount!;
          for (OrderDetailsModel orderDetails
              in orderController.orderDetails!) {
            for (AddOn addOn in orderDetails.addOns!) {
              addOns = addOns + (addOn.price! * addOn.quantity!);
            }
            itemsPrice =
                itemsPrice + (orderDetails.price! * orderDetails.quantity!);
          }
          if (order.restaurant != null) {
            if (order.restaurant!.restaurantModel == 'commission') {
              showChatPermission = true;
            } else if (order.restaurant!.restaurantSubscription != null &&
                order.restaurant!.restaurantSubscription!.chat == 1) {
              showChatPermission = true;
            } else {
              showChatPermission = false;
            }
          }
        }
        double subTotal = itemsPrice + addOns;
        double total = itemsPrice +
            addOns -
            discount! +
            (taxIncluded! ? 0 : tax!) +
            deliveryCharge! -
            couponDiscount! +
            dmTips! +
            additionalCharge +
            extraPackagingCharge -
            referrerBonusAmount;

        final colors = AppColors.of(context);
        final pageTitle = subscription
            ? 'subscription_details'.tr
            : 'order_details'.tr;

        return Scaffold(
          backgroundColor: colors.canvas,
          appBar: CustomAppBarWidget(
            title: pageTitle,
            onBackPressed: _handleBack,
          ),
          endDrawer: const MenuDrawerWidget(),
          endDrawerEnableOpenDragGesture: false,
          body: SafeArea(
            child: (order != null && orderController.orderDetails != null)
                ? Column(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: FooterViewWidget(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: Dimensions.webMaxWidth,
                                ),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: isDesktop
                                        ? AppSpacing.xl
                                        : AppSpacing.lg,
                                    vertical: AppSpacing.lg,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _OrderStatusHero(
                                        order: order,
                                        subscription: subscription,
                                        isDineIn: isDineIn,
                                        statusColor: _statusColor(
                                            colors, order.orderStatus),
                                        statusMessage: _statusMessage(order,
                                            subscription: subscription),
                                        colors: colors,
                                      ),
                                      const SizedBox(height: AppSpacing.lg),
                                      if (order.orderStatus ==
                                              'refund_requested' ||
                                          order.orderStatus == 'refunded' ||
                                          order.orderStatus ==
                                              'refund_request_canceled') ...[
                                        _RefundBanner(
                                            order: order, colors: colors),
                                        const SizedBox(height: AppSpacing.lg),
                                      ],
                                      if (isDesktop)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              flex: 6,
                                              child: OrderInfoSection(
                                                order: order,
                                                orderController:
                                                    orderController,
                                                schedules: schedules,
                                                showChatPermission:
                                                    showChatPermission,
                                                contactNumber:
                                                    widget.contactNumber,
                                                totalAmount: total,
                                              ),
                                            ),
                                            const SizedBox(
                                                width: AppSpacing.xl),
                                            Expanded(
                                              flex: 4,
                                              child: OrderPricingSection(
                                                itemsPrice: itemsPrice,
                                                addOns: addOns,
                                                order: order,
                                                subTotal: subTotal,
                                                discount: discount,
                                                couponDiscount: couponDiscount,
                                                tax: tax!,
                                                dmTips: dmTips,
                                                deliveryCharge: deliveryCharge,
                                                total: total,
                                                orderController:
                                                    orderController,
                                                orderId: widget.orderId,
                                                contactNumber:
                                                    widget.contactNumber,
                                                extraPackagingAmount:
                                                    extraPackagingCharge,
                                                referrerBonusAmount:
                                                    referrerBonusAmount,
                                              ),
                                            ),
                                          ],
                                        )
                                      else ...[
                                        OrderInfoSection(
                                          order: order,
                                          orderController: orderController,
                                          schedules: schedules,
                                          showChatPermission:
                                              showChatPermission,
                                          contactNumber: widget.contactNumber,
                                          totalAmount: total,
                                        ),
                                        const SizedBox(height: AppSpacing.md),
                                        OrderPricingSection(
                                          itemsPrice: itemsPrice,
                                          addOns: addOns,
                                          order: order,
                                          subTotal: subTotal,
                                          discount: discount,
                                          couponDiscount: couponDiscount,
                                          tax: tax!,
                                          dmTips: dmTips,
                                          deliveryCharge: deliveryCharge,
                                          total: total,
                                          orderController: orderController,
                                          orderId: widget.orderId,
                                          contactNumber: widget.contactNumber,
                                          extraPackagingAmount:
                                              extraPackagingCharge,
                                          referrerBonusAmount:
                                              referrerBonusAmount,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isDesktop)
                        Material(
                          color: colors.surface,
                          elevation: 8,
                          shadowColor: colors.ink.withValues(alpha: 0.08),
                          child: SafeArea(
                            top: false,
                            child: BottomViewWidget(
                              orderController: orderController,
                              order: order,
                              orderId: widget.orderId,
                              total: total,
                              contactNumber: widget.contactNumber,
                            ),
                          ),
                        ),
                    ],
                  )
                : _OrderDetailsLoading(colors: colors),
          ),
        );
      }),
    );
  }
}

class _OrderStatusHero extends StatelessWidget {
  const _OrderStatusHero({
    required this.order,
    required this.subscription,
    required this.isDineIn,
    required this.statusColor,
    required this.statusMessage,
    required this.colors,
  });

  final OrderModel order;
  final bool subscription;
  final bool isDineIn;
  final Color statusColor;
  final String statusMessage;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: colors.line),
        boxShadow: AppShadows.of(context, 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: AppRadius.mdAll,
                ),
                child: Icon(
                  subscription
                      ? Icons.autorenew_rounded
                      : isDineIn
                          ? Icons.restaurant_rounded
                          : Icons.receipt_long_rounded,
                  color: statusColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subscription
                          ? '${'subscription'.tr} #${order.id}'
                          : '${'order'.tr} #${order.id}',
                      style: AppTypography.displayMd(colors.ink).copyWith(
                        fontSize: ResponsiveHelper.isDesktop(context) ? 26 : 22,
                        height: 1.2,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      statusMessage,
                      style: AppTypography.bodyMd(colors.inkMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: AppRadius.pillAll,
            ),
            child: Text(
              (order.orderStatus ?? '').tr.replaceAll('_', ' '),
              style: AppTypography.labelMd(statusColor),
            ),
          ),
        ],
      ),
    );
  }
}

class _RefundBanner extends StatelessWidget {
  const _RefundBanner({required this.order, required this.colors});

  final OrderModel order;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final isRequested = order.orderStatus == 'refund_requested';
    final isRefunded = order.orderStatus == 'refunded';
    final tone =
        isRequested ? colors.warning : isRefunded ? colors.success : colors.danger;
    final icon = isRequested
        ? Icons.pending_outlined
        : isRefunded
            ? Icons.check_circle_outline
            : Icons.cancel_outlined;
    final title = isRequested
        ? 'refund_requested'.tr
        : isRefunded
            ? 'refunded'.tr
            : 'refund_request_canceled'.tr;
    final chip = isRequested
        ? 'pending'.tr
        : isRefunded
            ? 'refunded'.tr
            : 'canceled'.tr;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: tone.withValues(alpha: 0.35)),
        boxShadow: AppShadows.of(context, 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: tone, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(title, style: AppTypography.titleSm(colors.ink)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: tone.withValues(alpha: 0.12),
                  borderRadius: AppRadius.pillAll,
                ),
                child: Text(chip, style: AppTypography.labelMd(tone)),
              ),
            ],
          ),
          if (order.refund != null) ...[
            if (order.refund!.customerReason != null &&
                order.refund!.customerReason!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              Text(
                '${'refund_note'.tr}: ${order.refund!.customerReason!}',
                style: AppTypography.bodySm(colors.inkMuted),
              ),
            ],
            if (order.refundRequested != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${'refund_requested'.tr} ${DateConverter.dateTimeStringToDateTime(order.refundRequested!)}',
                style: AppTypography.bodySm(colors.inkMuted),
              ),
            ],
            if (isRefunded && order.refunded != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                '${'refunded'.tr} ${DateConverter.dateTimeStringToDateTime(order.refunded!)}',
                style: AppTypography.bodySm(colors.inkMuted),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _OrderDetailsLoading extends StatelessWidget {
  const _OrderDetailsLoading({required this.colors});
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(
            color: colors.accent,
            backgroundColor: colors.accentSoft,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'loading'.tr,
            style: AppTypography.bodyMd(colors.inkMuted),
          ),
        ],
      ),
    );
  }
}
