import 'package:flutter/material.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_spacing.dart';

/// Soft Lumen Atelier header surface — canvas wash with a faint accent tint.
/// No loud primary dump; decorative orbs use accentSoft.
class MyPrimaryHeaderContainer extends StatelessWidget {
  const MyPrimaryHeaderContainer({
    super.key,
    required this.child,
    this.height,
  });

  final Widget child;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return SizedBox(
      height: height,
      child: Container(
        color: colors.canvas,
        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
        child: Stack(
          children: [
            Positioned(
              top: -120,
              right: -80,
              child: IgnorePointer(
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.accentSoft.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              left: -60,
              child: IgnorePointer(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colors.accent.withValues(alpha: 0.06),
                  ),
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
