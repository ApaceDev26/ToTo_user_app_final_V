import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart' show GetPlatform;
import 'directions_helper_web.dart'
    if (dart.library.io) 'directions_helper_stub.dart';

class DirectionsHelper {
  static const String _baseUrl =
      'https://maps.googleapis.com/maps/api/directions/json';

  // Google Maps API key from web/index.html
  static const String _apiKey = 'AIzaSyBqK05alVFuZ8nUJl4NxLYIsg6FyKZNr_w';

  /// Get directions between two points using Google Maps Directions API
  static Future<List<LatLng>?> getDirections({
    required LatLng origin,
    required LatLng destination,
    LatLng? waypoint, // Optional waypoint (delivery man's current location)
  }) async {
    // Use web-specific implementation on web platform to avoid CORS issues
    if (GetPlatform.isWeb) {
      print('🌐 Using Web DirectionsService (JavaScript API)');
      return await DirectionsHelperWeb.getDirections(
        origin: origin,
        destination: destination,
      );
    }

    // Use HTTP API for mobile platforms
    try {
      String url = '$_baseUrl?origin=${origin.latitude},${origin.longitude}'
          '&destination=${destination.latitude},${destination.longitude}'
          '&key=$_apiKey';

      // Add waypoint if provided (delivery man's current location)
      if (waypoint != null) {
        url += '&waypoints=${waypoint.latitude},${waypoint.longitude}';
      }

      print('🗺️ FETCHING DIRECTIONS: $url');
      print('🌐 Platform: ${GetPlatform.isWeb ? "WEB" : "MOBILE"}');

      final response = await http
          .get(
        Uri.parse(url),
        headers: GetPlatform.isWeb
            ? {
                'Accept': 'application/json',
              }
            : {},
      )
          .timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏱️ DIRECTIONS API TIMEOUT after 10 seconds');
          throw Exception('Directions API request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        print('🗺️ DIRECTIONS API RESPONSE: ${data['status']}');
        print(
            '🗺️ FULL RESPONSE: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}...');

        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          List<LatLng> points = [];

          // Get the first route (usually the fastest)
          final route = data['routes'][0];
          final legs = route['legs'];

          print('🗺️ ROUTE LEGS: ${legs.length}');

          for (var leg in legs) {
            final steps = leg['steps'];
            print('🗺️ LEG STEPS: ${steps.length}');
            for (var step in steps) {
              final polyline = step['polyline']['points'];
              // Decode the polyline
              points.addAll(_decodePolyline(polyline));
            }
          }

          print('✅ DIRECTIONS SUCCESS: ${points.length} points');
          return points;
        } else {
          print('❌ DIRECTIONS ERROR: ${data['status']}');
          if (data['error_message'] != null) {
            print('❌ ERROR MESSAGE: ${data['error_message']}');
          }
          if (data['status'] == 'REQUEST_DENIED') {
            print(
                '⚠️ API KEY ISSUE: The API key may not have Directions API enabled or has restrictions');
          }
          return null;
        }
      } else {
        print('❌ HTTP ERROR: ${response.statusCode}');
        print('❌ RESPONSE HEADERS: ${response.headers}');
        print('❌ RESPONSE BODY: ${response.body}');
        if (GetPlatform.isWeb && response.statusCode == 0) {
          print(
              '⚠️ CORS ERROR: This is likely a CORS (Cross-Origin Resource Sharing) issue.');
          print(
              '⚠️ SOLUTION: Enable CORS for the API key in Google Cloud Console or use a backend proxy.');
        }
        return null;
      }
    } catch (e, stackTrace) {
      print('❌ DIRECTIONS EXCEPTION: $e');
      print('❌ STACK TRACE: $stackTrace');
      if (GetPlatform.isWeb && e.toString().contains('XMLHttpRequest')) {
        print(
            '⚠️ This is a CORS error - the browser blocked the request to Google Maps API');
      }
      return null;
    }
  }

  /// Decode Google Maps polyline string to LatLng points
  static List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < polyline.length) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  /// Get route from restaurant to customer (before pickup)
  static Future<List<LatLng>?> getRestaurantToCustomerRoute({
    required LatLng restaurant,
    required LatLng customer,
  }) async {
    return await getDirections(
      origin: restaurant,
      destination: customer,
    );
  }

  /// Get route from restaurant through delivery man to customer (after pickup)
  static Future<List<LatLng>?> getDeliveryRoute({
    required LatLng restaurant,
    required LatLng deliveryMan,
    required LatLng customer,
  }) async {
    return await getDirections(
      origin: restaurant,
      destination: customer,
      waypoint: deliveryMan,
    );
  }

  /// Test method to verify API key is working
  static Future<bool> testApiKey() async {
    try {
      // Test with a simple route
      LatLng origin = LatLng(40.7128, -74.0060); // New York
      LatLng destination = LatLng(40.7589, -73.9851); // Times Square

      List<LatLng>? result = await getDirections(
        origin: origin,
        destination: destination,
      );

      return result != null && result.isNotEmpty;
    } catch (e) {
      print('❌ API KEY TEST FAILED: $e');
      return false;
    }
  }

  /// Create a curved path between two points as a fallback when Directions API fails
  /// This creates intermediate points that simulate a road-like curve
  static List<LatLng> createCurvedPath(LatLng start, LatLng end,
      {int segments = 20}) {
    List<LatLng> points = [];

    // Calculate the midpoint with some offset to create a curve
    double midLat = (start.latitude + end.latitude) / 2;
    double midLng = (start.longitude + end.longitude) / 2;

    // Calculate perpendicular offset for curve
    double latDiff = end.latitude - start.latitude;
    double lngDiff = end.longitude - start.longitude;

    // Create a curved path using bezier-like interpolation
    for (int i = 0; i <= segments; i++) {
      double t = i / segments;

      // Quadratic bezier curve formula
      // B(t) = (1-t)²P0 + 2(1-t)tP1 + t²P2
      double t2 = t * t;
      double mt = 1 - t;
      double mt2 = mt * mt;

      // Add slight curve offset perpendicular to the direct path
      double curveOffset = 4 * t * mt * 0.1; // Creates a smooth curve

      double lat = mt2 * start.latitude +
          2 * mt * t * (midLat + lngDiff * curveOffset) +
          t2 * end.latitude;
      double lng = mt2 * start.longitude +
          2 * mt * t * (midLng - latDiff * curveOffset) +
          t2 * end.longitude;

      points.add(LatLng(lat, lng));
    }

    print('🎨 CREATED CURVED PATH: ${points.length} points (fallback mode)');
    return points;
  }
}
