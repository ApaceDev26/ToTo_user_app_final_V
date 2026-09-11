import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:toto_user/common/widgets/no_internet_screen_widget.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/notification/domain/models/notification_body_model.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/splash/domain/models/deep_link_body.dart';
import 'package:toto_user/helper/address_helper.dart';
import 'package:toto_user/util/images.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  final NotificationBodyModel? notificationBody;
  final DeepLinkBody? linkBody;
  const SplashScreen({
    super.key,
    required this.notificationBody,
    required this.linkBody,
  });

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey();
  StreamSubscription<List<ConnectivityResult>>? _onConnectivityChanged;
  Timer? _navigationTimer;
  bool _hasNavigated = false;
  bool _isSplashMediaReady = false;

  /// Approx full play length of intro GIF (tune if asset changes).
  static const Duration _splashGifDuration = Duration(milliseconds: 2800);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage(Images.introGif), context);
      _initializeConnectivityListener();
      _initializeSplashData();
    });
  }

  void _initializeConnectivityListener() {
    bool firstTime = true;
    _onConnectivityChanged = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> result) {
      if (!mounted) return;

      bool isConnected = result.contains(ConnectivityResult.wifi) ||
          result.contains(ConnectivityResult.mobile);

      if (!firstTime) {
        _showConnectivitySnackBar(isConnected);
        if (!isConnected) {
          Get.to(const NoInternetScreen());
        }
        // Do not jump home early — wait for GIF to finish.
      }
      firstTime = false;
    });
  }

  void _showConnectivitySnackBar(bool isConnected) {
    if (!mounted) return;

    try {
      ScaffoldMessenger.of(Get.context!).hideCurrentSnackBar();
      ScaffoldMessenger.of(Get.context!).showSnackBar(SnackBar(
        backgroundColor: isConnected ? Colors.green : Colors.red,
        duration: Duration(seconds: isConnected ? 0 : 10),
        content: Text(
          isConnected ? 'connected'.tr : 'no_connection'.tr,
          textAlign: TextAlign.center,
        ),
      ));
    } catch (e) {
      debugPrint('Error showing connectivity snackbar: $e');
    }
  }

  Future<void> _initializeSplashData() async {
    try {
      await Get.find<SplashController>().initSharedData();

      final address = AddressHelper.getAddressFromSharedPref();
      if (address != null &&
          (address.zoneIds == null || address.zoneData == null)) {
        AddressHelper.clearAddressFromSharedPref();
      }

      if (Get.find<AuthController>().isGuestLoggedIn() ||
          Get.find<AuthController>().isLoggedIn()) {
        Get.find<CartController>().getCartDataOnline();
      }
    } catch (e) {
      debugPrint('Error initializing splash data: $e');
    }
  }

  void _onSplashMediaLoaded() {
    if (!mounted || _isSplashMediaReady) return;
    _isSplashMediaReady = true;
    _navigationTimer?.cancel();
    _navigationTimer = Timer(_splashGifDuration, () {
      if (mounted) _route();
    });
  }

  void _route() {
    if (!mounted || _hasNavigated) return;

    _hasNavigated = true;
    try {
      _navigationTimer?.cancel();
      Get.find<SplashController>().getConfigData(
        handleMaintenanceMode: false,
        notificationBody: widget.notificationBody,
      );
    } catch (e) {
      debugPrint('Error in splash routing: $e');
    }
  }

  @override
  void dispose() {
    _onConnectivityChanged?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final gifSize = (size.shortestSide * 0.72).clamp(220.0, 420.0);

    return Scaffold(
      key: _globalKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: gifSize,
            height: gifSize,
            child: Image.asset(
              Images.introGif,
              width: gifSize,
              height: gifSize,
              fit: BoxFit.contain,
              gaplessPlayback: true,
              frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
                if (frame != null || wasSynchronouslyLoaded) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _onSplashMediaLoaded();
                  });
                }
                return child;
              },
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Splash GIF failed to load: $error');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) _route();
                });
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }
}
