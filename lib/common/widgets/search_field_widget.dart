import 'package:flutter/services.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:flutter/material.dart';

class SearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? suffixIcon;
  final Function? iconPressed;
  final Function? onSubmit;
  final Function? onChanged;
  final Function()? onTap;
  const SearchFieldWidget(
      {super.key,
      required this.controller,
      required this.hint,
      this.suffixIcon,
      this.iconPressed,
      this.onSubmit,
      this.onChanged,
      this.onTap});

  @override
  State<SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<SearchFieldWidget> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return TextField(
      controller: widget.controller,
      textInputAction: TextInputAction.search,
      onTap: widget.onTap,
      autofocus: true,
      style: AppTypography.bodyMd(colors.ink),
      cursorColor: colors.accent,
      inputFormatters: [
        FilteringTextInputFormatter.deny(RegExp(
            r'[!@#$%^&*(),.?":{}|<>_+-/~`•√π÷×§∆£¢€¥°=©®™✓;]')),
      ],
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppTypography.bodyMd(colors.inkFaint),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        filled: false,
        isDense: true,
        contentPadding: EdgeInsets.zero,
        hoverColor: Colors.transparent,
      ),
      onSubmitted: widget.onSubmit as void Function(String)?,
      onChanged: widget.onChanged as void Function(String)?,
    );
  }
}
