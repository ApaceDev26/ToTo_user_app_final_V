import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/profile/controllers/profile_controller.dart';
import 'package:toto_user/features/wallet/controllers/wallet_controller.dart';
import 'package:toto_user/features/wallet/widgets/bonus_banner_widget.dart';
import 'package:toto_user/features/wallet/widgets/wallet_card_widget.dart';
import 'package:toto_user/features/wallet/widgets/wallet_history_widget.dart';
import 'package:toto_user/features/wallet/widgets/web_bonus_banner_view_widget.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/not_logged_in_screen.dart';
import 'package:toto_user/common/widgets/web_page_title_widget.dart';
import 'package:toto_user/helper/in_app_messaging_helper.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class WalletScreen extends StatefulWidget {
  final String? fundStatus;
  final String? token;
  final bool fromMenuPage;
  final bool fromNotification;
  const WalletScreen(
      {super.key,
      this.fundStatus,
      this.token,
      this.fromMenuPage = false,
      this.fromNotification = false});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final ScrollController scrollController = ScrollController();
  final tooltipController = JustTheController();

  @override
  void initState() {
    super.initState();

    _initCall();

    // Trigger in-app messages for wallet screen
    Future.delayed(const Duration(milliseconds: 800), () {
      InAppMessagingHelper.triggerForScreen('wallet');
      // Also check for immediate messages
      InAppMessagingHelper.checkForImmediateMessages();
    });
  }

  void _initCall() {
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<WalletController>().insertFilterList();
      Get.find<WalletController>().setWalletFilerType('all', isUpdate: false);

      if ((widget.fundStatus == 'success' ||
              widget.fundStatus == 'fail' ||
              widget.fundStatus == 'cancel') &&
          Get.find<WalletController>().getWalletAccessToken() != widget.token) {
        Future.delayed(const Duration(seconds: 2), () {
          final colors =
              Get.isDarkMode ? AppColors.dark : AppColors.light;
          Get.showSnackbar(GetSnackBar(
            backgroundColor: widget.fundStatus == 'fail'
                ? colors.danger
                : colors.success,
            message: widget.fundStatus == 'success'
                ? 'fund_successfully_added_to_wallet'.tr
                : 'fund_not_added_to_wallet'.tr,
            maxWidth: 500,
            duration: const Duration(seconds: 3),
            snackStyle: SnackStyle.FLOATING,
            margin: const EdgeInsets.all(AppSpacing.x3l),
            borderRadius: AppRadius.lg,
            isDismissible: true,
            dismissDirection: DismissDirection.horizontal,
          ));
        }).then((value) {
          Get.find<WalletController>().setWalletAccessToken(widget.token ?? '');
        });
      }
      Get.find<ProfileController>().getUserInfo();
      Get.find<WalletController>().getWalletBonusList(isUpdate: false);
      Get.find<WalletController>().getWalletTransactionList(
          '1', false, Get.find<WalletController>().type);

      Get.find<WalletController>().setOffset(1);

      scrollController.addListener(() {
        if (scrollController.position.pixels ==
                scrollController.position.maxScrollExtent &&
            Get.find<WalletController>().transactionList != null &&
            !Get.find<WalletController>().isLoading) {
          int pageSize =
              (Get.find<WalletController>().popularPageSize! / 10).ceil();
          if (Get.find<WalletController>().offset < pageSize) {
            Get.find<WalletController>()
                .setOffset(Get.find<WalletController>().offset + 1);
            if (kDebugMode) {
              print('end of the page');
            }
            Get.find<WalletController>().showBottomLoader();
            Get.find<WalletController>().getWalletTransactionList(
                Get.find<WalletController>().offset.toString(),
                false,
                Get.find<WalletController>().type);
          }
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();

    scrollController.dispose();
  }

  void _handleBack() {
    Get.closeAllSnackbars();
    // After add-fund return, route is often root — force home.
    final fromFundReturn = widget.fundStatus == 'success' ||
        widget.fundStatus == 'fail' ||
        widget.fundStatus == 'cancel';
    if (fromFundReturn || !Navigator.of(context).canPop()) {
      Get.offAllNamed(RouteHelper.getInitialRoute());
      return;
    }
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        backgroundColor: colors.canvas,
        appBar: CustomAppBarWidget(
            title: 'wallet'.tr,
            isBackButtonExist: true,
            onBackPressed: _handleBack),
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: GetBuilder<ProfileController>(builder: (profileController) {
          return isLoggedIn
              ? profileController.userInfoModel != null
                  ? SafeArea(
                      child: RefreshIndicator(
                        color: colors.accent,
                        onRefresh: () async {
                          Get.find<WalletController>()
                              .setWalletFilerType('all');
                          Get.find<WalletController>()
                              .getWalletTransactionList('1', true, 'all');
                          Get.find<ProfileController>().getUserInfo();
                        },
                        child: SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              WebScreenTitleWidget(title: 'wallet'.tr),
                              FooterViewWidget(
                                child: SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: GetBuilder<WalletController>(
                                      builder: (walletController) {
                                    return ResponsiveHelper.isDesktop(context)
                                        ? Padding(
                                            padding: const EdgeInsets.only(
                                                top: AppSpacing.lg),
                                            child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                      flex: 4,
                                                      child: Column(
                                                        children: [
                                                          Container(
                                                            decoration: ResponsiveHelper
                                                                    .isDesktop(
                                                                        context)
                                                                ? BoxDecoration(
                                                                    color: colors
                                                                        .surface,
                                                                    borderRadius:
                                                                        AppRadius
                                                                            .smAll,
                                                                    boxShadow:
                                                                        AppShadows.of(
                                                                            context,
                                                                            2),
                                                                  )
                                                                : null,
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(
                                                                    AppSpacing
                                                                        .xl),
                                                            child: WalletCardWidget(
                                                                tooltipController:
                                                                    tooltipController),
                                                          ),
                                                        ],
                                                      )),
                                                  const SizedBox(
                                                      width: AppSpacing.lg),
                                                  Expanded(
                                                      flex: 6,
                                                      child: Column(children: [
                                                        const WebBonusBannerViewWidget(),
                                                        Container(
                                                          decoration:
                                                              ResponsiveHelper
                                                                      .isDesktop(
                                                                          context)
                                                                  ? BoxDecoration(
                                                                      color: colors
                                                                          .surface,
                                                                      borderRadius:
                                                                          AppRadius
                                                                              .smAll,
                                                                      boxShadow:
                                                                          AppShadows.of(
                                                                              context,
                                                                              2),
                                                                    )
                                                                  : null,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(
                                                                  AppSpacing
                                                                      .xl),
                                                          child:
                                                              const WalletHistoryWidget(),
                                                        ),
                                                      ])),
                                                ]),
                                          )
                                        : Column(children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal:
                                                          AppSpacing.xl),
                                              child: WalletCardWidget(
                                                  tooltipController:
                                                      tooltipController),
                                            ),
                                            const BonusBannerWidget(),
                                            const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: AppSpacing.xl),
                                              child: WalletHistoryWidget(),
                                            )
                                          ]);
                                  }),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  : Center(
                      child: SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.accent,
                        ),
                      ),
                    )
              : NotLoggedInScreen(callBack: (value) {
                  _initCall();
                  setState(() {});
                });
        }),
      ),
    );
  }
}

