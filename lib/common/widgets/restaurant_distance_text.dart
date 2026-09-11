import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:toto_user/features/restaurant/controllers/restaurant_controller.dart';

/// Road-distance label (DRIVE) with cache + rebuild via [RestaurantController].
class RestaurantDistanceText extends StatelessWidget {
  final String latitude;
  final String longitude;
  final TextStyle? style;
  final int fractionDigits;
  final double maxKm;
  final String? suffix;

  const RestaurantDistanceText({
    super.key,
    required this.latitude,
    required this.longitude,
    this.style,
    this.fractionDigits = 1,
    this.maxKm = 100,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<RestaurantController>(builder: (controller) {
      final label = controller.formatRestaurantDistance(
        LatLng(double.parse(latitude), double.parse(longitude)),
        fractionDigits: fractionDigits,
        maxKm: maxKm,
      );
      return Text(
        suffix == null ? label : '$label$suffix',
        style: style,
      );
    });
  }
}
