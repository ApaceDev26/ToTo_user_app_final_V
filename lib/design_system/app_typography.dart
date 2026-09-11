import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toto_user/design_system/app_colors.dart';

/// Lumen Atelier type scale.
/// UI / body / labels = Noto Serif Bengali (supports BN + Latin).
/// Display = Fraunces (with Noto Serif Bengali glyph fallback).
class AppTypography {
  AppTypography._();

  static const String fontFamilyUi = 'Noto Serif Bengali';
  static const String fontFamilyDisplay = 'Fraunces';
  static const String fontFamilyBengali = 'Noto Serif Bengali';

  static String get _bengaliFamily =>
      GoogleFonts.notoSerifBengali().fontFamily ?? fontFamilyBengali;

  static String get primaryFontFamily =>
      GoogleFonts.notoSerifBengali().fontFamily ?? fontFamilyUi;

  static TextStyle _ui({
    required double size,
    required FontWeight weight,
    required double height,
    Color? color,
    TextDecoration? decoration,
  }) {
    return GoogleFonts.notoSerifBengali(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      decoration: decoration,
      letterSpacing: 0,
    );
  }

  static TextStyle _display({
    required double size,
    required FontWeight weight,
    required double height,
    Color? color,
  }) {
    return GoogleFonts.fraunces(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      letterSpacing: -0.5,
    ).copyWith(fontFamilyFallback: [_bengaliFamily]);
  }

  /// Catalog copy — same as UI (Noto Serif Bengali); kept for call-site clarity.
  static TextStyle _catalog({
    required double size,
    required FontWeight weight,
    required double height,
    Color? color,
    TextDecoration? decoration,
    double letterSpacing = 0,
  }) {
    return GoogleFonts.notoSerifBengali(
      fontSize: size,
      fontWeight: weight,
      height: height,
      color: color,
      decoration: decoration,
      letterSpacing: letterSpacing,
    );
  }

  static TextStyle displayLg([Color? color]) =>
      _display(size: 40, weight: FontWeight.w600, height: 1.15, color: color);

  static TextStyle displayMd([Color? color]) =>
      _display(size: 32, weight: FontWeight.w600, height: 1.2, color: color);

  static TextStyle titleLg([Color? color]) =>
      _ui(size: 24, weight: FontWeight.w600, height: 1.25, color: color);

  static TextStyle titleMd([Color? color]) =>
      _ui(size: 20, weight: FontWeight.w600, height: 1.3, color: color);

  static TextStyle titleSm([Color? color]) =>
      _ui(size: 17, weight: FontWeight.w600, height: 1.35, color: color);

  static TextStyle bodyLg([Color? color]) =>
      _ui(size: 16, weight: FontWeight.w400, height: 1.5, color: color);

  static TextStyle bodyMd([Color? color]) =>
      _ui(size: 14, weight: FontWeight.w400, height: 1.5, color: color);

  static TextStyle bodySm([Color? color]) =>
      _ui(size: 12, weight: FontWeight.w400, height: 1.45, color: color);

  static TextStyle labelLg([Color? color]) =>
      _ui(size: 14, weight: FontWeight.w600, height: 1.2, color: color);

  static TextStyle labelMd([Color? color]) =>
      _ui(size: 12, weight: FontWeight.w600, height: 1.2, color: color);

  static TextStyle labelSm([Color? color]) =>
      _ui(size: 11, weight: FontWeight.w500, height: 1.2, color: color);

  static TextStyle price([Color? color]) =>
      _ui(size: 18, weight: FontWeight.w700, height: 1.2, color: color);

  static TextStyle priceStrike([Color? color]) => _ui(
        size: 13,
        weight: FontWeight.w400,
        height: 1.2,
        color: color,
        decoration: TextDecoration.lineThrough,
      );

  static TextStyle catalogDisplayMd([Color? color]) => _catalog(
        size: 32,
        weight: FontWeight.w600,
        height: 1.2,
        color: color,
      );

  static TextStyle catalogTitleSm([Color? color]) => _catalog(
        size: 17,
        weight: FontWeight.w600,
        height: 1.35,
        color: color,
      );

  static TextStyle catalogTitleMd([Color? color]) => _catalog(
        size: 20,
        weight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  static TextStyle catalogBodyMd([Color? color]) => _catalog(
        size: 14,
        weight: FontWeight.w400,
        height: 1.5,
        color: color,
      );

  static TextStyle catalogBodySm([Color? color]) => _catalog(
        size: 12,
        weight: FontWeight.w400,
        height: 1.45,
        color: color,
      );

  static TextStyle catalogLabelMd([Color? color]) => _catalog(
        size: 12,
        weight: FontWeight.w600,
        height: 1.2,
        color: color,
      );

  static TextTheme textTheme(AppColors colors) {
    return TextTheme(
      displayLarge: displayLg(colors.ink),
      displayMedium: displayMd(colors.ink),
      headlineLarge: titleLg(colors.ink),
      headlineMedium: titleMd(colors.ink),
      headlineSmall: titleSm(colors.ink),
      titleLarge: titleMd(colors.ink),
      titleMedium: titleSm(colors.ink),
      titleSmall: labelLg(colors.ink),
      bodyLarge: bodyLg(colors.ink),
      bodyMedium: bodyMd(colors.ink),
      bodySmall: bodySm(colors.inkMuted),
      labelLarge: labelLg(colors.ink),
      labelMedium: labelMd(colors.inkMuted),
      labelSmall: labelSm(colors.inkFaint),
    );
  }
}
