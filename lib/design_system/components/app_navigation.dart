import 'package:flutter/material.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_durations.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    this.count,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int? count;
}

/// Floating island bottom navigation — not stock Material bar.
class AppNavIsland extends StatelessWidget {
  const AppNavIsland({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final bottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        0,
        AppSpacing.xl,
        bottom > 0 ? bottom : AppSpacing.lg,
      ),
      child: Material(
        color: colors.glass,
        elevation: 0,
        shadowColor: colors.ink.withValues(alpha: 0.08),
        borderRadius: AppRadius.xlAll,
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.94),
            borderRadius: AppRadius.xlAll,
            boxShadow: AppShadows.of(context, 3),
            border: Border.all(color: colors.line.withValues(alpha: 0.6)),
          ),
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final selected = i == currentIndex;
              return Expanded(
                child: Semantics(
                  button: true,
                  selected: selected,
                  label: item.count != null && item.count! > 0
                      ? '${item.label}, ${item.count} items'
                      : item.label,
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: AppRadius.xlAll,
                    child: AnimatedContainer(
                      duration: AppDurations.fast,
                      curve: AppDurations.defaultCurve,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(
                                selected ? item.activeIcon : item.icon,
                                size: 22,
                                color: selected ? colors.accent : colors.inkMuted,
                              ),
                              if (item.count != null && item.count! > 0)
                                Positioned(
                                  right: -8,
                                  top: -4,
                                  child: Container(
                                    constraints: const BoxConstraints(
                                      minWidth: 16,
                                      minHeight: 16,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: colors.accent,
                                      borderRadius: AppRadius.pillAll,
                                    ),
                                    child: Text(
                                      '${item.count}',
                                      textAlign: TextAlign.center,
                                      style: AppTypography.labelSm(colors.onAccent),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.label,
                            style: AppTypography.labelSm(
                              selected ? colors.accent : colors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

/// Floating cart dock when cart non-empty.
class AppCartDock extends StatelessWidget {
  const AppCartDock({
    super.key,
    required this.itemCount,
    required this.totalText,
    required this.onTap,
  });

  final int itemCount;
  final String totalText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Semantics(
      button: true,
      label: 'Cart, $itemCount items, $totalText',
      child: Material(
        color: colors.accent,
        borderRadius: AppRadius.mdAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.mdAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colors.onAccent.withValues(alpha: 0.15),
                    borderRadius: AppRadius.xsAll,
                  ),
                  child: Text(
                    '$itemCount',
                    style: AppTypography.labelLg(colors.onAccent),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    'View cart',
                    style: AppTypography.labelLg(colors.onAccent),
                  ),
                ),
                Text(totalText, style: AppTypography.labelLg(colors.onAccent)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
