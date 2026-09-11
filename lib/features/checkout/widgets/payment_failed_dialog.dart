import 'package:toto_user/features/order/controllers/order_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/util/styles.dart';
import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PaymentFailedDialog extends StatelessWidget {
  final String? orderID;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final String? contactPersonNumber;
  final String? failureMessage;
  const PaymentFailedDialog(
      {super.key,
      required this.orderID,
      required this.maxCodOrderAmount,
      required this.orderAmount,
      this.contactPersonNumber,
      this.failureMessage});

  static const String messageDuplicate =
      'A payment with the same amount was recently attempted. Please wait a few minutes and try again.';
  static const String messageCancelled = 'Payment Cancelled';
  static const String messageFailed = 'Payment Failed';

  static String normalizeGatewayMessage(String? raw) {
    final text = (raw ?? '').trim();
    final lower = text.toLowerCase();
    if (lower.contains('2029') ||
        lower.contains('duplicate') ||
        lower.contains('recently attempted')) {
      return messageDuplicate;
    }
    if (lower.contains('cancel')) {
      return messageCancelled;
    }
    if (text.isEmpty || lower.contains('fail') || lower.contains('otp')) {
      return messageFailed;
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
      insetPadding: const EdgeInsets.all(30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 500,
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Image.asset(Images.warning, width: 70, height: 70),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions.paddingSizeLarge),
              child: Text(
                'are_you_agree_with_this_order_fail'.tr,
                textAlign: TextAlign.center,
                style: robotoMedium.copyWith(
                    fontSize: Dimensions.fontSizeExtraLarge, color: Colors.red),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Dimensions.paddingSizeLarge),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.error,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  PaymentFailedDialog.normalizeGatewayMessage(failureMessage),
                  textAlign: TextAlign.center,
                  style: robotoBold.copyWith(
                    fontSize: Dimensions.fontSizeLarge,
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Dimensions.paddingSizeLarge,
                0,
                Dimensions.paddingSizeLarge,
                Dimensions.paddingSizeLarge,
              ),
              child: Text(
                'if_you_do_not_pay'.tr,
                style:
                    robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: Dimensions.paddingSizeLarge),
            GetBuilder<OrderController>(builder: (orderController) {
              return !orderController.isLoading
                  ? Column(children: [
                      Get.find<SplashController>().configModel!.cashOnDelivery!
                          ? CustomButtonWidget(
                              buttonText: 'switch_to_cash_on_delivery'.tr,
                              onPressed: () {
                                if (maxCodOrderAmount == null ||
                                    orderAmount! < maxCodOrderAmount!) {
                                  double total = ((orderAmount! / 100) *
                                      Get.find<SplashController>()
                                          .configModel!
                                          .loyaltyPointItemPurchasePoint!);
                                  orderController.switchToCOD(
                                      orderID, contactPersonNumber,
                                      points: total);
                                } else {
                                  if (Get.isDialogOpen!) {
                                    Get.back();
                                  }
                                  showCustomSnackBar(
                                      '${'you_cant_order_more_then'.tr} ${PriceConverter.convertPrice(maxCodOrderAmount)} ${'in_cash_on_delivery'.tr}');
                                }
                              },
                              radius: Dimensions.radiusSmall,
                              height: 40,
                            )
                          : const SizedBox(),
                      SizedBox(
                          height: Get.find<SplashController>()
                                  .configModel!
                                  .cashOnDelivery!
                              ? Dimensions.paddingSizeLarge
                              : 0),
                      !orderController.isCancelLoading
                          ? TextButton(
                              onPressed: () {
                                Get.find<OrderController>()
                                    .cancelOrder(int.parse(orderID!),
                                        'Digital payment issue')
                                    .then((success) {
                                  if (success) {
                                    Get.offAllNamed(
                                        RouteHelper.getInitialRoute());
                                  } else if (Get.isDialogOpen == true) {
                                    Get.back();
                                  }
                                });
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Theme.of(context)
                                    .disabledColor
                                    .withValues(alpha: 0.3),
                                minimumSize:
                                    const Size(Dimensions.webMaxWidth, 40),
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        Dimensions.radiusSmall)),
                              ),
                              child: Text('cancel_order'.tr,
                                  textAlign: TextAlign.center,
                                  style: robotoBold.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color)),
                            )
                          : const Center(child: CircularProgressIndicator()),
                    ])
                  : const Center(child: CircularProgressIndicator());
            }),
          ]),
        ),
      ),
    );
  }
}
