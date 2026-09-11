import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';

void showCustomBottomSheet({required Widget child, double? maxHeight}) {
  final context = Get.context!;
  final colors = AppColors.of(context);

  showModalBottomSheet(
    isScrollControlled: true,
    useRootNavigator: true,
    context: context,
    backgroundColor: colors.surface,
    barrierColor: colors.overlay,
    shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
    builder: (context) {
      return ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: maxHeight ?? MediaQuery.of(context).size.height * 0.8,
        ),
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
      );
    },
  );
}
