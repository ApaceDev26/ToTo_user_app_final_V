import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_durations.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/design_system/components/app_button.dart';

class AppSheet {
  AppSheet._();

  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) {
    final colors = AppColors.of(context);
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: colors.surface,
      barrierColor: colors.overlay,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: AppSpacing.sm),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: colors.lineStrong,
                borderRadius: AppRadius.pillAll,
              ),
            ),
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}

class AppDialog {
  AppDialog._();

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    String? message,
    Widget? content,
    String? confirmLabel,
    String? cancelLabel,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool destructive = false,
  }) {
    final colors = AppColors.of(context);
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: colors.overlay,
      transitionDuration: AppDurations.fast,
      pageBuilder: (ctx, a1, a2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Container(
                margin: const EdgeInsets.all(AppSpacing.x2l),
                padding: const EdgeInsets.all(AppSpacing.x2l),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: AppRadius.lgAll,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: AppTypography.titleMd(colors.ink)),
                    if (message != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Text(message, style: AppTypography.bodyMd(colors.inkMuted)),
                    ],
                    if (content != null) ...[
                      const SizedBox(height: AppSpacing.lg),
                      content,
                    ],
                    const SizedBox(height: AppSpacing.x2l),
                    Row(
                      children: [
                        if (cancelLabel != null)
                          Expanded(
                            child: AppButton(
                              label: cancelLabel,
                              variant: AppButtonVariant.secondary,
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                onCancel?.call();
                              },
                            ),
                          ),
                        if (cancelLabel != null && confirmLabel != null)
                          const SizedBox(width: AppSpacing.sm),
                        if (confirmLabel != null)
                          Expanded(
                            child: AppButton(
                              label: confirmLabel,
                              variant: destructive
                                  ? AppButtonVariant.destructive
                                  : AppButtonVariant.primary,
                              onPressed: () {
                                Navigator.of(ctx).pop(true as T?);
                                onConfirm?.call();
                              },
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (ctx, anim, _, child) {
        return FadeTransition(
          opacity: anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.96, end: 1.0).animate(
              CurvedAnimation(parent: anim, curve: AppDurations.defaultCurve),
            ),
            child: child,
          ),
        );
      },
    );
  }
}

class AppSnack {
  AppSnack._();

  static void show(
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
    EdgeInsets? margin,
  }) {
    final context = Get.context;
    if (context == null) return;
    final colors = AppColors.of(context);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTypography.bodyMd(
            isError ? colors.onAccent : colors.canvas,
          ),
        ),
        backgroundColor: isError ? colors.danger : colors.ink,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.smAll),
        margin: margin ?? const EdgeInsets.all(AppSpacing.lg),
      ),
    );
  }

  static void error(String message) => show(message, isError: true);
}