class WalletShimmer extends StatelessWidget {
  final WalletController walletController;
  const WalletShimmer({super.key, required this.walletController});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GridView.builder(
      key: UniqueKey(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisSpacing: 50,
        mainAxisSpacing: ResponsiveHelper.isDesktop(context)
            ? AppSpacing.xl
            : 0.01,
        childAspectRatio: ResponsiveHelper.isDesktop(context) ? 5 : 4.1,
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 2,
      ),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: 10,
      padding:
          EdgeInsets.only(top: ResponsiveHelper.isDesktop(context) ? 28 : 25),
      itemBuilder: (context, index) {
        return Padding(
          padding:
              const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Shimmer(
            duration: const Duration(seconds: 2),
            enabled: walletController.transactionList == null,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 10,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: colors.line,
                                  borderRadius: AppRadius.xsAll)),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                              height: 10,
                              width: 70,
                              decoration: BoxDecoration(
                                  color: colors.line,
                                  borderRadius: AppRadius.xsAll)),
                        ]),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                              height: 10,
                              width: 50,
                              decoration: BoxDecoration(
                                  color: colors.line,
                                  borderRadius: AppRadius.xsAll)),
                          const SizedBox(height: AppSpacing.md),
                          Container(
                              height: 10,
                              width: 70,
                              decoration: BoxDecoration(
                                  color: colors.line,
                                  borderRadius: AppRadius.xsAll)),
                        ]),
                  ],
                ),
                Padding(
                    padding:
                        const EdgeInsets.only(top: AppSpacing.xl),
                    child: Divider(color: colors.inkFaint)),
              ],
            ),
          ),
        );
      },
    );
  }
}
