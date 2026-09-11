import 'package:flutter/material.dart';
import 'package:toto_user/design_system/app_colors.dart';

class AppElevation {
  AppElevation._();

  static const double level0 = 0;
  static const double level1 = 1;
  static const double level2 = 2;
  static const double level3 = 3;
  static const double level4 = 4;
}

class AppShadows {
  AppShadows._();

  static List<BoxShadow> level(
    int level, {
    required bool dark,
    Color? ink,
  }) {
    final base = ink ?? (dark ? const Color(0xFF000000) : const Color(0xFF14110E));
    switch (level) {
      case 0:
        return const [];
      case 1:
        return [
          BoxShadow(
            color: base.withValues(alpha: dark ? 0.35 : 0.04),
            offset: const Offset(0, 1),
            blurRadius: 2,
          ),
        ];
      case 2:
        return [
          BoxShadow(
            color: base.withValues(alpha: dark ? 0.4 : 0.06),
            offset: const Offset(0, 4),
            blurRadius: 12,
          ),
        ];
      case 3:
        return [
          BoxShadow(
            color: base.withValues(alpha: dark ? 0.45 : 0.08),
            offset: const Offset(0, 8),
            blurRadius: 24,
          ),
        ];
      case 4:
      default:
        return [
          BoxShadow(
            color: base.withValues(alpha: dark ? 0.5 : 0.10),
            offset: const Offset(0, 16),
            blurRadius: 40,
          ),
        ];
    }
  }

  static List<BoxShadow> of(BuildContext context, [int level = 2]) {
    final colors = AppColors.of(context);
    final dark = Theme.of(context).brightness == Brightness.dark;
    return AppShadows.level(level, dark: dark, ink: colors.ink);
  }
}
