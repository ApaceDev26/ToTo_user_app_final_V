import 'dart:async';

import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Expands on add, collapses to a pinned "View Cart" chip after 1s.
/// Root overlay + [GlobalKey] state so route inset updates don't remount /
/// restart the expand↔collapse animation.
void showCartSnackBarWidget() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _CartFloatingBar.show();
  });
}

void hideCartSnackBarWidget() => _CartFloatingBar.hide();

class _CartFloatingBar {
  static OverlayEntry? _entry;
  static final GlobalKey<_CartFloatingBarViewState> _key =
      GlobalKey<_CartFloatingBarViewState>();
  static Timer? _routePoll;
  static String? _navSignature;
  static int _insertRetries = 0;

  static const _navHeight = 68.0;
  static const _navBottomOffset = 12.0;

  static OverlayState? get _overlay => Get.key.currentState?.overlay;

  static String _signature() {
    final canPop = Get.key.currentState?.canPop() ?? false;
    final path =
        (Get.rawRoute?.settings.name ?? Get.currentRoute).split('?').first;
    return '$path|$canPop';
  }

  /// Product bottom sheets / dialogs sit above the app; hide our bar while open
  /// so it doesn't cover Add to Cart (root overlay paints above Get.bottomSheet).
  static bool get isSheetOrDialogOpen {
    if (Get.isBottomSheetOpen == true) return true;
    if (Get.isDialogOpen == true) return true;
    final route = Get.rawRoute;
    return route is PopupRoute;
  }

  static void show() {
    final state = _key.currentState;
    if (_entry != null && state != null && state.mounted) {
      state.expand();
      state.setCoveredBySheet(isSheetOrDialogOpen);
      return;
    }

    final overlay = _overlay;
    if (overlay == null) {
      if (_insertRetries >= 5) {
        _insertRetries = 0;
        return;
      }
      _insertRetries++;
      Future<void>.delayed(const Duration(milliseconds: 50), () {
        if (_entry == null) show();
      });
      return;
    }

    _insertRetries = 0;
    hide();
    _navSignature = _signature();
    _entry = OverlayEntry(
      builder: (_) => _CartFloatingBarView(key: _key),
    );
    // Keep under future modal entries when possible; still hide while sheet open.
    overlay.insert(_entry!);
    _startRoutePoll();
  }

  static void hide() {
    _routePoll?.cancel();
    _routePoll = null;
    _entry?.remove();
    _entry = null;
    _navSignature = null;
  }

  static void _startRoutePoll() {
    _routePoll?.cancel();
    _routePoll = Timer.periodic(const Duration(milliseconds: 200), (_) {
      if (_entry == null) return;

      // Sheet open/close doesn't always change Get.currentRoute — check every tick.
      _key.currentState?.setCoveredBySheet(isSheetOrDialogOpen);

      final next = _signature();
      if (next == _navSignature) return;
      _navSignature = next;

      final path = next.split('|').first;
      if (path == RouteHelper.cart || path.startsWith('${RouteHelper.cart}/')) {
        hide();
        return;
      }
      // Only refresh bottom inset — do not remount / re-expand.
      _key.currentState?.reposition();
    });
  }

  static bool hasFloatingBottomNav(BuildContext context) {
    if (ResponsiveHelper.isDesktop(context)) return false;

    final nav = Get.key.currentState;
    if (nav != null && nav.canPop()) return false;

    final path =
        (Get.rawRoute?.settings.name ?? Get.currentRoute).split('?').first;
    return path == RouteHelper.initial || path == RouteHelper.main;
  }

  static double bottomInset(BuildContext context) {
    final pad = MediaQuery.paddingOf(context).bottom;
    const gap = Dimensions.paddingSizeSmall;
    if (ResponsiveHelper.isDesktop(context)) return gap;
    if (hasFloatingBottomNav(context)) {
      return pad + _navHeight + _navBottomOffset + gap;
    }
    return pad + gap;
  }
}

class _CartFloatingBarView extends StatefulWidget {
  const _CartFloatingBarView({super.key});

  @override
  State<_CartFloatingBarView> createState() => _CartFloatingBarViewState();
}

class _CartFloatingBarViewState extends State<_CartFloatingBarView> {
  static const _collapseDelay = Duration(seconds: 1);
  static const _animDuration = Duration(milliseconds: 320);

  bool _expanded = true;
  bool _coveredBySheet = false;
  double _bottom = 0;
  Timer? _collapseTimer;

  @override
  void initState() {
    super.initState();
    _coveredBySheet = _CartFloatingBar.isSheetOrDialogOpen;
    _scheduleCollapse();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bottom = _CartFloatingBar.bottomInset(context);
  }

  @override
  void dispose() {
    _collapseTimer?.cancel();
    super.dispose();
  }

  void expand() {
    if (!mounted) return;
    setState(() => _expanded = true);
    _scheduleCollapse();
  }

  /// Hide while product bottom sheet / dialog is open; keep state for restore.
  void setCoveredBySheet(bool covered) {
    if (!mounted || _coveredBySheet == covered) return;
    setState(() => _coveredBySheet = covered);
  }

  /// Route changed — update pin offset only.
  void reposition() {
    if (!mounted) return;
    final next = _CartFloatingBar.bottomInset(context);
    if (next == _bottom) return;
    setState(() => _bottom = next);
  }

  void _scheduleCollapse() {
    _collapseTimer?.cancel();
    _collapseTimer = Timer(_collapseDelay, () {
      if (!mounted) return;
      setState(() => _expanded = false);
    });
  }

  void _openCart() {
    _CartFloatingBar.hide();
    Get.toNamed(RouteHelper.getCartRoute());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final media = MediaQuery.of(context);

    // Still occupy the overlay slot, but invisible under sheets.
    if (_coveredBySheet) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: Dimensions.paddingSizeSmall,
      right: isDesktop
          ? media.size.width * 0.7
          : Dimensions.paddingSizeSmall,
      bottom: _bottom,
      child: Material(
        color: Colors.transparent,
        child: AnimatedAlign(
          duration: _animDuration,
          curve: Curves.easeInOutCubic,
          alignment: _expanded ? Alignment.center : Alignment.centerRight,
          child: Dismissible(
            key: const ValueKey('cart_floating_bar'),
            direction: DismissDirection.horizontal,
            onDismissed: (_) => _CartFloatingBar.hide(),
            child: Material(
              color: theme.primaryColor,
              elevation: 8,
              shadowColor: theme.primaryColor.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(Dimensions.radiusLarge),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: _openCart,
                child: AnimatedSize(
                  duration: _animDuration,
                  curve: Curves.easeInOutCubic,
                  alignment: Alignment.centerRight,
                  child: _expanded
                      ? _ExpandedBody(
                          message: 'item_added_to_cart'.tr,
                          actionLabel: 'view_cart'.tr,
                          onAction: _openCart,
                        )
                      : _CollapsedChip(label: 'view_cart'.tr),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandedBody extends StatelessWidget {
  const _ExpandedBody({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              style: robotoMedium.copyWith(color: Colors.white),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onAction,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionLabel,
              style: robotoMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CollapsedChip extends StatelessWidget {
  const _CollapsedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.shopping_bag_outlined,
              color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Text(
            label,
            style: robotoMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
