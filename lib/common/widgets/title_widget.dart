import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/helper/responsive_helper.dart';

class TitleWidget extends StatelessWidget {
  final String title;
  final VoidCallback? onTap;
  const TitleWidget({super.key, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.displayMd(colors.ink).copyWith(
                fontSize: isDesktop ? 26 : 22,
                height: 1.2,
                letterSpacing: -0.4,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onTap != null && !isDesktop)
            _ViewAllChip(onTap: onTap!, colors: colors),
          if (onTap != null && isDesktop)
            InkWell(
              onTap: onTap,
              borderRadius: AppRadius.pillAll,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'view_all'.tr,
                      style: AppTypography.labelMd(colors.accent),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: colors.accentSoft,
                        boxShadow: AppShadows.of(context, 1),
                      ),
                      padding: const EdgeInsets.all(AppSpacing.xs),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 12,
                        color: colors.accent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ViewAllChip extends StatelessWidget {
  const _ViewAllChip({required this.onTap, required this.colors});

  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.pillAll,
      child: Container(
        height: 32,
        width: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.surface,
          border: Border.all(color: colors.line),
          boxShadow: AppShadows.of(context, 1),
        ),
        child: Icon(
          Icons.arrow_forward_rounded,
          size: 16,
          color: colors.accent,
        ),
      ),
    );
  }
}
