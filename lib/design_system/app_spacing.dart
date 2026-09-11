import 'package:flutter/material.dart';

/// 4pt spacing grid.
class AppSpacing {
  AppSpacing._();

  static const double xxs = 2;
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double x2l = 24;
  static const double x3l = 32;
  static const double x4l = 40;
  static const double x5l = 48;
  static const double x6l = 64;

  static const double cardGap = 12;
  static const double section = 40;

  static double page(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    if (w >= 1200) return 40;
    if (w >= 600) return 32;
    return 20;
  }

  static EdgeInsets pageInsets(BuildContext context) =>
      EdgeInsets.symmetric(horizontal: page(context));

  static const EdgeInsets cardPadding = EdgeInsets.all(lg);
  static const EdgeInsets sheetPadding =
      EdgeInsets.fromLTRB(xl, sm, xl, x2l);
}
