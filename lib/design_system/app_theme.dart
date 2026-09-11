import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_durations.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';

/// Builds Lumen Atelier ThemeData for light/dark.
class AppTheme {
  AppTheme._();

  static ThemeData light() => _build(AppColors.light, Brightness.light);

  static ThemeData dark() => _build(AppColors.dark, Brightness.dark);

  static ThemeData _build(AppColors colors, Brightness brightness) {
    final colorScheme = ColorScheme(
      brightness: brightness,
      primary: colors.accent,
      onPrimary: colors.onAccent,
      secondary: colors.accent,
      onSecondary: colors.onAccent,
      tertiary: colors.warm,
      onTertiary: colors.onAccent,
      error: colors.danger,
      onError: colors.onAccent,
      surface: colors.surface,
      onSurface: colors.ink,
      surfaceContainerHighest: colors.surfaceElevated,
      outline: colors.line,
      outlineVariant: colors.lineStrong,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTypography.primaryFontFamily,
      scaffoldBackgroundColor: colors.canvas,
      primaryColor: colors.accent,
      cardColor: colors.surface,
      canvasColor: colors.ink,
      disabledColor: colors.inkFaint,
      hintColor: colors.inkMuted,
      shadowColor: colors.ink.withValues(alpha: 0.04),
      dividerColor: colors.line,
      secondaryHeaderColor: colors.accentSoft,
      textTheme: AppTypography.textTheme(colors),
      primaryTextTheme: AppTypography.textTheme(colors),
      colorScheme: colorScheme,
      extensions: <ThemeExtension<dynamic>>[colors],
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        backgroundColor: colors.canvas,
        foregroundColor: colors.ink,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: AppTypography.titleMd(colors.ink),
        iconTheme: IconThemeData(color: colors.ink, size: 22),
      ),
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colors.accent,
          foregroundColor: colors.onAccent,
          minimumSize: const Size(64, 52),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
          textStyle: AppTypography.labelLg(),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.accent,
          textStyle: AppTypography.labelLg(colors.accent),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.ink,
          minimumSize: const Size(64, 52),
          side: BorderSide(color: colors.lineStrong),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        hintStyle: AppTypography.bodyMd(colors.inkFaint),
        border: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: colors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: colors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.smAll,
          borderSide: BorderSide(color: colors.accent, width: 1.5),
        ),
      ),
      dividerTheme: DividerThemeData(color: colors.line, thickness: 1, space: 1),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.accent,
        foregroundColor: colors.onAccent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
      ),
      bottomAppBarTheme: BottomAppBarThemeData(
        color: colors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        height: 64,
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: Colors.transparent,
        indicatorColor: colors.accent,
        labelColor: colors.accent,
        unselectedLabelColor: colors.inkMuted,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: colors.ink,
        contentTextStyle: AppTypography.bodyMd(colors.canvas),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colors.accent,
        circularTrackColor: colors.accentSoft,
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: colors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
  builders: {
    TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
    TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
  },
),
      splashFactory: InkRipple.splashFactory,
      materialTapTargetSize: MaterialTapTargetSize.padded,
    );
  }

  static Future<void> prefetchFonts() async {
    GoogleFonts.fraunces();
    GoogleFonts.notoSerifBengali();
    await GoogleFonts.pendingFonts();
  }
}

ThemeData get lumenLight => AppTheme.light();
ThemeData get lumenDark => AppTheme.dark();

Duration get appAnimNormal => AppDurations.normal;
