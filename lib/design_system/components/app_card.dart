import 'package:flutter/material.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';
import 'package:toto_user/design_system/app_spacing.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = AppSpacing.cardPadding,
    this.margin,
    this.elevation = 2,
    this.color,
    this.borderRadius,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final int elevation;
  final Color? color;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final radius = borderRadius ?? AppRadius.mdAll;

    final content = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? colors.surface,
        borderRadius: radius,
        boxShadow: AppShadows.of(context, elevation),
      ),
      child: child,
    );

    if (onTap == null) {
      return semanticLabel != null
          ? Semantics(label: semanticLabel, child: content)
          : content;
    }

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: content,
        ),
      ),
    );
  }
}
