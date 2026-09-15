import 'dart:async';
import 'dart:collection';
import 'dart:ui';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:geolocator/geolocator.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/features/address/domain/models/address_model.dart';
import 'package:toto_user/features/location/widgets/permission_dialog.dart';
import 'package:toto_user/features/notification/domain/models/notification_body_model.dart';
import 'package:toto_user/features/order/controllers/order_controller.dart';
import 'package:toto_user/features/order/domain/models/order_model.dart';
import 'package:toto_user/common/models/restaurant_model.dart';
import 'package:toto_user/features/chat/domain/models/conversation_model.dart';
import 'package:toto_user/features/location/controllers/location_controller.dart';
import 'package:toto_user/features/order/widgets/dine_in_restaurants_card_widget.dart';
import 'package:toto_user/features/order/widgets/track_details_view.dart';
import 'package:toto_user/helper/address_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/helper/directions_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String? orderID;
  final String? contactNumber;
  const OrderTrackingScreen(
      {super.key, required this.orderID, this.contactNumber});

  @override
  OrderTrackingScreenState createState() => OrderTrackingScreenState();
}

class OrderTrackingScreenState extends State<OrderTrackingScreen>
    with WidgetsBindingObserver {
  GoogleMapController? _controller;
  bool _isLoading = true;
  bool _hasAnimated = false; // Track if initial animation has been shown
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polyline> _polylines = HashSet<Polyline>();
  Timer? _timer;

  // Route API optimization:
  // Keep marker/order updates every 10 seconds, but refresh the paid route
  // only when at least 60 seconds passed AND the delivery man moved 100+ meters.
  DateTime? _lastRouteApiCallAt;
  LatLng? _lastRouteApiDeliveryLocation;
  static const Duration _routeApiCooldown = Duration(seconds: 60);
  static const double _routeApiMinMovementMeters = 100.0;
  bool _restaurantCustomerRouteLoaded = false;
  bool _routeRequestInProgress = false;

  // Cache BitmapDescriptors to avoid recreating them on every update for smooth live movement
  BitmapDescriptor? _cachedRestaurantMarker;
  BitmapDescriptor? _cachedDeliveryBoyMarker;
  BitmapDescriptor? _cachedDestinationMarker;
  bool _bitmapDescriptorsInitialized = false;

  void _loadData() async {
    await Get.find<LocationController>().getCurrentLocation(true,
        notify: false,
        defaultLatLng: LatLng(
          double.parse(AddressHelper.getAddressFromSharedPref()!.latitude!),
          double.parse(AddressHelper.getAddressFromSharedPref()!.longitude!),
        ));
    await Get.find<OrderController>().trackOrder(widget.orderID, null, true,
        contactNumber: widget.contactNumber);
    _timerTrackOrder();
  }

  _timerTrackOrder() {
    OrderModel track = Get.find<OrderController>().trackModel!;

    if (track.orderStatus != 'delivered' &&
        track.orderStatus != 'failed' &&
        track.orderStatus != 'canceled') {
      Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(),
          contactNumber: widget.contactNumber);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
        if (Get.currentRoute.contains(RouteHelper.orderDetails) ||
            Get.currentRoute.contains(RouteHelper.orderTracking)) {
          // Await the API call to get updated data
          await Get.find<OrderController>().timerTrackOrder(
              widget.orderID.toString(),
              contactNumber: widget.contactNumber);

          // Get the updated track model from controller
          OrderModel? updatedTrack = Get.find<OrderController>().trackModel;

          if (updatedTrack != null) {
            updateMarker(
              updatedTrack.restaurant,
              updatedTrack.deliveryMan,
              updatedTrack.orderType == 'take_away'
                  ? Get.find<LocationController>().position.latitude == 0
                      ? updatedTrack.deliveryAddress
                      : AddressModel(
                          latitude: Get.find<LocationController>()
                              .position
                              .latitude
                              .toString(),
                          longitude: Get.find<LocationController>()
                              .position
                              .longitude
                              .toString(),
                          address: Get.find<LocationController>().address,
                        )
                  : updatedTrack.deliveryAddress,
              updatedTrack.orderType == 'take_away',
              track: updatedTrack,
            );
          }
        } else {
          _timer?.cancel();
        }
      });
    } else {
      Get.find<OrderController>().timerTrackOrder(widget.orderID.toString(),
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
      _timerTrackOrder();
    } else if (state == AppLifecycleState.paused) {
      Get.find<OrderController>().cancelTimer();
    }
  }

  @override
  void dispose() {
    super.dispose();
    _controller?.dispose();
    _timer?.cancel();
    Get.find<OrderController>().cancelTimer();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBarWidget(
          title: '${'order'.tr}' ' #' '${widget.orderID.toString()}'),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<OrderController>(builder: (orderController) {
        OrderModel? track;
        if (orderController.trackModel != null) {
          track = orderController.trackModel;
        }

        return track != null
            ? Center(
                child: SizedBox(
                    width: Dimensions.webMaxWidth,
                    child: ExpandableBottomSheet(
                      background: Stack(children: [
                        GoogleMap(
                          initialCameraPosition:
                              _getInitialCameraPosition(track),
                          minMaxZoomPreference:
                              const MinMaxZoomPreference(0, 16),
                          zoomControlsEnabled: true,
                          markers: _markers,
                          polylines: _polylines,
                          mapType: MapType.normal,
                          onMapCreated: (GoogleMapController controller) async {
                            _controller = controller;
                            _isLoading = false;

                            // Add a small delay to ensure map is fully loaded before animation
                            await Future.delayed(
                                const Duration(milliseconds: 500));

                            await setMarker(
                              track!.restaurant,
                              track.deliveryMan,
                              track.orderType == 'take_away'
                                  ? Get.find<LocationController>()
                                              .position
                                              .latitude ==
                                          0
                                      ? track.deliveryAddress
                                      : AddressModel(
                                          latitude:
                                              Get.find<LocationController>()
                                                  .position
                                                  .latitude
                                                  .toString(),
                                          longitude:
                                              Get.find<LocationController>()
                                                  .position
                                                  .longitude
                                                  .toString(),
                                          address:
                                              Get.find<LocationController>()
                                                  .address,
                                        )
                                  : track.deliveryAddress,
                              track.orderType == 'take_away',
                              track: track,
                            );
                          },
                          style: AppConstants.minimalistMapStyle,
                        ),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : const SizedBox(),
                        Positioned(
                          right: 15,
                          bottom: track.orderType !=
                                      'take_away' /*&& (track.orderType != 'dine_in')*/ &&
                                  track.deliveryMan == null
                              ? 150
                              : 190,
                          child: InkWell(
                            onTap: () => _checkPermission(() async {
                              AddressModel address =
                                  await Get.find<LocationController>()
                                      .getCurrentLocation(false,
                                          mapController: _controller);
                              await setMarker(
                                track!.restaurant,
                                track.deliveryMan,
                                track.orderType == 'take_away'
                                    ? Get.find<LocationController>()
                                                .position
                                                .latitude ==
                                            0
                                        ? track.deliveryAddress
                                        : AddressModel(
                                            latitude:
                                                Get.find<LocationController>()
                                                    .position
                                                    .latitude
                                                    .toString(),
                                            longitude:
                                                Get.find<LocationController>()
                                                    .position
                                                    .longitude
                                                    .toString(),
                                            address:
                                                Get.find<LocationController>()
                                                    .address,
                                          )
                                    : track.deliveryAddress,
                                track.orderType == 'take_away',
                                currentAddress: address,
                                fromCurrentLocation: true,
                                track: track,
                              );
                            }),
                            child: Container(
                              padding: const EdgeInsets.all(
                                  Dimensions.paddingSizeSmall),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(50),
                                  color: Colors.white),
                              child: Icon(Icons.my_location_outlined,
                                  color: Theme.of(context).primaryColor,
                                  size: 25),
                            ),
                          ),
                        ),
                      ]),
                      persistentContentHeight: 170,
                      expandableContent: track.orderType == 'dine_in'
                          ? DineInRestaurantsCardWidget(
                              restaurant: track.restaurant!)
                          : Padding(
                              padding: const EdgeInsets.only(
                                  left: Dimensions.paddingSizeSmall,
                                  right: Dimensions.paddingSizeSmall,
                                  bottom: Dimensions.paddingSizeSmall),
                              child: TrackDetailsView(
                                  track: track,
                                  callback: () async {
                                    bool takeAway =
                                        track?.orderType == 'take_away';
                                    orderController.cancelTimer();
                                    await Get.toNamed(RouteHelper.getChatRoute(
                                      notificationBody: takeAway
                                          ? NotificationBodyModel(
                                              restaurantId:
                                                  track!.restaurant!.id,
                                              orderId:
                                                  int.parse(widget.orderID!))
                                          : NotificationBodyModel(
                                              deliverymanId:
                                                  track!.deliveryMan!.id,
                                              orderId:
                                                  int.parse(widget.orderID!)),
                                      user: User(
                                        id: takeAway
                                            ? track.restaurant!.id
                                            : track.deliveryMan!.id,
                                        fName: takeAway
                                            ? track.restaurant!.name
                                            : track.deliveryMan!.fName,
                                        lName: takeAway
                                            ? ''
                                            : track.deliveryMan!.lName,
                                        imageFullUrl: takeAway
                                            ? track.restaurant!.logoFullUrl
                                            : track.deliveryMan!.imageFullUrl,
                                      ),
                                    ));
                                    _timerTrackOrder();
                                  }),
                            ),
                    )))
            : const Center(child: CircularProgressIndicator());
      }),
    );
  }

  /// Initialize cached BitmapDescriptors once for smooth live marker updates
  Future<void> _initializeBitmapDescriptors() async {
    if (_bitmapDescriptorsInitialized) return;

    try {
      _cachedRestaurantMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(devicePixelRatio: 3.0),
        Images.restaurantMarker,
        width: 50,
        height: 50,
      );
      _cachedDeliveryBoyMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(devicePixelRatio: 3.0),
        Images.deliveryManMarker,
        width: 50,
        height: 50,
      );
      _cachedDestinationMarker = await BitmapDescriptor.asset(
        const ImageConfiguration(devicePixelRatio: 3.0),
        Images.myLocationMarker,
        width: 50,
        height: 50,
      );
      _bitmapDescriptorsInitialized = true;
    } catch (_) {
      // Fallback to default markers if asset loading fails
      _cachedRestaurantMarker ??=
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      _cachedDeliveryBoyMarker ??=
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
      _cachedDestinationMarker ??=
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      _bitmapDescriptorsInitialized = true;
    }
  }

  Future<void> setMarker(Restaurant? restaurant, DeliveryMan? deliveryMan,
      AddressModel? addressModel, bool takeAway,
      {AddressModel? currentAddress,
      bool fromCurrentLocation = false,
      OrderModel? track}) async {
    try {
      // Initialize cached BitmapDescriptors if not already done
      await _initializeBitmapDescriptors();

      // Use cached BitmapDescriptors for consistent marker rendering
      BitmapDescriptor restaurantImageData = _cachedRestaurantMarker!;
      BitmapDescriptor deliveryBoyImageData = _cachedDeliveryBoyMarker!;
      BitmapDescriptor destinationImageData = _cachedDestinationMarker!;

      // Animate to coordinate
      LatLngBounds? bounds;
      double rotation = 0;
      if (_controller != null) {
        if (double.parse(addressModel!.latitude!) <
            double.parse(restaurant!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!),
                double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(restaurant.latitude!),
                double.parse(restaurant.longitude!)),
          );
          rotation = 0;
        } else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(restaurant.latitude!),
                double.parse(restaurant.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!),
                double.parse(addressModel.longitude!)),
          );
          rotation = 0;
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );

      if (fromCurrentLocation && currentAddress != null) {
        LatLng currentLocation = LatLng(
          double.parse(currentAddress.latitude!),
          double.parse(currentAddress.longitude!),
        );
        // Smooth zoom animation to current location
        _controller!.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: currentLocation, zoom: 15)));
      }

      // Always use dynamic zoom logic unless user clicked "My Location" button
      if (!fromCurrentLocation) {
        // Use dynamic zoom logic based on order status
        LatLng targetLocation;
        double zoom = 15;

        // TEST: Always zoom to restaurant location first to test if zoom works
        if (restaurant != null &&
            restaurant.latitude != null &&
            restaurant.longitude != null) {
          targetLocation = LatLng(
            double.parse(restaurant.latitude!),
            double.parse(restaurant.longitude!),
          );
          print(
              'ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â½ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¯ TEST ZOOM TO: Restaurant Location (${targetLocation.latitude}, ${targetLocation.longitude})');
        } else {
          targetLocation = centerBounds;
          print(
              'ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â½ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¯ TEST ZOOM TO: Center Bounds (${targetLocation.latitude}, ${targetLocation.longitude})');
        }

        // Smooth zoom animation to target location with dramatic effect (only once)
        if (!_hasAnimated) {
          _animateToLocation(targetLocation, zoom);
          _hasAnimated = true;
        } else {
          // Just move camera without animation for subsequent updates
          _controller!.moveCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: targetLocation, zoom: zoom)));
        }
        // Don't call zoomToFit when using dynamic zoom logic
        // if (!ResponsiveHelper.isWeb()) {
        //   zoomToFit(_controller, bounds, centerBounds, padding: 3.5);
        // }
      }

      // Create route polyline based on order status
      if (track != null) {
        bool isPickedUp = track.orderStatus == 'picked_up' ||
            track.orderStatus == 'delivered' ||
            track.orderStatus == 'handover';

        if (isPickedUp) {
          await _updateRouteWithDeliveryMan(track);
        } else {
          await _createRoutePolyline(track);
        }
      }

      // Marker
      _markers = HashSet<Marker>();

      ///current location marker set
      if (currentAddress != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          visible: true,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.parse(currentAddress.latitude!),
            double.parse(currentAddress.longitude!),
          ),
          icon: destinationImageData,
        ));
        setState(() {});
      }

      if (currentAddress == null) {
        addressModel != null
            ? _markers.add(Marker(
                markerId: const MarkerId('destination'),
                position: LatLng(double.parse(addressModel.latitude!),
                    double.parse(addressModel.longitude!)),
                infoWindow: InfoWindow(
                  title: 'Destination',
                  snippet: addressModel.address,
                ),
                icon: destinationImageData,
              ))
            : const SizedBox();
      }

      restaurant != null
          ? _markers.add(Marker(
              markerId: const MarkerId('restaurant'),
              position: LatLng(double.parse(restaurant.latitude!),
                  double.parse(restaurant.longitude!)),
              infoWindow: InfoWindow(
                title: 'restaurant'.tr,
                snippet: restaurant.address,
              ),
              icon: restaurantImageData,
            ))
          : const SizedBox();

      deliveryMan != null
          ? _markers.add(Marker(
              markerId: const MarkerId('delivery_boy'),
              position: LatLng(double.parse(deliveryMan.lat ?? '0'),
                  double.parse(deliveryMan.lng ?? '0')),
              infoWindow: InfoWindow(
                title: 'delivery_man'.tr,
                snippet: deliveryMan.location,
              ),
              rotation: rotation,
              icon: deliveryBoyImageData,
            ))
          : const SizedBox();
    } catch (_) {}
    setState(() {});
  }

  Future<void> updateMarker(Restaurant? restaurant, DeliveryMan? deliveryMan,
      AddressModel? addressModel, bool takeAway,
      {AddressModel? currentAddress,
      bool fromCurrentLocation = false,
      OrderModel? track}) async {
    try {
      // Ensure BitmapDescriptors are initialized (should already be done in setMarker)
      if (!_bitmapDescriptorsInitialized) {
        await _initializeBitmapDescriptors();
      }

      // Use cached BitmapDescriptors to avoid async delays and enable smooth live marker movement
      BitmapDescriptor restaurantImageData = _cachedRestaurantMarker!;
      BitmapDescriptor deliveryBoyImageData = _cachedDeliveryBoyMarker!;
      BitmapDescriptor destinationImageData = _cachedDestinationMarker!;

      // Animate to coordinate
      LatLngBounds? bounds;
      debugPrint(bounds.toString());

      double rotation = 0;
      if (_controller != null) {
        if (double.parse(addressModel!.latitude!) <
            double.parse(restaurant!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!),
                double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(restaurant.latitude!),
                double.parse(restaurant.longitude!)),
          );
          rotation = 0;
        } else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(restaurant.latitude!),
                double.parse(restaurant.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!),
                double.parse(addressModel.longitude!)),
          );
          rotation = 0;
        }
      }

      // Apply dynamic zoom logic based on order status
      if (_controller != null && !fromCurrentLocation) {
        LatLng targetLocation;
        double zoom = 15;

        // Check if order has been picked up
        bool isPickedUp = track?.orderStatus == 'picked_up' ||
            track?.orderStatus == 'delivered' ||
            track?.orderStatus == 'handover';

        if (isPickedUp &&
            deliveryMan != null &&
            deliveryMan.lat != null &&
            deliveryMan.lng != null) {
          // After pickup: zoom to delivery man location
          targetLocation = LatLng(
            double.parse(deliveryMan.lat!),
            double.parse(deliveryMan.lng!),
          );
        } else if (restaurant != null &&
            restaurant.latitude != null &&
            restaurant.longitude != null) {
          // Before pickup: zoom to restaurant location
          targetLocation = LatLng(
            double.parse(restaurant.latitude!),
            double.parse(restaurant.longitude!),
          );
        } else {
          // Fallback to center bounds if available
          if (bounds != null) {
            targetLocation = LatLng(
              (bounds.northeast.latitude + bounds.southwest.latitude) / 2,
              (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
            );
          } else {
            targetLocation = LatLng(
              double.parse(addressModel!.latitude!),
              double.parse(addressModel.longitude!),
            );
          }
        }

        // Just move camera without animation for real-time updates
        _controller!.moveCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: targetLocation, zoom: zoom)));
      }

      // Update route polyline based on order status
      if (track != null) {
        bool isPickedUp = track.orderStatus == 'picked_up' ||
            track.orderStatus == 'delivered' ||
            track.orderStatus == 'handover';

        if (isPickedUp) {
          await _updateRouteWithDeliveryMan(track);
        } else {
          await _createRoutePolyline(track);
        }
      }

      // Marker
      _markers = HashSet<Marker>();

      ///current location marker set
      if (currentAddress != null) {
        _markers.add(Marker(
          markerId: const MarkerId('current_location'),
          visible: true,
          draggable: false,
          zIndex: 2,
          flat: true,
          anchor: const Offset(0.5, 0.5),
          position: LatLng(
            double.parse(currentAddress.latitude!),
            double.parse(currentAddress.longitude!),
          ),
          icon: destinationImageData,
        ));
        setState(() {});
      }

      if (currentAddress == null) {
        addressModel != null
            ? _markers.add(Marker(
                markerId: const MarkerId('destination'),
                position: LatLng(double.parse(addressModel.latitude!),
                    double.parse(addressModel.longitude!)),
                infoWindow: InfoWindow(
                  title: 'Destination',
                  snippet: addressModel.address,
                ),
                icon: destinationImageData,
              ))
            : const SizedBox();
      }

      restaurant != null
          ? _markers.add(Marker(
              markerId: const MarkerId('restaurant'),
              position: LatLng(double.parse(restaurant.latitude!),
                  double.parse(restaurant.longitude!)),
              infoWindow: InfoWindow(
                title: 'restaurant'.tr,
                snippet: restaurant.address,
              ),
              icon: restaurantImageData,
            ))
          : const SizedBox();

      deliveryMan != null
          ? _markers.add(Marker(
              markerId: const MarkerId('delivery_boy'),
              position: LatLng(double.parse(deliveryMan.lat ?? '0'),
                  double.parse(deliveryMan.lng ?? '0')),
              infoWindow: InfoWindow(
                title: 'delivery_man'.tr,
                snippet: deliveryMan.location,
              ),
              rotation: rotation,
              icon: deliveryBoyImageData,
            ))
          : const SizedBox();
    } catch (_) {}
    setState(() {});
  }

  Future<void> zoomToFit(GoogleMapController? controller, LatLngBounds? bounds,
      LatLng centerBounds,
      {double padding = 0.5}) async {
    bool keepZoomingOut = true;

    while (keepZoomingOut) {
      final LatLngBounds screenBounds = await controller!.getVisibleRegion();
      if (fits(bounds!, screenBounds)) {
        keepZoomingOut = false;
        final double zoomLevel = await controller.getZoomLevel() - padding;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
        break;
      } else {
        // Zooming out by 0.1 zoom level per iteration
        final double zoomLevel = await controller.getZoomLevel() - 0.1;
        controller.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
          target: centerBounds,
          zoom: zoomLevel,
        )));
      }
    }
  }

  bool fits(LatLngBounds fitBounds, LatLngBounds screenBounds) {
    final bool northEastLatitudeCheck =
        screenBounds.northeast.latitude >= fitBounds.northeast.latitude;
    final bool northEastLongitudeCheck =
        screenBounds.northeast.longitude >= fitBounds.northeast.longitude;

    final bool southWestLatitudeCheck =
        screenBounds.southwest.latitude <= fitBounds.southwest.latitude;
    final bool southWestLongitudeCheck =
        screenBounds.southwest.longitude <= fitBounds.southwest.longitude;

    return northEastLatitudeCheck &&
        northEastLongitudeCheck &&
        southWestLatitudeCheck &&
        southWestLongitudeCheck;
  }

  Future<Uint8List> convertAssetToUnit8List(String imagePath,
      {int width = 50}) async {
    ByteData data = await rootBundle.load(imagePath);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  void _checkPermission(Function onTap) async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      showCustomSnackBar('you_have_to_allow'.tr);
    } else if (permission == LocationPermission.deniedForever) {
      Get.dialog(const PermissionDialog());
    } else {
      onTap();
    }
  }

  /// Animate camera to target location with smooth zoom IN effect
  Future<void> _animateToLocation(LatLng targetLocation, double zoom) async {
    if (_controller != null) {
      // Start from a wider view (lower zoom level)
      await _controller!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: targetLocation, zoom: zoom - 5)));

      // Wait a moment to let user see the wider view
      await Future.delayed(const Duration(milliseconds: 300));

      // Then zoom IN to the target location with higher zoom
      await _controller!.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: targetLocation, zoom: zoom)));
    }
  }

  /// Create route polyline from restaurant to customer using real directions
  Future<void> _createRoutePolyline(OrderModel track) async {
    // Restaurant -> customer route is static for this order.
    // Do not request Google Directions again after it has been created.
    if (_restaurantCustomerRouteLoaded) {
      return;
    }

    if (track.restaurant == null ||
        track.restaurant!.latitude == null ||
        track.restaurant!.longitude == null ||
        track.deliveryAddress == null ||
        track.deliveryAddress!.latitude == null ||
        track.deliveryAddress!.longitude == null) {
      return;
    }

    final LatLng restaurantLocation = LatLng(
      double.parse(track.restaurant!.latitude!),
      double.parse(track.restaurant!.longitude!),
    );

    final LatLng customerLocation = LatLng(
      double.parse(track.deliveryAddress!.latitude!),
      double.parse(track.deliveryAddress!.longitude!),
    );

    List<LatLng>? routePoints;

    try {
      routePoints = await DirectionsHelper.getRestaurantToCustomerRoute(
        restaurant: restaurantLocation,
        customer: customerLocation,
      );
    } catch (e) {
      debugPrint('Restaurant to customer route request failed: $e');
    }

    final Set<Polyline> newPolylines = <Polyline>{};

    if (routePoints != null && routePoints.isNotEmpty) {
      newPolylines.add(
        Polyline(
          polylineId: const PolylineId('delivery_route'),
          points: routePoints,
          color: Colors.blue,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    } else {
      final List<LatLng> curvedPath = DirectionsHelper.createCurvedPath(
        restaurantLocation,
        customerLocation,
        segments: 25,
      );

      newPolylines.add(
        Polyline(
          polylineId: const PolylineId('delivery_route'),
          points: curvedPath,
          color: Colors.blue,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      );
    }

    _polylines
      ..clear()
      ..addAll(newPolylines);

    _restaurantCustomerRouteLoaded = true;
  }

  /// Update route polyline with delivery man's current position using real directions.
  /// The live marker can still update every 10 seconds, but Google Directions
  /// is refreshed only after the cooldown AND meaningful rider movement.
  Future<void> _updateRouteWithDeliveryMan(OrderModel track) async {
    if (track.restaurant == null ||
        track.restaurant!.latitude == null ||
        track.restaurant!.longitude == null ||
        track.deliveryAddress == null ||
        track.deliveryAddress!.latitude == null ||
        track.deliveryAddress!.longitude == null) {
      return;
    }

    final LatLng customerLocation = LatLng(
      double.parse(track.deliveryAddress!.latitude!),
      double.parse(track.deliveryAddress!.longitude!),
    );

    LatLng? deliveryManLocation;
    if (track.deliveryMan != null &&
        track.deliveryMan!.lat != null &&
        track.deliveryMan!.lng != null) {
      deliveryManLocation = LatLng(
        double.parse(track.deliveryMan!.lat!),
        double.parse(track.deliveryMan!.lng!),
      );
    }

    // If delivery-man coordinates are temporarily unavailable,
    // keep the existing route. Load restaurant -> customer route only once.
    if (deliveryManLocation == null) {
      if (!_restaurantCustomerRouteLoaded) {
        await _createRoutePolyline(track);
      }
      return;
    }

    final DateTime now = DateTime.now();

    if (_lastRouteApiCallAt != null && _lastRouteApiDeliveryLocation != null) {
      final Duration elapsed = now.difference(_lastRouteApiCallAt!);
      final double movedMeters = Geolocator.distanceBetween(
        _lastRouteApiDeliveryLocation!.latitude,
        _lastRouteApiDeliveryLocation!.longitude,
        deliveryManLocation.latitude,
        deliveryManLocation.longitude,
      );

      // Do not clear the existing polyline here. Keeping it prevents the route
      // from disappearing while a paid route refresh is intentionally skipped.
      if (elapsed < _routeApiCooldown ||
          movedMeters < _routeApiMinMovementMeters) {
        return;
      }
    }

    if (_routeRequestInProgress) {
      return;
    }

    _routeRequestInProgress = true;

    List<LatLng>? routePoints;

    try {
      routePoints = await DirectionsHelper.getDirections(
        origin: deliveryManLocation,
        destination: customerLocation,
      );

      // Count only an actual attempted route refresh toward the cooldown.
      _lastRouteApiCallAt = now;
      _lastRouteApiDeliveryLocation = deliveryManLocation;
    } catch (e) {
      debugPrint('Delivery route request failed: $e');

      // Prevent repeated API retries every 10 seconds after a failed request.
      _lastRouteApiCallAt = now;
      _lastRouteApiDeliveryLocation = deliveryManLocation;
    } finally {
      _routeRequestInProgress = false;
    }

    if (routePoints != null && routePoints.isNotEmpty) {
      final Polyline routePolyline = Polyline(
        polylineId: const PolylineId('delivery_route'),
        points: routePoints,
        color: Colors.green,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      );

      _polylines
        ..clear()
        ..add(routePolyline);
    } else {
      final LatLng startPoint = deliveryManLocation;
      final List<LatLng> curvedPath = DirectionsHelper.createCurvedPath(
        startPoint,
        customerLocation,
        segments: 25,
      );

      final Polyline fallbackPolyline = Polyline(
        polylineId: const PolylineId('delivery_route'),
        points: curvedPath,
        color: Colors.green,
        width: 4,
        patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      );

      _polylines
        ..clear()
        ..add(fallbackPolyline);
    }
  }

  /// Get initial camera position based on order status
  /// Before pickup: zoom to restaurant location
  /// After pickup: zoom to delivery man location
  CameraPosition _getInitialCameraPosition(OrderModel track) {
    LatLng targetLocation;
    double zoom = 16.0;

    // TEST: Always zoom to restaurant location first
    if (track.restaurant != null &&
        track.restaurant!.latitude != null &&
        track.restaurant!.longitude != null) {
      targetLocation = LatLng(
        double.parse(track.restaurant!.latitude!),
        double.parse(track.restaurant!.longitude!),
      );
      print(
          'ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â½ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¯ INITIAL TEST ZOOM TO: Restaurant Location (${targetLocation.latitude}, ${targetLocation.longitude})');
    } else {
      targetLocation = LatLng(
        double.parse(track.deliveryAddress!.latitude!),
        double.parse(track.deliveryAddress!.longitude!),
      );
      print(
          'ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã‚Â ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬ÃƒÂ¢Ã¢â‚¬Å¾Ã‚Â¢ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â°ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¸ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¦ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â½ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã¢â‚¬Â ÃƒÂ¢Ã¢â€šÂ¬Ã¢â€žÂ¢ÃƒÆ’Ã†â€™Ãƒâ€šÃ‚Â¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡Ãƒâ€šÃ‚Â¬ÃƒÆ’Ã¢â‚¬Â¦Ãƒâ€šÃ‚Â¡ÃƒÆ’Ã†â€™Ãƒâ€ Ã¢â‚¬â„¢ÃƒÆ’Ã‚Â¢ÃƒÂ¢Ã¢â‚¬Å¡Ã‚Â¬Ãƒâ€¦Ã‚Â¡ÃƒÆ’Ã†â€™ÃƒÂ¢Ã¢â€šÂ¬Ã…Â¡ÃƒÆ’Ã¢â‚¬Å¡Ãƒâ€šÃ‚Â¯ INITIAL TEST ZOOM TO: Delivery Address (${targetLocation.latitude}, ${targetLocation.longitude})');
    }

    // Start with a lower zoom level to create zoom IN effect
    zoom = zoom - 3;

    return CameraPosition(target: targetLocation, zoom: zoom);
  }
}
