import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper class for managing Android system UI, specifically navigation bar styling.
/// This helper ensures proper configuration for Android 10+ devices while remaining
/// iOS-compatible (no-op on iOS).
class SystemUIHelper {
  /// Determines the appropriate icon brightness (light or dark) based on the
  /// background color's luminance. Uses the standard relative luminance formula.
  ///
  /// Returns:
  /// - [Brightness.dark] for light backgrounds (dark icons)
  /// - [Brightness.light] for dark backgrounds (light icons)
  static Brightness getIconBrightnessForColor(Color color) {
    // Calculate relative luminance
    final double luminance = color.computeLuminance();
    // Threshold: 0.5 means if background is lighter than 50%, use dark icons
    return luminance > 0.5 ? Brightness.dark : Brightness.light;
  }

  /// Creates a [SystemUiOverlayStyle] configured for Android navigation bar.
  ///
  /// Parameters:
  /// - [navigationBarColor]: The color for the Android system navigation bar
  /// - [iconBrightness]: Optional brightness for navigation bar icons. If null,
  ///   it's automatically calculated based on the background color
  /// - [statusBarColor]: Optional status bar color (transparent by default)
  /// - [statusBarIconBrightness]: Optional status bar icon brightness
  ///
  /// Note: This only affects Android devices. iOS will ignore navigation bar properties.
  static SystemUiOverlayStyle getNavigationBarStyle({
    required Color navigationBarColor,
    Brightness? iconBrightness,
    Color? statusBarColor,
    Brightness? statusBarIconBrightness,
  }) {
    final Brightness calculatedIconBrightness =
        iconBrightness ?? getIconBrightnessForColor(navigationBarColor);

    return SystemUiOverlayStyle(
      // Navigation bar properties (Android only)
      systemNavigationBarColor: navigationBarColor,
      systemNavigationBarIconBrightness: calculatedIconBrightness,
      systemNavigationBarDividerColor: Colors.transparent, // For Android 10+

      // Status bar properties (optional)
      statusBarColor: statusBarColor ?? Colors.transparent,
      statusBarIconBrightness: statusBarIconBrightness,
      statusBarBrightness: statusBarIconBrightness == Brightness.dark
          ? Brightness.light
          : Brightness.dark, // iOS compatibility
    );
  }

  /// Wraps a widget with AnnotatedRegion for system UI overlay styling.
  /// This is the recommended Flutter approach for per-screen system UI customization.
  ///
  /// Parameters:
  /// - [child]: The widget to wrap
  /// - [navigationBarColor]: Color for Android navigation bar
  /// - [iconBrightness]: Optional icon brightness (auto-calculated if null)
  /// - [onlyAndroid]: If true, only applies on Android (default: true)
  static Widget wrapWithSystemUI({
    required Widget child,
    required Color navigationBarColor,
    Brightness? iconBrightness,
    bool onlyAndroid = true,
  }) {
    // Return unwrapped widget if web or not Android and onlyAndroid is true
    if (kIsWeb || (onlyAndroid && !Platform.isAndroid)) {
      return child;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: getNavigationBarStyle(
        navigationBarColor: navigationBarColor,
        iconBrightness: iconBrightness,
      ),
      child: child,
    );
  }

  /// Sets the system UI overlay style globally using SystemChrome.
  /// Use this in main() for app-wide configuration.
  ///
  /// Note: For per-screen customization, prefer using [wrapWithSystemUI] or
  /// wrapping Scaffold with AnnotatedRegion.
  static void setGlobalSystemUI({
    required Color navigationBarColor,
    Brightness? iconBrightness,
    bool onlyAndroid = true,
  }) {
    if (kIsWeb || (onlyAndroid && !Platform.isAndroid)) {
      return;
    }

    SystemChrome.setSystemUIOverlayStyle(
      getNavigationBarStyle(
        navigationBarColor: navigationBarColor,
        iconBrightness: iconBrightness,
      ),
    );
  }

  /// Gets an appropriate navigation bar color based on theme brightness.
  /// You can customize these default colors to match your app theme.
  static Color getNavigationBarColorForTheme({
    required bool isDarkTheme,
    Color? lightColor,
    Color? darkColor,
  }) {
    if (isDarkTheme) {
      return darkColor ?? const Color(0xFF1E1E1E); // Default dark color
    } else {
      return lightColor ?? Colors.white; // Default light color
    }
  }
}
