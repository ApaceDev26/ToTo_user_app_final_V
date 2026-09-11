import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/order/controllers/order_controller.dart';
import 'package:toto_user/features/order/widgets/guest_track_order_input_view_widget.dart';
import 'package:toto_user/features/order/widgets/order_view_widget.dart';
import 'package:toto_user/features/order/widgets/history_order_view_widget.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/auth_helper.dart';
import 'package:toto_user/helper/in_app_messaging_helper.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/not_logged_in_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  OrderScreenState createState() => OrderScreenState();
}

class OrderScreenState extends State<OrderScreen>
    with TickerProviderStateMixin {
  TabController? _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, initialIndex: 0, vsync: this);
    initCall();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  void initCall() {
    if (AuthHelper.isLoggedIn()) {
      Get.find<OrderController>().getRunningOrders(1, limit: 10, notify: false);
      Get.find<OrderController>()
          .getRunningSubscriptionOrders(1, notify: false);
      Get.find<OrderController>().getHistoryOrders(1, notify: false);
      // Get.find<OrderController>().getSubscriptions(1, notify: false);
    }

    // Trigger in-app messages for order screen
    Future.delayed(const Duration(milliseconds: 800), () {
      InAppMessagingHelper.triggerForScreen('order');
      // Also check for immediate messages
      InAppMessagingHelper.checkForImmediateMessages();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    bool isLoggedIn = AuthHelper.isLoggedIn();
    bool isGuestCheckoutEnabled =
        Get.find<SplashController>().configModel?.guestCheckoutStatus ?? false;

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBarWidget(
          title: 'my_orders'.tr,
          isBackButtonExist: ResponsiveHelper.isDesktop(context)),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: isLoggedIn
          ? GetBuilder<OrderController>(
              builder: (orderController) {
                return Column(children: [
                  Container(
                    color: colors.canvas,
                    child: Column(
                      children: [
                        ResponsiveHelper.isDesktop(context)
                            ? Center(
                                child: Padding(
                                padding: const EdgeInsets.only(
                                    top: AppSpacing.sm),
                                child: Text('my_orders'.tr,
                                    style: AppTypography.titleMd(colors.ink)),
                              ))
                            : const SizedBox(),
                        // Search bar for order ID
                        Container(
                          color: colors.canvas,
                          child: Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                                vertical: AppSpacing.sm),
                            width: ResponsiveHelper.isDesktop(context)
                                ? Dimensions.webMaxWidth
                                : double.infinity,
                            decoration: BoxDecoration(
                              color: colors.surface,
                              borderRadius: AppRadius.mdAll,
                              border: Border.all(color: colors.line),
                              boxShadow: AppShadows.of(context, 1),
                            ),
                            child: SizedBox(
                              height: 50,
                              child: Row(
                                children: [
                                  const SizedBox(width: AppSpacing.lg),
                                  Icon(Icons.search,
                                      color: colors.inkFaint, size: 20),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: TextField(
                                      controller: _searchController,
                                      textInputAction: TextInputAction.search,
                                      style: AppTypography.bodyMd(colors.ink),
                                      cursorColor: colors.accent,
                                      decoration: InputDecoration(
                                        hintText: 'search_by_order_id'.tr,
                                        hintStyle: AppTypography.bodyMd(
                                            colors.inkFaint),
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
                                      onChanged: (value) {
                                        setState(() {
                                          _searchQuery = value.trim();
                                        });
                                      },
                                      onSubmitted: (value) {
                                        setState(() {
                                          _searchQuery = value.trim();
                                        });
                                      },
                                    ),
                                  ),
                                  if (_searchQuery.isNotEmpty)
                                    IconButton(
                                      icon: Icon(Icons.clear,
                                          size: 20, color: colors.inkMuted),
                                      onPressed: () {
                                        setState(() {
                                          _searchController.clear();
                                          _searchQuery = '';
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        Center(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: Align(
                              alignment: ResponsiveHelper.isDesktop(context)
                                  ? Alignment.centerLeft
                                  : Alignment.center,
                              child: Container(
                                width: ResponsiveHelper.isDesktop(context)
                                    ? 350
                                    : Dimensions.webMaxWidth,
                                decoration: BoxDecoration(
                                  color: ResponsiveHelper.isDesktop(context)
                                      ? Colors.transparent
                                      : colors.canvas,
                                  border: ResponsiveHelper.isDesktop(context)
                                      ? null
                                      : Border(
                                          bottom: BorderSide(
                                              color: colors.line, width: 1),
                                        ),
                                ),
                                child: TabBar(
                                  controller: _tabController,
                                  indicatorColor: colors.accent,
                                  indicatorWeight: 2.5,
                                  labelColor: colors.accent,
                                  unselectedLabelColor: colors.inkFaint,
                                  unselectedLabelStyle:
                                      AppTypography.labelMd(colors.inkFaint),
                                  labelStyle:
                                      AppTypography.labelLg(colors.accent),
                                  tabs: [
                                    Tab(text: 'running'.tr),
                                    Tab(text: 'subscription'.tr),
                                    Tab(text: 'history'.tr),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: TabBarView(
                    controller: _tabController,
                    children: [
                      OrderViewWidget(
                          isRunning: true, searchQuery: _searchQuery),
                      OrderViewWidget(
                          isRunning: false,
                          isSubscription: true,
                          searchQuery: _searchQuery),
                      HistoryOrderViewWidget(searchQuery: _searchQuery),
                    ],
                  )),
                ]);
              },
            )
          : isGuestCheckoutEnabled
              ? const GuestTrackOrderInputViewWidget()
              : NotLoggedInScreen(callBack: (bool value) {
                  initCall();
                  setState(() {});
                }),
    );
  }
}
