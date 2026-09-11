import 'package:flutter/material.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.color,
    this.foreground,
  });

  final String label;
  final Color? color;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bg = color ?? colors.accent;
    final fg = foreground ?? colors.onAccent;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.pillAll,
      ),
      child: Text(label, style: AppTypography.labelSm(fg)),
    );
  }
}

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: selected ? colors.accentSoft : colors.surface,
        borderRadius: AppRadius.smAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.smAll,
          child: Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            decoration: BoxDecoration(
              borderRadius: AppRadius.smAll,
              border: Border.all(
                color: selected ? colors.accent : colors.line,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leading != null) ...[
                  leading!,
                  const SizedBox(width: AppSpacing.xs),
                ],
                Text(
                  label,
                  style: AppTypography.labelMd(
                    selected ? colors.accent : colors.ink,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppTag extends StatelessWidget {
  const AppTag.discount({super.key, required this.label}) : warm = true;
  const AppTag({super.key, required this.label, this.warm = false});

  final String label;
  final bool warm;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: warm ? colors.warmSoft : colors.accentSoft,
        borderRadius: AppRadius.xsAll,
      ),
      child: Text(
        label,
        style: AppTypography.labelSm(warm ? colors.warm : colors.accent),
      ),
    );
  }
}

class AppPriceText extends StatelessWidget {
  const AppPriceText({
    super.key,
    required this.price,
    this.originalPrice,
    this.large = false,
  });

  final String price;
  final String? originalPrice;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          price,
          style: large
              ? AppTypography.price(colors.accent)
              : AppTypography.labelLg(colors.accent),
        ),
        if (originalPrice != null) ...[
          const SizedBox(width: AppSpacing.xs),
          Text(
            originalPrice!,
            style: AppTypography.priceStrike(colors.inkFaint),
          ),
        ],
      ],
    );
  }
}

class AppQtyStepper extends StatelessWidget {
  const AppQtyStepper({
    super.key,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final primary = Theme.of(context).primaryColor;

    return Semantics(
      label: 'Quantity $quantity',
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: colors.accentSoft,
          borderRadius: AppRadius.smAll,
          border: Border.all(color: primary.withValues(alpha: 0.22)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StepperAction(
              icon: Icons.remove_rounded,
              onTap: onDecrement,
              primary: primary,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 18),
                child: Text(
                  '$quantity',
                  textAlign: TextAlign.center,
                  style: AppTypography.labelLg(colors.ink),
                ),
              ),
            ),
            _StepperAction(
              icon: Icons.add_rounded,
              onTap: onIncrement,
              primary: primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _StepperAction extends StatelessWidget {
  const _StepperAction({
    required this.icon,
    required this.onTap,
    required this.primary,
  });

  final IconData icon;
  final VoidCallback onTap;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3),
      child: Material(
        color: primary,
        borderRadius: BorderRadius.circular(AppRadius.xs - 2),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.xs - 2),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class AppRating extends StatelessWidget {
  const AppRating({
    super.key,
    required this.rating,
    this.count,
    this.size = 14,
  });

  final double rating;
  final int? count;
  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.star_rounded, size: size, color: colors.rating),
        const SizedBox(width: 2),
        Text(
          rating.toStringAsFixed(1),
          style: AppTypography.labelMd(colors.ink),
        ),
        if (count != null) ...[
          const SizedBox(width: 2),
          Text('($count)', style: AppTypography.bodySm(colors.inkFaint)),
        ],
      ],
    );
  }
}

class AppDivider extends StatelessWidget {
  const AppDivider({super.key, this.indent = 0, this.endIndent = 0});

  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: indent,
      endIndent: endIndent,
      color: AppColors.of(context).line,
    );
  }
}
