import 'dart:async';
import 'package:toto_user/features/checkout/widgets/payment_failed_dialog.dart';
import 'package:toto_user/features/dashboard/controllers/dashboard_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/order/domain/models/order_model.dart';
import 'package:toto_user/features/loyalty/controllers/loyalty_controller.dart';
import 'package:toto_user/features/wallet/widgets/fund_payment_dialog_widget.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';

class PaymentScreen extends StatefulWidget {
  final OrderModel orderModel;
  final String paymentMethod;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String guestId;
  final String contactNumber;
  final int? restaurantId;
  final int? packageId;
  const PaymentScreen({super.key, required this.orderModel, required this.paymentMethod, this.addFundUrl, this.subscriptionUrl,
    required this.guestId, required this.contactNumber, this.restaurantId, this.packageId});

  @override
  PaymentScreenState createState() => PaymentScreenState();
}

class PaymentScreenState extends State<PaymentScreen> {
  late String selectedUrl;
  double value = 0.0;
  final bool _isLoading = true;
  PullToRefreshController? pullToRefreshController;
  late MyInAppBrowser browser;
  double? maxCodOrderAmount;

  @override
  void initState() {
    super.initState();

    if(widget.addFundUrl == '' && widget.addFundUrl!.isEmpty && widget.subscriptionUrl == '' && widget.subscriptionUrl!.isEmpty) {
      selectedUrl = '${AppConstants.baseUrl}/payment-mobile?customer_id=${widget.orderModel.userId == 0 ? widget.guestId : widget.orderModel.userId}&order_id=${widget.orderModel.id}&payment_method=${widget.paymentMethod}';
    } else if(widget.subscriptionUrl != '' && widget.subscriptionUrl!.isNotEmpty){
      selectedUrl = widget.subscriptionUrl!;
    } else {
      selectedUrl = widget.addFundUrl!;
    }
    _initData();
  }

