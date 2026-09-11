import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:ui' as ui;

import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerHelper {
  /// Target logical size for map markers (smaller = less dominant on map).
  static const int _markerSize = 36;

  static Future<BitmapDescriptor> convertAssetToBitmapDescriptor({
    required final String imagePath,
    final int? width,
    final int? height,
  }) async {
    try {
      final int targetW = width ?? _markerSize;
      final int targetH = height ?? _markerSize;

      // Resize by decoding at exact pixel dimensions so marker displays at correct size on map (web and mobile).
      // BitmapDescriptor.asset + ImageConfiguration(size) does not reliably control display size on web.
      final ByteData byteDataFromImage =
          await rootBundle.load(imagePath).timeout(const Duration(seconds: 8));
      final ui.Codec codec = await ui
          .instantiateImageCodec(byteDataFromImage.buffer.asUint8List(),
              targetWidth: targetW, targetHeight: targetH)
          .timeout(const Duration(seconds: 8));
      final ui.FrameInfo frameInfo =
          await codec.getNextFrame().timeout(const Duration(seconds: 8));
      final ByteData? byteDataFromFrame = await frameInfo.image
          .toByteData(format: ui.ImageByteFormat.png)
          .timeout(const Duration(seconds: 8));
      if (byteDataFromFrame != null) {
        final Uint8List uint8List = byteDataFromFrame.buffer.asUint8List();
        return BitmapDescriptor.bytes(uint8List);
      }
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    } catch (_) {
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue);
    }
  }
}
