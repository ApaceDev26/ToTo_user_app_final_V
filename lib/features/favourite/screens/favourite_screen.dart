import 'package:toto_user/common/widgets/web_screen_title_widget.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/favourite/controllers/favourite_controller.dart';
import 'package:toto_user/features/favourite/widgets/fav_item_view_widget.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/not_logged_in_screen.dart';
import 'package:toto_user/helper/in_app_messaging_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  FavouriteScreenState createState() => FavouriteScreenState();
}

class FavouriteScreenState extends State<FavouriteScreen>
    with SingleTickerProviderStateMixin {
  TabController? _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);
    _initCall();

    // Trigger in-app messages for favourite screen
    Future.delayed(const Duration(milliseconds: 800), () {
      InAppMessagingHelper.triggerForScreen('favourite');
      // Also check for immediate messages
      InAppMessagingHelper.checkForImmediateMessages();
    });
  }

  void _initCall() {
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<FavouriteController>().getFavouriteList(fromFavScreen: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBarWidget(
          onBackPressed: () => Get.back(),
          title: 'favourite'.tr,
          isBackButtonExist: true),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: Get.find<AuthController>().isLoggedIn()
          ? SafeArea(
              child: Column(children: [
              WebScreenTitleWidget(title: 'favourite'.tr),
              Container(
                width: Dimensions.webMaxWidth,
                decoration: BoxDecoration(
                  color: colors.surface,
                  border: Border(
                    bottom: BorderSide(color: colors.line, width: 1),
                  ),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: colors.accent,
                  indicatorWeight: 2.5,
                  labelColor: colors.accent,
                  unselectedLabelColor: colors.inkFaint,
                  unselectedLabelStyle: AppTypography.labelMd(colors.inkFaint),
                  labelStyle: AppTypography.labelLg(colors.accent),
                  tabs: [
                    Tab(text: 'food'.tr),
                    Tab(text: 'restaurants'.tr),
                  ],
                ),
              ),
              Expanded(
                  child: TabBarView(
                controller: _tabController,
                children: const [
                  FavItemViewWidget(isRestaurant: false),
                  FavItemViewWidget(isRestaurant: true),
                ],
              )),
            ]))
          : NotLoggedInScreen(callBack: (value) {
              _initCall();
              setState(() {});
            }),
    );
  }
}