  void _initData() async {
    browser = MyInAppBrowser(orderID: widget.orderModel.id.toString(), orderAmount: widget.orderModel.orderAmount, maxCodOrderAmount: maxCodOrderAmount, addFundUrl: widget.addFundUrl,
        subscriptionUrl: widget.subscriptionUrl, contactNumber: widget.contactNumber, restaurantId: widget.restaurantId, packageId: widget.packageId, isDeliveryOrder: widget.orderModel.orderType == 'delivery');

    await browser.openUrlRequest(
      urlRequest: URLRequest(url: WebUri(selectedUrl)),
      settings: InAppBrowserClassSettings(
        webViewSettings: InAppWebViewSettings(useShouldOverrideUrlLoading: true, useOnLoadResource: true),
        browserSettings: InAppBrowserSettings(hideUrlBar: true, hideToolbarTop: GetPlatform.isAndroid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _exitApp();
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).cardColor,
        appBar: CustomAppBarWidget(title: 'payment'.tr, onBackPressed: () => _exitApp()),
        endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
        body: Center(
          child: SizedBox(
            width: Dimensions.webMaxWidth,
            child: Stack(
              children: [
                _isLoading ? Center(
                  child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor)),
                ) : const SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _exitApp() async {
    if (!mounted || Get.isDialogOpen == true) return;
    final addFund = widget.addFundUrl;
    final sub = widget.subscriptionUrl;
    final isOrderPay = (addFund == null || addFund.isEmpty || addFund == 'null') &&
        (sub == null || sub.isEmpty || sub == 'null');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || Get.isDialogOpen == true) return;
      if (isOrderPay) {
        Get.dialog(PaymentFailedDialog(
          orderID: widget.orderModel.id.toString(),
          orderAmount: widget.orderModel.orderAmount,
          maxCodOrderAmount: maxCodOrderAmount,
          contactPersonNumber: widget.contactNumber,
        ));
      } else {
        Get.dialog(FundPaymentDialogWidget(
            isSubscription: sub != null && sub.isNotEmpty && sub != 'null'));
      }
    });
  }

}

class MyInAppBrowser extends InAppBrowser {
  final String orderID;
  final double? orderAmount;
  final double? maxCodOrderAmount;
  final String? addFundUrl;
  final String? subscriptionUrl;
  final String? contactNumber;
  final int? restaurantId;
  final int? packageId;
  final bool isDeliveryOrder;
  MyInAppBrowser({required this.orderID, required this.orderAmount, required this.maxCodOrderAmount, this.contactNumber, super.windowId,
    super.initialUserScripts, this.addFundUrl, this.subscriptionUrl, this.restaurantId, this.packageId, this.isDeliveryOrder = false});

  bool _canRedirect = true;

  @override
  Future onBrowserCreated() async {
    if (kDebugMode) {
      print("\n\nBrowser Created!\n\n");
    }
  }

  String _navKind(String? url) {
    if (url == null || url.isEmpty) {
      return 'empty';
    }
    final path = url.split('?').first;
    if (path.contains('/payment/bkash/make-payment')) {
      return 'make-payment';
    }
    if (path.contains('/payment/bkash/callback')) {
      return 'callback';
    }
    if (path.contains('payment-fail')) {
      return 'payment-fail';
    }
    if (path.contains('payment-success')) {
      return 'payment-success';
    }
    if (path.contains('bka.sh') || path.contains('bkash.com')) {
      return 'bkash';
    }
    return 'other';
  }

  void _traceNav(String event, {String? url, bool? isRedirect, int? statusCode, String? reason}) {
    debugPrint(
      'BKASH_NAV event=$event kind=${_navKind(url)} isRedirect=$isRedirect statusCode=$statusCode reason=$reason',
    );
  }

  @override
  Future onLoadStart(url) async {
    _traceNav('onLoadStart', url: url?.toString());
    _redirect(url.toString(), contactNumber, restaurantId, packageId);
  }

  @override
  Future onLoadStop(url) async {
    pullToRefreshController?.endRefreshing();
    _traceNav('onLoadStop', url: url?.toString());
    _redirect(url.toString(), contactNumber, restaurantId, packageId);
  }

  @override
  void onLoadError(url, code, message) {
    pullToRefreshController?.endRefreshing();
    _traceNav('onReceivedError', url: url?.toString(), statusCode: code, reason: message);
  }

  @override
  void onProgressChanged(progress) {
    if (progress == 100) {
      pullToRefreshController?.endRefreshing();
    }
    if (kDebugMode) {
      print("Progress: $progress");
    }
  }

  @override
  void onExit() {
    if(_canRedirect && Get.isDialogOpen != true) {
      if((addFundUrl == null || addFundUrl!.isEmpty) && subscriptionUrl == '' && subscriptionUrl!.isEmpty){
        Get.dialog(PaymentFailedDialog(orderID: orderID, orderAmount: orderAmount, maxCodOrderAmount: maxCodOrderAmount, contactPersonNumber: contactNumber,));
      } else {
        Get.dialog(FundPaymentDialogWidget(isSubscription: subscriptionUrl != null && subscriptionUrl!.isNotEmpty));
      }
    }
    if (kDebugMode) {
      print("\n\nBrowser closed!\n\n");
    }
  }

  @override
  Future<NavigationActionPolicy> shouldOverrideUrlLoading(navigationAction) async {
    final uri = navigationAction.request.url;
    _traceNav(
      'shouldOverrideUrlLoading',
      url: uri?.toString(),
      isRedirect: navigationAction.isRedirect,
    );
    return NavigationActionPolicy.ALLOW;
  }

  @override
  void onLoadResource(resource) {
    if (kDebugMode) {
      print("Started at: ${resource.startTime}ms ---> duration: ${resource.duration}ms ${resource.url ?? ''}");
    }
  }

  @override
  void onConsoleMessage(consoleMessage) {
    if (kDebugMode) {
      print("""
    console output:
      message: ${consoleMessage.message}
      messageLevel: ${consoleMessage.messageLevel.toValue()}
   """);
    }
  }

  void _redirect(String url, String? contactNumber, int? restaurantId, int? packageId) {

    bool forSubscription = (subscriptionUrl != null && subscriptionUrl!.isNotEmpty && addFundUrl == '' && addFundUrl!.isEmpty);
    final bool isAddFund = addFundUrl != null && addFundUrl!.isNotEmpty && addFundUrl != 'null';

    if(_canRedirect) {
      String? flag;
      try {
        flag = Uri.parse(url).queryParameters['flag'];
      } catch (_) {}

      bool isSuccess = forSubscription
          ? url.contains('/subscription-success')
          : url.contains('/payment-success') ||
              flag == 'success' ||
              (isAddFund && url.contains(RouteHelper.wallet) && flag == 'success');
      bool isFailed = forSubscription
          ? url.contains('/subscription-fail')
          : url.contains('/payment-fail') ||
              flag == 'fail' ||
              (isAddFund && url.contains(RouteHelper.wallet) && flag == 'fail');
      bool isCancel = forSubscription
          ? url.contains('/subscription-cancel')
          : url.contains('/payment-cancel') ||
              flag == 'cancel' ||
              (isAddFund && url.contains(RouteHelper.wallet) && flag == 'cancel');

      if (isSuccess || isFailed || isCancel) {
        _canRedirect = false;
        close();
      }

      if((addFundUrl == '' && addFundUrl!.isEmpty && subscriptionUrl == '' && subscriptionUrl!.isEmpty)){
        String? message;
        try {
          message = Uri.parse(url).queryParameters['message'];
        } catch (_) {}
        _orderPaymentDoneDecision(isSuccess, isFailed, isCancel, message: message);
      } else{
        _decideSubscriptionOrWallet(isSuccess, isFailed, isCancel, restaurantId, packageId);
      }
    }
  }

  void _orderPaymentDoneDecision(bool isSuccess, bool isFailed, bool isCancel, {String? message}) {
    if (isSuccess) {
      double total = ((orderAmount! / 100) * Get.find<SplashController>().configModel!.loyaltyPointItemPurchasePoint!);
      Get.find<LoyaltyController>().saveEarningPoint(total.toStringAsFixed(0));
      Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, 'success', orderAmount, contactNumber, isDeliveryOrder: isDeliveryOrder));
    } else if (isFailed || isCancel) {
      final resolved = PaymentFailedDialog.normalizeGatewayMessage(
        (message != null && message.trim().isNotEmpty)
            ? message
            : (isCancel ? PaymentFailedDialog.messageCancelled : PaymentFailedDialog.messageFailed),
      );
      Get.offNamed(RouteHelper.getOrderSuccessRoute(orderID, 'fail', orderAmount, contactNumber, isDeliveryOrder: isDeliveryOrder, message: resolved));
    }
  }

  void _decideSubscriptionOrWallet(bool isSuccess, bool isFailed, bool isCancel, int? restaurantId, int? packageId) {
    if(!(isSuccess || isFailed || isCancel)) return;

    final status = isSuccess ? 'success' : isFailed ? 'fail' : 'cancel';

    // InAppBrowser callback is outside widget tree — navigate next frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(subscriptionUrl != null && subscriptionUrl!.isNotEmpty && (addFundUrl == null || addFundUrl!.isEmpty || addFundUrl == 'null')) {
        Get.find<DashboardController>().saveRegistrationSuccessfulSharedPref(true);
        Get.find<DashboardController>().saveIsRestaurantRegistrationSharedPref(true);
        Get.offAllNamed(RouteHelper.getSubscriptionSuccessRoute(
          status: status, fromSubscription: true, restaurantId: restaurantId, packageId: packageId,
        ));
      } else {
        // Single root wallet route; wallet back → home.
        Get.offAllNamed(RouteHelper.getWalletRoute(fundStatus: status));
      }
    });
  }

}