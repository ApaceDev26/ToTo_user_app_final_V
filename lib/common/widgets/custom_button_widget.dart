import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Legacy button — presentation rewired to Lumen Atelier tokens.
/// Prefer `AppButton` in new screens.
class CustomButtonWidget extends StatelessWidget {
  final Function? onPressed;
  final String buttonText;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final IconData? icon;
  final Color? color;
  final Color? textColor;
  final bool isLoading;
  final bool isBold;
  const CustomButtonWidget({
    super.key,
    this.onPressed,
    required this.buttonText,
    this.transparent = false,
    this.margin,
    this.width,
    this.height,
    this.fontSize,
    this.radius = AppRadius.sm,
    this.icon,
    this.color,
    this.textColor,
    this.isLoading = false,
    this.isBold = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final primary = Theme.of(context).primaryColor;
    final fillColor = color ?? colors.accent;
    final isPrimaryBg = !transparent &&
        (color == null || color == colors.accent || color == primary);
    final bg = onPressed == null
        ? colors.inkFaint.withValues(alpha: 0.35)
        : transparent
            ? Colors.transparent
            : fillColor;
    final fg = textColor ??
        (transparent
            ? colors.accent
            : isPrimaryBg
                ? Colors.white
                : colors.onAccent);

    final ButtonStyle flatButtonStyle = TextButton.styleFrom(
      backgroundColor: bg,
      minimumSize: Size(
        width ?? Dimensions.webMaxWidth,
        height ?? 52,
      ),
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radius),
        side: transparent
            ? BorderSide(color: colors.lineStrong)
            : BorderSide.none,
      ),
    );

    return Center(
      child: SizedBox(
        width: width ?? Dimensions.webMaxWidth,
        child: Padding(
          padding: margin ?? EdgeInsets.zero,
          child: TextButton(
            onPressed: isLoading ? null : onPressed as void Function()?,
            style: flatButtonStyle,
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(fg),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'loading'.tr,
                        style: AppTypography.labelLg(fg),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (icon != null)
                        Padding(
                          padding: const EdgeInsets.only(
                            right: AppSpacing.xs,
                          ),
                          child: Icon(icon, color: fg, size: 18),
                        ),
                      Flexible(
                        child: Text(
                          buttonText,
                          textAlign: TextAlign.center,
                          style: (isBold
                                  ? AppTypography.labelLg(fg)
                                  : AppTypography.bodyLg(fg))
                              .copyWith(
                            fontSize: fontSize ?? 14,
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
