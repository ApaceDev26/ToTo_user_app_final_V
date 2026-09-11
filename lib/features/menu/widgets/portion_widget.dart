import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_icons.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/design_system/components/app_primitives.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PortionWidget extends StatelessWidget {
  final String? icon;
  final String title;
  final bool hideDivider;
  final String route;
  final String? suffix;
  final Function()? onTap;
  final bool isIcon;
  final IconData? iconData;
  const PortionWidget(
      {super.key,
      this.icon,
      required this.title,
      required this.route,
      this.hideDivider = false,
      this.suffix,
      this.onTap,
      this.isIcon = false,
      this.iconData});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return InkWell(
      onTap: onTap ?? () => Get.toNamed(route),
      borderRadius: AppRadius.xsAll,
      child: Column(children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(children: [
            isIcon
                ? Icon(iconData, size: AppIcons.sm, color: colors.inkMuted)
                : icon != null
                    ? Image.asset(icon!,
                        height: AppIcons.sm,
                        width: AppIcons.sm,
                        color: colors.inkMuted)
                    : const SizedBox.shrink(),
            const SizedBox(width: AppSpacing.md),
            Expanded(
                child: Text(title, style: AppTypography.bodyMd(colors.ink))),
            if (suffix != null)
              Container(
                decoration: BoxDecoration(
                  color: colors.danger,
                  borderRadius: AppRadius.xsAll,
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.xxs, horizontal: AppSpacing.sm),
                child: Text(suffix!,
                    style: AppTypography.labelSm(colors.onAccent)),
              )
            else
              Icon(Icons.chevron_right_rounded,
                  size: AppIcons.md, color: colors.inkFaint),
          ]),
        ),
        hideDivider ? const SizedBox() : const AppDivider(),
      ]),
    );
  }
}
