import 'package:flutter/material.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_icons.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';

class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const AppTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.centerTitle = false,
    this.transparent = false,
    this.onBack,
    this.showBack = true,
  });

  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool centerTitle;
  final bool transparent;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final canPop = Navigator.of(context).canPop();

    return AppBar(
      backgroundColor: transparent ? Colors.transparent : colors.canvas,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: centerTitle,
      leading: leading ??
          (showBack && canPop
              ? Semantics(
                  button: true,
                  label: 'Back',
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: AppIcons.sm, color: colors.ink),
                    onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                  ),
                )
              : null),
      title: titleWidget ??
          (title != null
              ? Text(title!, style: AppTypography.titleMd(colors.ink))
              : null),
      actions: actions,
    );
  }
}

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search',
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.readOnly = false,
    this.autofocus = false,
    this.suffix,
  });

  final TextEditingController? controller;
  final String hint;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final bool autofocus;
  final Widget? suffix;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      textField: true,
      label: hint,
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        style: AppTypography.bodyMd(colors.ink),
        cursorColor: colors.accent,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTypography.bodyMd(colors.inkFaint),
          prefixIcon: Icon(Icons.search_rounded,
              color: colors.inkMuted, size: AppIcons.md),
          suffixIcon: suffix,
          filled: true,
          fillColor: colors.surface,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          border: OutlineInputBorder(
            borderRadius: AppRadius.mdAll,
            borderSide: BorderSide(color: colors.line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdAll,
            borderSide: BorderSide(color: colors.line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.mdAll,
            borderSide: BorderSide(color: colors.accent, width: 1.5),
          ),
        ),
      ),
    );
  }
}
