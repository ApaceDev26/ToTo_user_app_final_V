import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:toto_user/features/address/domain/models/address_model.dart';
import 'package:toto_user/features/order/domain/models/order_model.dart';
import 'package:toto_user/common/models/restaurant_model.dart';
import 'package:toto_user/features/location/controllers/location_controller.dart';
import 'package:toto_user/helper/marker_helper.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/directions_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:collection';

class TrackingMapWidget extends StatefulWidget {
  final OrderModel? track;
  const TrackingMapWidget({super.key, required this.track});

  @override
  State<TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<TrackingMapWidget> {
  GoogleMapController? _controller;
  bool _isLoading = true;
  bool _hasAnimated = false; // Track if initial animation has been shown
  Set<Marker> _markers = HashSet<Marker>();
  Set<Polyline> _polylines = HashSet<Polyline>();

  @override
  void dispose() {
    super.dispose();

    _controller?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Container(
      height: 200,
      width: ResponsiveHelper.isMobilePhone() ? width : 1170.0 - 100.0,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
      ),
      child: widget.track!.deliveryMan != null
          ? Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition:
                        _getInitialCameraPosition(widget.track!),
                    minMaxZoomPreference: const MinMaxZoomPreference(0, 16),
                    zoomControlsEnabled: true,
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (GoogleMapController controller) async {
                      _controller = controller;
                      _isLoading = false;
                      await setMarker(
                        widget.track!.restaurant,
                        widget.track!.deliveryMan,
                        widget.track!.orderType == 'take_away'
                            ? Get.find<LocationController>()
                                        .position
                                        .latitude ==
                                    0
                                ? widget.track!.deliveryAddress
                                : AddressModel(
                                    latitude: Get.find<LocationController>()
                                        .position
                                        .latitude
                                        .toString(),
                                    longitude: Get.find<LocationController>()
                                        .position
                                        .longitude
                                        .toString(),
                                    address:
                                        Get.find<LocationController>().address,
                                  )
                            : widget.track!.deliveryAddress,
                        widget.track!.orderType == 'take_away',
                      );
                    },
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                          () => EagerGestureRecognizer()),
                      Factory<PanGestureRecognizer>(
                          () => PanGestureRecognizer()),
                      Factory<ScaleGestureRecognizer>(
                          () => ScaleGestureRecognizer()),
                      Factory<TapGestureRecognizer>(
                          () => TapGestureRecognizer()),
                      Factory<VerticalDragGestureRecognizer>(
                          () => VerticalDragGestureRecognizer()),
                    },
                    style: AppConstants.minimalistMapStyle,
                  ),
                ),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor)))
                    : const SizedBox(),
              ],
            )
          : FittedBox(child: Text('no_delivery_man_data_found'.tr)),
    );
  }

  Future<void> setMarker(Restaurant? restaurant, DeliveryMan? deliveryMan,
      AddressModel? addressModel, bool takeAway) async {
    try {
      BitmapDescriptor restaurantImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
              width: 50, imagePath: Images.restaurantMarker);
      BitmapDescriptor deliveryBoyImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
              width: 50, imagePath: Images.deliveryManMarker);
      BitmapDescriptor destinationImageData =
          await MarkerHelper.convertAssetToBitmapDescriptor(
              width: 50, imagePath: Images.myLocationMarker);

      // Animate to coordinate
      LatLngBounds? bounds;
      if (_controller != null) {
        if (double.parse(addressModel!.latitude!) <
            double.parse(restaurant!.latitude!)) {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(addressModel.latitude!),
                double.parse(addressModel.longitude!)),
            northeast: LatLng(double.parse(restaurant.latitude!),
                double.parse(restaurant.longitude!)),
          );
        } else {
          bounds = LatLngBounds(
            southwest: LatLng(double.parse(restaurant.latitude!),
                double.parse(restaurant.longitude!)),
            northeast: LatLng(double.parse(addressModel.latitude!),
                double.parse(addressModel.longitude!)),
          );
        }
      }
      LatLng centerBounds = LatLng(
        (bounds!.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2,
      );

      // Apply dynamic zoom logic based on order status
      LatLng targetLocation;
      double zoom = GetPlatform.isWeb ? 10 : 15;

      // Check if order has been picked up
      bool isPickedUp = widget.track!.orderStatus == 'picked_up' ||
          widget.track!.orderStatus == 'delivered' ||
          widget.track!.orderStatus == 'handover';

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
        // Fallback to center bounds
        targetLocation = centerBounds;
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
      //   zoomToFit(_controller, bounds, centerBounds, padding: 10);
      // }

      // Create route polyline based on order status
      if (isPickedUp) {
        await _updateRouteWithDeliveryMan(widget.track!);
      } else {
        await _createRoutePolyline(widget.track!);
      }

      // Marker
      _markers = HashSet<Marker>();
      addressModel != null
          ? _markers.add(Marker(
              markerId: const MarkerId('destination'),
              position: LatLng(double.parse(addressModel.latitude!),
                  double.parse(addressModel.longitude!)),
              infoWindow: InfoWindow(
                title: 'Destination',
                snippet: addressModel.address,
              ),
              icon: GetPlatform.isWeb
                  ? BitmapDescriptor.defaultMarker
                  : destinationImageData,
            ))
          : const SizedBox();

      restaurant != null
          ? _markers.add(Marker(
              markerId: const MarkerId('restaurant'),
              position: LatLng(double.parse(restaurant.latitude!),
                  double.parse(restaurant.longitude!)),
              infoWindow: InfoWindow(
                title: 'restaurant'.tr,
                snippet: restaurant.address,
              ),
              icon: GetPlatform.isWeb
                  ? BitmapDescriptor.defaultMarker
                  : restaurantImageData,
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
              icon: GetPlatform.isWeb
                  ? BitmapDescriptor.defaultMarker
                  : deliveryBoyImageData,
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
        final double zoomLevel = await controller.getZoomLevel() - 0.5;
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
    _polylines.clear();

    if (track.restaurant != null &&
        track.restaurant!.latitude != null &&
        track.restaurant!.longitude != null &&
        track.deliveryAddress != null &&
        track.deliveryAddress!.latitude != null &&
        track.deliveryAddress!.longitude != null) {
      LatLng restaurantLocation = LatLng(
        double.parse(track.restaurant!.latitude!),
        double.parse(track.restaurant!.longitude!),
      );

      LatLng customerLocation = LatLng(
        double.parse(track.deliveryAddress!.latitude!),
        double.parse(track.deliveryAddress!.longitude!),
      );

      // Get real directions from Google Maps
      List<LatLng>? routePoints =
          await DirectionsHelper.getRestaurantToCustomerRoute(
        restaurant: restaurantLocation,
        customer: customerLocation,
      );

      if (routePoints != null && routePoints.isNotEmpty) {
        // Create polyline with real road route
        Polyline routePolyline = Polyline(
          polylineId: const PolylineId('delivery_route'),
          points: routePoints,
          color: Colors.blue,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        );

        _polylines.add(routePolyline);
      } else {
        // Fallback to straight line if directions fail
        Polyline fallbackPolyline = Polyline(
          polylineId: const PolylineId('delivery_route'),
          points: [restaurantLocation, customerLocation],
          color: Colors.blue,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        );
        _polylines.add(fallbackPolyline);
      }
    }
  }

  /// Update route polyline with delivery man's current position using real directions
  Future<void> _updateRouteWithDeliveryMan(OrderModel track) async {
    _polylines.clear();

    if (track.restaurant != null &&
        track.restaurant!.latitude != null &&
        track.restaurant!.longitude != null &&
        track.deliveryAddress != null &&
        track.deliveryAddress!.latitude != null &&
        track.deliveryAddress!.longitude != null) {
      LatLng restaurantLocation = LatLng(
        double.parse(track.restaurant!.latitude!),
        double.parse(track.restaurant!.longitude!),
      );

      LatLng customerLocation = LatLng(
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

      // Get route from delivery man's current position to customer (not from restaurant)
      List<LatLng>? routePoints;
      if (deliveryManLocation != null) {
        // Get route from delivery man's current position to customer
        routePoints = await DirectionsHelper.getDirections(
          origin: deliveryManLocation,
          destination: customerLocation,
        );
      } else {
        // Fallback to restaurant to customer if no delivery man location
        routePoints = await DirectionsHelper.getRestaurantToCustomerRoute(
          restaurant: restaurantLocation,
          customer: customerLocation,
        );
      }

      if (routePoints != null && routePoints.isNotEmpty) {
        // Create polyline with real road route
        Polyline routePolyline = Polyline(
          polylineId: const PolylineId('delivery_route'),
          points: routePoints,
          color: Colors.green,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        );

        _polylines.add(routePolyline);
      } else {
        // Fallback to straight line if directions fail
        List<LatLng> fallbackPoints = [];
        if (deliveryManLocation != null) {
          fallbackPoints.add(deliveryManLocation);
        } else {
          fallbackPoints.add(restaurantLocation);
        }
        fallbackPoints.add(customerLocation);

        Polyline fallbackPolyline = Polyline(
          polylineId: const PolylineId('delivery_route'),
          points: fallbackPoints,
          color: Colors.green,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        );
        _polylines.add(fallbackPolyline);
      }
    }
  }

  /// Get initial camera position based on order status
  /// Before pickup: zoom to restaurant location
  /// After pickup: zoom to delivery man location
  CameraPosition _getInitialCameraPosition(OrderModel track) {
    LatLng targetLocation;
    double zoom = 16.0;

    // Check if order has been picked up
    bool isPickedUp = track.orderStatus == 'picked_up' ||
        track.orderStatus == 'delivered' ||
        track.orderStatus == 'handover';

    if (isPickedUp &&
        track.deliveryMan != null &&
        track.deliveryMan!.lat != null &&
        track.deliveryMan!.lng != null) {
      // After pickup: zoom to delivery man location
      targetLocation = LatLng(
        double.parse(track.deliveryMan!.lat!),
        double.parse(track.deliveryMan!.lng!),
      );
    } else if (track.restaurant != null &&
        track.restaurant!.latitude != null &&
        track.restaurant!.longitude != null) {
      // Before pickup: zoom to restaurant location
      targetLocation = LatLng(
        double.parse(track.restaurant!.latitude!),
        double.parse(track.restaurant!.longitude!),
      );
    } else {
      // Fallback to delivery address
      targetLocation = LatLng(
        double.parse(track.deliveryAddress!.latitude!),
        double.parse(track.deliveryAddress!.longitude!),
      );
    }

    return CameraPosition(target: targetLocation, zoom: zoom);
  }
}
