import 'package:flutter/material.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';

class CustomLoaderWidget extends StatelessWidget {
  const CustomLoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.mdAll,
          boxShadow: AppShadows.of(context, 1),
        ),
        alignment: Alignment.center,
        child: CircularProgressIndicator(
          color: colors.accent,
          backgroundColor: colors.accentSoft,
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}
