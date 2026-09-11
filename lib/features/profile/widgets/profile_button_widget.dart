import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_icons.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileButtonWidget extends StatelessWidget {
  final IconData? icon;
  final String title;
  final bool? isButtonActive;
  final Function onTap;
  final Color? color;
  final String? iconImage;
  final bool isThemeSwitchButton;
  const ProfileButtonWidget(
      {super.key,
      this.icon,
      required this.title,
      required this.onTap,
      this.isButtonActive,
      this.color,
      this.iconImage,
      this.isThemeSwitchButton = false});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return InkWell(
      onTap: onTap as void Function()?,
      borderRadius: AppRadius.smAll,
      child: Container(
        height: isThemeSwitchButton ? 48 : 64,
        padding: EdgeInsets.symmetric(
          horizontal: isThemeSwitchButton ? 0 : AppSpacing.lg,
          vertical: isButtonActive != null ? AppSpacing.xs : AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isThemeSwitchButton ? Colors.transparent : colors.surface,
          borderRadius: AppRadius.smAll,
          border: isDesktop || isThemeSwitchButton
              ? null
              : Border.all(color: colors.line, width: 1),
        ),
        child: Row(children: [
          iconImage != null
              ? Image.asset(iconImage!, height: 18, width: 25)
              : Icon(icon,
                  size: isThemeSwitchButton ? AppIcons.sm : AppIcons.md,
                  color: color ?? colors.inkMuted),
          const SizedBox(width: AppSpacing.md),
          Expanded(
              child: Text(title, style: AppTypography.bodyMd(colors.ink))),
          isButtonActive != null
              ? CupertinoSwitch(
                  value: isButtonActive!,
                  activeTrackColor: colors.accent,
                  onChanged: (bool? value) => onTap(),
                  inactiveTrackColor: colors.lineStrong,
                )
              : const SizedBox()
        ]),
      ),
    );
  }
}
