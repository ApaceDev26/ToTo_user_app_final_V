import 'package:flutter/material.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, destructive, soft }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
    this.expand = true,
    this.height = 52,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final bool isLoading;
  final IconData? icon;
  final bool expand;
  final double height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final enabled = onPressed != null && !isLoading;

    late final Color bg;
    late final Color fg;
    BorderSide? side;

    switch (variant) {
      case AppButtonVariant.primary:
        bg = colors.accent;
        fg = Colors.white;
      case AppButtonVariant.secondary:
        bg = colors.surface;
        fg = colors.ink;
        side = BorderSide(color: colors.lineStrong);
      case AppButtonVariant.ghost:
        bg = Colors.transparent;
        fg = colors.accent;
      case AppButtonVariant.destructive:
        bg = colors.danger;
        fg = Colors.white;
      case AppButtonVariant.soft:
        bg = colors.accentSoft;
        fg = colors.accent;
    }

    final child = isLoading
        ? SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(fg),
            ),
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: fg),
                const SizedBox(width: AppSpacing.sm),
              ],
              Flexible(
                child: Text(
                  label,
                  style: AppTypography.labelLg(fg),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: expand ? double.infinity : null,
        height: height,
        child: Material(
          color: enabled
              ? bg
              : (variant == AppButtonVariant.ghost
                  ? Colors.transparent
                  : colors.inkFaint.withValues(alpha: 0.35)),
          borderRadius: AppRadius.smAll,
          child: InkWell(
            onTap: enabled ? onPressed : null,
            borderRadius: AppRadius.smAll,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: AppRadius.smAll,
                border: side != null ? Border.fromBorderSide(side) : null,
              ),
              child: Center(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: child,
              )),
            ),
          ),
        ),
      ),
    );
  }
}
