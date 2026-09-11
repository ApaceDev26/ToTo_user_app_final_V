import 'package:flutter/material.dart';

/// Lumen Atelier color tokens. No raw hex in feature UI — use these.
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.ink,
    required this.inkMuted,
    required this.inkFaint,
    required this.canvas,
    required this.surface,
    required this.surfaceElevated,
    required this.line,
    required this.lineStrong,
    required this.accent,
    required this.accentSoft,
    required this.accentHover,
    required this.warm,
    required this.warmSoft,
    required this.success,
    required this.warning,
    required this.danger,
    required this.rating,
    required this.overlay,
    required this.glass,
    required this.onAccent,
  });

  final Color ink;
  final Color inkMuted;
  final Color inkFaint;
  final Color canvas;
  final Color surface;
  final Color surfaceElevated;
  final Color line;
  final Color lineStrong;
  final Color accent;
  final Color accentSoft;
  final Color accentHover;
  final Color warm;
  final Color warmSoft;
  final Color success;
  final Color warning;
  final Color danger;
  final Color rating;
  final Color overlay;
  final Color glass;
  final Color onAccent;

  static const light = AppColors(
    ink: Color(0xFF14110E),
    inkMuted: Color(0xFF6B645C),
    inkFaint: Color(0xFF9A928A),
    canvas: Color(0xFFF7F4EF),
    surface: Color(0xFFFFFFFF),
    surfaceElevated: Color(0xFFFAF8F5),
    line: Color(0xFFE4DFD6),
    lineStrong: Color(0xFFC9C2B6),
    accent: Color(0xFFF39C12),
    accentSoft: Color(0xFFFEF3E0),
    accentHover: Color(0xFFD68910),
    warm: Color(0xFFC45C26),
    warmSoft: Color(0xFFF8E8DE),
    success: Color(0xFF1F7A4C),
    warning: Color(0xFFB58100),
    danger: Color(0xFFC0392B),
    rating: Color(0xFFD4A017),
    overlay: Color(0x7314110E),
    glass: Color(0xB8FFFFFF),
    onAccent: Color(0xFF14110E),
  );

  static const dark = AppColors(
    ink: Color(0xFFF7F3EE),
    inkMuted: Color(0xFFB0A89E),
    inkFaint: Color(0xFF857C72),
    canvas: Color(0xFF100E0C),
    surface: Color(0xFF1A1714),
    surfaceElevated: Color(0xFF221E1A),
    line: Color(0xFF322E28),
    lineStrong: Color(0xFF433E36),
    accent: Color(0xFFF39C12),
    accentSoft: Color(0xFF3A2A14),
    accentHover: Color(0xFFFFB340),
    warm: Color(0xFFE8915A),
    warmSoft: Color(0xFF3A2A1F),
    success: Color(0xFF4CAF7A),
    warning: Color(0xFFE0B040),
    danger: Color(0xFFE57373),
    rating: Color(0xFFE0B040),
    overlay: Color(0x8C000000),
    glass: Color(0xCC1A1714),
    onAccent: Color(0xFF100E0C),
  );

  static AppColors of(BuildContext context) {
    return Theme.of(context).extension<AppColors>() ??
        (Theme.of(context).brightness == Brightness.dark ? dark : light);
  }

  @override
  AppColors copyWith({
    Color? ink,
    Color? inkMuted,
    Color? inkFaint,
    Color? canvas,
    Color? surface,
    Color? surfaceElevated,
    Color? line,
    Color? lineStrong,
    Color? accent,
    Color? accentSoft,
    Color? accentHover,
    Color? warm,
    Color? warmSoft,
    Color? success,
    Color? warning,
    Color? danger,
    Color? rating,
    Color? overlay,
    Color? glass,
    Color? onAccent,
  }) {
    return AppColors(
      ink: ink ?? this.ink,
      inkMuted: inkMuted ?? this.inkMuted,
      inkFaint: inkFaint ?? this.inkFaint,
      canvas: canvas ?? this.canvas,
      surface: surface ?? this.surface,
      surfaceElevated: surfaceElevated ?? this.surfaceElevated,
      line: line ?? this.line,
      lineStrong: lineStrong ?? this.lineStrong,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      accentHover: accentHover ?? this.accentHover,
      warm: warm ?? this.warm,
      warmSoft: warmSoft ?? this.warmSoft,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      danger: danger ?? this.danger,
      rating: rating ?? this.rating,
      overlay: overlay ?? this.overlay,
      glass: glass ?? this.glass,
      onAccent: onAccent ?? this.onAccent,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      ink: Color.lerp(ink, other.ink, t)!,
      inkMuted: Color.lerp(inkMuted, other.inkMuted, t)!,
      inkFaint: Color.lerp(inkFaint, other.inkFaint, t)!,
      canvas: Color.lerp(canvas, other.canvas, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceElevated: Color.lerp(surfaceElevated, other.surfaceElevated, t)!,
      line: Color.lerp(line, other.line, t)!,
      lineStrong: Color.lerp(lineStrong, other.lineStrong, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      accentHover: Color.lerp(accentHover, other.accentHover, t)!,
      warm: Color.lerp(warm, other.warm, t)!,
      warmSoft: Color.lerp(warmSoft, other.warmSoft, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      rating: Color.lerp(rating, other.rating, t)!,
      overlay: Color.lerp(overlay, other.overlay, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
    );
  }
}
