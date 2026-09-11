import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/order/controllers/order_controller.dart';
import 'package:toto_user/features/order/widgets/cancellation_dialogue.dart';
import 'package:toto_user/features/order/widgets/subscription_pause_dialog.dart';
import 'package:toto_user/features/review/domain/models/rate_review_model.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/order/domain/models/order_details_model.dart';
import 'package:toto_user/features/order/domain/models/order_model.dart';
import 'package:toto_user/helper/address_helper.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/confirmation_dialog_widget.dart';
import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class BottomViewWidget extends StatelessWidget {
  final OrderController orderController;
  final OrderModel order;
  final int? orderId;
  final double total;
  final String? contactNumber;
  const BottomViewWidget({
    super.key,
    required this.orderController,
    required this.order,
    this.orderId,
    required this.total,
    this.contactNumber,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    bool subscription = order.subscription != null;

    bool pending = order.orderStatus == AppConstants.pending;
    bool accepted = order.orderStatus == AppConstants.accepted;
    bool confirmed = order.orderStatus == AppConstants.confirmed;
    bool processing = order.orderStatus == AppConstants.processing;
    bool pickedUp = order.orderStatus == AppConstants.pickedUp;
    bool delivered = order.orderStatus == AppConstants.delivered;
    bool cancelled = order.orderStatus == AppConstants.cancelled;
    bool cod = order.paymentMethod == 'cash_on_delivery';
    bool digitalPay = order.paymentMethod == 'digital_payment';
    bool offlinePay = order.paymentMethod == 'offline_payment';

    return Container(
      decoration: ResponsiveHelper.isDesktop(context)
          ? null
          : BoxDecoration(
              border: Border(top: BorderSide(color: colors.line)),
            ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Column(children: [
        !orderController.showCancelled
            ? Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth + 20,
                  child: Row(children: [
                    ((!subscription ||
                                (order.subscription!.status != 'canceled' &&
                                    order.subscription!.status !=
                                        'completed')) &&
                            ((pending && !digitalPay) ||
                                accepted ||
                                confirmed ||
                                processing ||
                                order.orderStatus == 'handover' ||
                                pickedUp)) &&
                        order.orderType == 'delivery'
                        ? Expanded(
                            child: CustomButtonWidget(
                              buttonText: subscription
                                  ? 'track_subscription'.tr
                                  : 'track_order'.tr,
                              margin: const EdgeInsets.all(AppSpacing.sm),
                              onPressed: () async {
                                orderController.cancelTimer();
                                await Get.toNamed(
                                    RouteHelper.getOrderTrackingRoute(
                                        order.id, contactNumber));
                                orderController.callTrackOrderApi(
                                    orderModel: order,
                                    orderId: orderId.toString(),
                                    contactNumber: contactNumber);
                              },
                            ),
                          )
                        : const SizedBox(),
                    (!offlinePay &&
                            pending &&
                            order.paymentStatus == 'unpaid' &&
                            digitalPay &&
                            Get.find<SplashController>()
                                .configModel!
                                .cashOnDelivery!)
                        ? Expanded(
                            child: CustomButtonWidget(
                              buttonText: 'switch_to_cash_on_delivery'.tr,
                              margin: const EdgeInsets.all(AppSpacing.sm),
                              onPressed: () {
                                Get.dialog(ConfirmationDialogWidget(
                                    icon: Images.warning,
                                    description: 'are_you_sure_to_switch'.tr,
                                    onYesPressed: () {
                                      double maxCodOrderAmount = AddressHelper
                                                  .getAddressFromSharedPref()!
                                              .zoneData!
                                              .firstWhere((data) =>
                                                  data.id ==
                                                  order.restaurant!.zoneId)
                                              .maxCodOrderAmount ??
                                          0;

                                      if (maxCodOrderAmount > total) {
                                        orderController
                                            .switchToCOD(
                                                order.id.toString(), null)
                                            .then((isSuccess) {
                                          Get.back();
                                          if (isSuccess) {
                                            Get.back();
                                          }
                                        });
                                      } else {
                                        if (Get.isDialogOpen!) {
                                          Get.back();
                                        }
                                        showCustomSnackBar(
                                            '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                                      }
                                    }));
                              },
                            ),
                          )
                        : const SizedBox(),
                    (subscription
                            ? (order.subscription!.status == 'active' ||
                                order.subscription!.status == 'paused')
                            : (pending))
                        ? Expanded(
                            child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: TextButton(
                              style: TextButton.styleFrom(
                                minimumSize: const Size(1, 50),
                                foregroundColor: colors.inkMuted,
                                shape: RoundedRectangleBorder(
                                  borderRadius: AppRadius.mdAll,
                                  side: BorderSide(
                                      width: 1.5, color: colors.lineStrong),
                                ),
                              ),
                              onPressed: () {
                                if (subscription) {
                                  Get.dialog(SubscriptionPauseDialog(
                                      subscriptionID: order.subscriptionId,
                                      isPause: false));
                                } else {
                                  orderController.setOrderCancelReason('');
                                  Get.dialog(
                                      CancellationDialogue(orderId: order.id));
                                }
                              },
                              child: Text(
                                subscription
                                    ? 'cancel_subscription'.tr
                                    : 'cancel_order'.tr,
                                style: AppTypography.labelMd(colors.inkMuted),
                              ),
                            ),
                          ))
                        : const SizedBox(),
                  ]),
                ),
              )
            : Center(
                child: Container(
                  width: Dimensions.webMaxWidth,
                  height: 50,
                  margin: const EdgeInsets.all(AppSpacing.sm),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(width: 1.5, color: colors.accent),
                    borderRadius: AppRadius.mdAll,
                    color: colors.accentSoft,
                  ),
                  child: Text(
                    'order_cancelled'.tr,
                    style: AppTypography.labelMd(colors.accent),
                  ),
                ),
              ),
        !orderController.showCancelled &&
                subscription &&
                (order.subscription!.status == 'active' ||
                    order.subscription!.status == 'paused')
            ? CustomButtonWidget(
                buttonText: 'pause_subscription'.tr,
                margin: const EdgeInsets.all(AppSpacing.sm),
                onPressed: () async {
                  Get.dialog(SubscriptionPauseDialog(
                      subscriptionID: order.subscriptionId, isPause: true));
                },
              )
            : const SizedBox(),
        Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: !orderController.isLoading
                  ? Get.find<AuthController>().isLoggedIn()
                      ? Row(
                          children: [
                            (!subscription &&
                                    delivered &&
                                    orderController.orderDetails![0]
                                            .itemCampaignId ==
                                        null)
                                ? Expanded(
                                    child: CustomButtonWidget(
                                      buttonText: 'review'.tr,
                                      onPressed: () async {
                                        List<OrderDetailsModel>
                                            orderDetailsList = [];
                                        List<int?> orderDetailsIdList = [];
                                        for (var orderDetail
                                            in orderController.orderDetails!) {
                                          if (!orderDetailsIdList.contains(
                                              orderDetail.foodDetails!.id)) {
                                            orderDetailsList.add(orderDetail);
                                            orderDetailsIdList.add(
                                                orderDetail.foodDetails!.id);
                                          }
                                        }
                                        orderController.cancelTimer();
                                        RateReviewModel rateReviewModel =
                                            RateReviewModel(
                                                orderDetailsList:
                                                    orderDetailsList,
                                                deliveryMan: order.deliveryMan);
                                        await Get.toNamed(
                                            RouteHelper.getReviewRoute(
                                                rateReviewModel));
                                        orderController.callTrackOrderApi(
                                            orderModel: order,
                                            orderId: orderId.toString(),
                                            contactNumber: contactNumber);
                                      },
                                    ),
                                  )
                                : const SizedBox(),
                            SizedBox(
                                width: cancelled ||
                                        order.orderStatus == 'failed'
                                    ? 0
                                    : AppSpacing.sm),
                            !subscription &&
                                    Get.find<SplashController>()
                                        .configModel!
                                        .repeatOrderOption! &&
                                    (delivered ||
                                        cancelled ||
                                        order.orderStatus == 'failed' ||
                                        order.orderStatus ==
                                            'refund_request_canceled')
                                ? orderController
                                            .orderDetails![0].itemCampaignId ==
                                        null
                                    ? Expanded(
                                        child: CustomButtonWidget(
                                          buttonText: 'reorder'.tr,
                                          onPressed: () =>
                                              orderController.reOrder(
                                                  orderController.orderDetails!,
                                                  order.restaurant!.zoneId),
                                        ),
                                      )
                                    : const SizedBox()
                                : const SizedBox(),
                          ],
                        )
                      : const SizedBox()
                  : Center(
                      child: CircularProgressIndicator(color: colors.accent)),
            ),
          ),
        ),
        (!offlinePay &&
                (order.orderStatus == 'failed' || cancelled) &&
                !cod &&
                Get.find<SplashController>().configModel!.cashOnDelivery!)
            ? Center(
                child: Container(
                  width: Dimensions.webMaxWidth,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: CustomButtonWidget(
                    buttonText: 'switch_to_cash_on_delivery'.tr,
                    onPressed: () {
                      Get.dialog(ConfirmationDialogWidget(
                          icon: Images.warning,
                          description: 'are_you_sure_to_switch'.tr,
                          onYesPressed: () {
                            double? maxCodOrderAmount = AddressHelper
                                    .getAddressFromSharedPref()!
                                .zoneData!
                                .firstWhere((data) =>
                                    data.id == order.restaurant!.zoneId)
                                .maxCodOrderAmount;

                            if (maxCodOrderAmount == null ||
                                maxCodOrderAmount > total) {
                              orderController
                                  .switchToCOD(order.id.toString(), null)
                                  .then((isSuccess) {
                                Get.back();
                                if (isSuccess) {
                                  Get.back();
                                }
                              });
                            } else {
                              if (Get.isDialogOpen!) {
                                Get.back();
                              }
                              showCustomSnackBar(
                                  '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                            }
                          }));
                    },
                  ),
                ),
              )
            : const SizedBox(),
      ]),
    );
  }
}
