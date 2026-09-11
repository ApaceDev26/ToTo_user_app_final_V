import 'package:flutter/material.dart';

class AppDurations {
  AppDurations._();

  static const Duration instant = Duration(milliseconds: 100);
  static const Duration fast = Duration(milliseconds: 180);
  static const Duration normal = Duration(milliseconds: 280);
  static const Duration emphasis = Duration(milliseconds: 400);
  static const Duration slow = Duration(milliseconds: 600);

  static const Curve defaultCurve = Curves.easeOutCubic;
  static const Curve reciprocalCurve = Curves.easeInOut;
}
