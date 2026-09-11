import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_durations.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/order/controllers/order_controller.dart';
import 'package:toto_user/features/order/domain/models/order_model.dart';
import 'package:toto_user/features/order/screens/order_details_screen.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Space under floating island so it sits above the nav pill.
/// nav: bottom = safe + 12, height 68, gap 8.
double runningOrderNavClearance(BuildContext context) =>
    MediaQuery.paddingOf(context).bottom + 12 + 68 + 8;

class RunningOrderViewWidget extends StatefulWidget {
  final List<OrderModel> reversOrder;
  final Function() onMoreClick;
  final VoidCallback? onCollapse;
  final bool isExpanded;
  const RunningOrderViewWidget(
      {super.key,
      required this.reversOrder,
      required this.onMoreClick,
      this.onCollapse,
      this.isExpanded = false});

  @override
  State<RunningOrderViewWidget> createState() => _RunningOrderViewWidgetState();
}

class _RunningOrderViewWidgetState extends State<RunningOrderViewWidget> {
  double _dragDy = 0;

  void _onDragEnd(bool expanded, bool canExpand) {
    final shouldExpand = _dragDy < -20;
    final shouldCollapse = _dragDy > 20;
    _dragDy = 0;
    if (shouldExpand && canExpand && !expanded) {
      widget.onMoreClick();
    } else if (shouldCollapse && expanded) {
      widget.onCollapse?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final maxListHeight = MediaQuery.sizeOf(context).height * 0.38;

    return GetBuilder<OrderController>(builder: (orderController) {
      List<OrderModel> currentOrders = orderController.runningOrderList ?? [];
      List<OrderModel> displayOrders = List.from(currentOrders.reversed);

      bool showExpandedView =
          widget.isExpanded || orderController.bottomSheetExpanded;
      bool hasMultipleOrders = displayOrders.length >= 2;
      bool shouldShowCounter = !showExpandedView && hasMultipleOrders;
      final visibleCount =
          showExpandedView ? displayOrders.length : (displayOrders.isEmpty ? 0 : 1);

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onVerticalDragUpdate: (details) {
          _dragDy += details.delta.dy;
        },
        onVerticalDragEnd: (details) {
          final v = details.primaryVelocity ?? 0;
          if (v < -250 && hasMultipleOrders && !showExpandedView) {
            _dragDy = 0;
            widget.onMoreClick();
            return;
          }
          if (v > 250 && showExpandedView) {
            _dragDy = 0;
            widget.onCollapse?.call();
            return;
          }
          _onDragEnd(showExpandedView, hasMultipleOrders);
        },
        child: Material(
          color: colors.surfaceElevated,
          elevation: 14,
          shadowColor: Colors.black.withValues(alpha: 0.35),
          borderRadius: AppRadius.xlAll,
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  if (showExpandedView) {
                    widget.onCollapse?.call();
                  } else if (hasMultipleOrders) {
                    widget.onMoreClick();
                  }
                },
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 8),
                    height: 4,
                    width: 36,
                    decoration: BoxDecoration(
                      color: colors.lineStrong,
                      borderRadius: AppRadius.pillAll,
                    ),
                  ),
                ),
              ),
              AnimatedSize(
                duration: AppDurations.emphasis,
                curve: AppDurations.defaultCurve,
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: maxListHeight),
                  child: ListView.builder(
                    itemCount: visibleCount,
                    shrinkWrap: true,
                    physics: showExpandedView && visibleCount > 2
                        ? const BouncingScrollPhysics()
                        : const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemBuilder: (context, index) {
                    bool isFirstOrder = index == 0;

                    String? orderStatus = displayOrders[index].orderStatus ?? '';
                    int status = 0;

                    if (orderStatus == AppConstants.pending) {
                      status = 1;
                    } else if (orderStatus == AppConstants.accepted ||
                        orderStatus == AppConstants.processing ||
                        orderStatus == AppConstants.confirmed) {
                      status = 2;
                    } else if (orderStatus == AppConstants.handover ||
                        orderStatus == AppConstants.pickedUp) {
                      status = 3;
                    }

                    return Column(
                      children: [
                        InkWell(
                          onTap: () async {
                            await Get.toNamed(
                              RouteHelper.getOrderDetailsRoute(
                                  displayOrders[index].id),
                              arguments: OrderDetailsScreen(
                                orderId: displayOrders[index].id,
                                orderModel: displayOrders[index],
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                            child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    height: 52,
                                    width: 52,
                                    child: Image.asset(
                                        status == 2
                                            ? orderStatus ==
                                                        AppConstants
                                                            .confirmed ||
                                                    orderStatus ==
                                                        AppConstants.accepted
                                                ? Images.processingGif
                                                : Images.cookingGif
                                            : status == 3
                                                ? orderStatus ==
                                                        AppConstants.handover
                                                    ? Images.handoverGif
                                                    : Images.onTheWayGif
                                                : Images.pendingGif,
                                        height: 52,
                                        width: 52,
                                        fit: BoxFit.contain),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text.rich(
                                            TextSpan(
                                              text: '${'your_order_is'.tr} ',
                                              style: AppTypography.bodyMd(
                                                  colors.ink),
                                              children: [
                                                TextSpan(
                                                  text: displayOrders[index]
                                                      .orderStatus!
                                                      .tr,
                                                  style: AppTypography.bodyMd(
                                                      colors.accent),
                                                ),
                                              ],
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${'order'.tr} #${displayOrders[index].id}',
                                            style: AppTypography.labelSm(
                                                colors.inkMuted),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (isFirstOrder)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 8),
                                              child: Row(children: [
                                                Expanded(
                                                    child: _AnimatedTrackView(
                                                  context: context,
                                                  status: status >= 1,
                                                  delay: 0,
                                                )),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                    child: _AnimatedTrackView(
                                                  context: context,
                                                  status: status >= 2,
                                                  delay: 200,
                                                )),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                    child: _AnimatedTrackView(
                                                  context: context,
                                                  status: status >= 3,
                                                  delay: 400,
                                                )),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                    child: _AnimatedTrackView(
                                                  context: context,
                                                  status: status >= 4,
                                                  delay: 600,
                                                )),
                                              ]),
                                            ),
                                        ]),
                                  ),
                                  const SizedBox(width: 8),
                                  isFirstOrder && shouldShowCounter
                                      ? InkWell(
                                          onTap: widget.onMoreClick,
                                          borderRadius: AppRadius.pillAll,
                                          child: Container(
                                            padding: const EdgeInsets
                                                .symmetric(
                                                horizontal: 10, vertical: 8),
                                            decoration: BoxDecoration(
                                              color: colors.accentSoft,
                                              borderRadius: AppRadius.pillAll,
                                            ),
                                            child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                      '+${displayOrders.length - 1}',
                                                      style:
                                                          robotoBold.copyWith(
                                                              fontSize:
                                                                  Dimensions
                                                                      .fontSizeSmall,
                                                              color: colors
                                                                  .accent)),
                                                  Text('more'.tr,
                                                      style:
                                                          robotoBold.copyWith(
                                                              fontSize: Dimensions
                                                                  .fontSizeExtraSmall,
                                                              color: colors
                                                                  .accent)),
                                                ]),
                                          ),
                                        )
                                      : Icon(Icons.arrow_forward_ios_rounded,
                                          size: 14,
                                          color: colors.inkMuted),
                                ]),
                          ),
                        ),
                        if (index < visibleCount - 1)
                          Divider(
                            height: 1,
                            thickness: 1,
                            color: colors.line,
                            indent: 16,
                            endIndent: 16,
                          ),
                      ],
                    );
                  }),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _AnimatedTrackView extends StatefulWidget {
  final BuildContext context;
  final bool status;
  final int delay;

  const _AnimatedTrackView({
    required this.context,
    required this.status,
    required this.delay,
  });

  @override
  State<_AnimatedTrackView> createState() => _AnimatedTrackViewState();
}

class _AnimatedTrackViewState extends State<_AnimatedTrackView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _previousStatus = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.elasticOut,
      ),
    );
    _previousStatus = widget.status;
    if (widget.status) {
      Future.delayed(Duration(milliseconds: widget.delay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void didUpdateWidget(_AnimatedTrackView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.status != _previousStatus) {
      _previousStatus = widget.status;
      if (widget.status) {
        Future.delayed(Duration(milliseconds: widget.delay), () {
          if (mounted) {
            _controller.forward();
          }
        });
      } else {
        _controller.reverse();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(widget.context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: widget.status ? 1.0 : 0.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOutCubic,
      builder: (context, value, child) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.status ? _scaleAnimation.value : 1.0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 4,
                decoration: BoxDecoration(
                  color: Color.lerp(
                    colors.line,
                    colors.accent,
                    value,
                  ),
                  borderRadius: AppRadius.pillAll,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
