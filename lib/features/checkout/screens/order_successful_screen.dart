import 'dart:async';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:toto_user/features/order/controllers/order_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/splash/controllers/theme_controller.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/location/domain/models/zone_response_model.dart';
import 'package:toto_user/helper/address_helper.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderSuccessfulScreen extends StatefulWidget {
  final String? orderID;
  final int status;
  final double? totalAmount;
  final String? contactPersonNumber;
  final bool isDeliveryOrder;
  final String? failureMessage;
  const OrderSuccessfulScreen({super.key, required this.orderID, required this.status, required this.totalAmount, this.contactPersonNumber, this.isDeliveryOrder = false, this.failureMessage});

  @override
  State<OrderSuccessfulScreen> createState() => _OrderSuccessfulScreenState();
}

class _OrderSuccessfulScreenState extends State<OrderSuccessfulScreen> {
  String? orderId;
  final ScrollController scrollController = ScrollController();
  bool _paymentFailedDialogShown = false;

  @override
  void initState() {
    super.initState();

    orderId = widget.orderID!;
    if(widget.orderID != null) {
      if(widget.orderID!.contains('?')){
        var parts = widget.orderID!.split('?');
        String id = parts[0].trim();                 // prefix: "date"
        orderId = id;
      }
    }
    Get.find<OrderController>().trackOrder(orderId.toString(), null, false, contactNumber: widget.contactPersonNumber);

  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        double total = 0;
        bool success = true;
        double? maximumCodOrderAmount;
        if(orderController.trackModel != null) {
          ZoneData zoneData = AddressHelper.getAddressFromSharedPref()!.zoneData!.firstWhere((data) => data.id == AddressHelper.getAddressFromSharedPref()!.zoneId);
          maximumCodOrderAmount = zoneData.maxCodOrderAmount;
          total = ((orderController.trackModel!.orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
          success = orderController.trackModel!.paymentStatus == 'paid' || orderController.trackModel!.paymentMethod == 'cash_on_delivery' || orderController.trackModel!.paymentMethod == 'partial_payment';

          if (!success && !_paymentFailedDialogShown && orderController.trackModel!.orderStatus != 'canceled' && Get.currentRoute.startsWith(RouteHelper.orderSuccess)) {
            _paymentFailedDialogShown = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || Get.isDialogOpen == true) return;
              Get.dialog(
                PaymentFailedDialog(orderID: orderId, orderAmount: total, maxCodOrderAmount: maximumCodOrderAmount, contactPersonNumber: widget.contactPersonNumber, failureMessage: widget.failureMessage),
                barrierDismissible: false,
              );
            });
          }
        }

        return orderController.trackModel != null ? Center(child: SingleChildScrollView(
          controller: scrollController,
          child: FooterViewWidget(
            child: SizedBox(width: Dimensions.webMaxWidth, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: success ? colors.accentSoft : colors.warmSoft,
                ),
                alignment: Alignment.center,
                child: Image.asset(
                  success ? Images.checked : Images.warning,
                  width: 88,
                  height: 88,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              Text(
                success ? 'you_placed_the_order_successfully'.tr : 'your_order_is_failed_to_place'.tr,
                style: AppTypography.titleMd(colors.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              Get.find<AuthController>().isGuestLoggedIn() ? Text(
                '${'order_id'.tr}: $orderId',
                style: AppTypography.titleSm(colors.accent),
              ) : const SizedBox(),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
                child: Text(
                  success ? widget.isDeliveryOrder ? 'your_order_is_placed_successfully'.tr : 'your_order_is_placed_successfully_dine_in_and_takeaway'.tr : 'your_order_is_failed_to_place_because'.tr,
                  style: AppTypography.bodyMd(colors.inkMuted),
                  textAlign: TextAlign.center,
                ),
              ),

              Get.find<AuthController>().isLoggedIn() && ResponsiveHelper.isDesktop(context) && (success && Get.find<SplashController>().configModel!.loyaltyPointStatus == 1 && total.floor() > 0 )  ? Container(
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
                padding: const EdgeInsets.all(AppSpacing.x2l),
                decoration: BoxDecoration(
                  color: colors.warmSoft,
                  borderRadius: AppRadius.lgAll,
                ),
                child: Column(children: [

                Image.asset(Get.find<ThemeController>().darkTheme ? Images.giftBox1 : Images.giftBox, width: 150, height: 150),

                Text('congratulations'.tr , style: AppTypography.titleMd(colors.ink)),
                const SizedBox(height: AppSpacing.sm),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Text(
                    '${'you_have_earned'.tr} ${total.floor().toString()} ${'points_it_will_add_to'.tr}',
                    style: AppTypography.bodyLg(colors.inkMuted),
                    textAlign: TextAlign.center,
                  ),
                ),

              ])) : const SizedBox.shrink() ,
              const SizedBox(height: AppSpacing.x3l),

              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: CustomButtonWidget(
                  width: ResponsiveHelper.isDesktop(context) ? 300 : double.infinity,
                  buttonText: 'back_to_home'.tr,
                  onPressed: () => Get.offAllNamed(RouteHelper.getInitialRoute()),
                ),
              ),

            ])),
          ),
        )) : Center(
          child: CircularProgressIndicator(
            color: colors.accent,
            backgroundColor: colors.accentSoft,
          ),
        );
      }),
    );
  }
}
