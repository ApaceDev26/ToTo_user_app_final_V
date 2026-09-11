import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/order/widgets/order_view_widget.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryOrderViewWidget extends StatefulWidget {
  final String searchQuery;
  const HistoryOrderViewWidget({super.key, this.searchQuery = ''});

  @override
  State<HistoryOrderViewWidget> createState() => _HistoryOrderViewWidgetState();
}

class _HistoryOrderViewWidgetState extends State<HistoryOrderViewWidget>
    with SingleTickerProviderStateMixin {
  late TabController _historyTabController;

  @override
  void initState() {
    super.initState();
    _historyTabController =
        TabController(length: 2, initialIndex: 0, vsync: this);
  }

  @override
  void dispose() {
    _historyTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: [
        Container(
          color: colors.canvas,
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Align(
                alignment: ResponsiveHelper.isDesktop(context)
                    ? Alignment.centerLeft
                    : Alignment.center,
                child: Container(
                  width: ResponsiveHelper.isDesktop(context)
                      ? 300
                      : Dimensions.webMaxWidth,
                  decoration: BoxDecoration(
                    color: ResponsiveHelper.isDesktop(context)
                        ? Colors.transparent
                        : colors.canvas,
                    border: ResponsiveHelper.isDesktop(context)
                        ? null
                        : Border(
                            bottom: BorderSide(color: colors.line, width: 1),
                          ),
                  ),
                  child: TabBar(
                    controller: _historyTabController,
                    indicatorColor: colors.accent,
                    indicatorWeight: 2.5,
                    labelColor: colors.accent,
                    unselectedLabelColor: colors.inkFaint,
                    unselectedLabelStyle:
                        AppTypography.labelMd(colors.inkFaint),
                    labelStyle: AppTypography.labelLg(colors.accent),
                    tabs: [
                      Tab(text: 'all'.tr),
                      Tab(text: 'refund'.tr),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _historyTabController,
            children: [
              OrderViewWidget(
                  isRunning: false,
                  showRefundOnly: false,
                  searchQuery: widget.searchQuery),
              OrderViewWidget(
                  isRunning: false,
                  showRefundOnly: true,
                  searchQuery: widget.searchQuery),
            ],
          ),
        ),
      ],
    );
  }
}
