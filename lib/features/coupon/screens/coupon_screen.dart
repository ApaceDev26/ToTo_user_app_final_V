import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/coupon/controllers/coupon_controller.dart';
import 'package:toto_user/features/coupon/widgets/coupon_card_widget.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/no_data_screen_widget.dart';
import 'package:toto_user/common/widgets/not_logged_in_screen.dart';
import 'package:toto_user/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CouponScreen extends StatefulWidget {
  final bool fromCheckout;

  const CouponScreen({super.key, required this.fromCheckout});
  @override
  State<CouponScreen> createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {

  final ScrollController scrollController = ScrollController();
  bool _isLoggedIn = Get.find<AuthController>().isLoggedIn();
  List<JustTheController>? _availableToolTipControllerList;
  List<JustTheController>? _unavailableToolTipControllerList;

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  Future<void> _initCall() async {
    if(Get.find<AuthController>().isLoggedIn()) {
      await Get.find<CouponController>().getCouponList();
      _availableToolTipControllerList = [];
      _unavailableToolTipControllerList = [];

      if(Get.find<CouponController>().customerCouponModel?.available != null && Get.find<CouponController>().customerCouponModel!.available!.isNotEmpty) {
        for(int i = 0; i < Get.find<CouponController>().customerCouponModel!.available!.length; i++) {
          _availableToolTipControllerList!.add(JustTheController());
        }
      }

      if(Get.find<CouponController>().customerCouponModel?.unavailable != null && Get.find<CouponController>().customerCouponModel!.unavailable!.isNotEmpty) {
        for(int i = 0; i < Get.find<CouponController>().customerCouponModel!.unavailable!.length; i++) {
          _unavailableToolTipControllerList!.add(JustTheController());
        }
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBarWidget(title: 'coupon'.tr),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: _isLoggedIn ? GetBuilder<CouponController>(builder: (couponController) {
        return (couponController.customerCouponModel?.available != null && _availableToolTipControllerList != null) ? couponController.customerCouponModel!.available!.isNotEmpty ? RefreshIndicator(
          color: colors.accent,
          onRefresh: () async {
            await couponController.getCouponList();
          },
          child: SingleChildScrollView(
            controller: scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                WebScreenTitleWidget(title: 'coupon'.tr),
                FooterViewWidget(
                  child: Center(child: SizedBox(width: Dimensions.webMaxWidth, child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Padding(
                        padding: const EdgeInsets.only(
                          left: AppSpacing.xl,
                          right: AppSpacing.xl,
                          top: AppSpacing.lg,
                        ),
                        child: Text(
                          'available_coupon'.tr,
                          style: AppTypography.titleSm(colors.ink),
                        ),
                      ),

                      GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveHelper.isDesktop(context) ? 3 : ResponsiveHelper.isTab(context) ? 2 : 1,
                          mainAxisSpacing: AppSpacing.xl,
                          crossAxisSpacing: AppSpacing.xl,
                          childAspectRatio: ResponsiveHelper.isMobile(context) ? 3 : 3,
                        ),
                        itemCount: couponController.customerCouponModel?.available?.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        itemBuilder: (context, index) {
                          return JustTheTooltip(
                            backgroundColor: colors.ink,
                            controller: _availableToolTipControllerList![index],
                            preferredDirection: AxisDirection.up,
                            tailLength: 14,
                            tailBaseWidth: 20,
                            triggerMode: TooltipTriggerMode.manual,
                            content: Padding(
                              padding: const EdgeInsets.all(AppSpacing.sm),
                              child: Text(
                                '${'code_copied'.tr} !',
                                style: AppTypography.bodySm(colors.canvas),
                              ),
                            ),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              onTap: () async {
                                _availableToolTipControllerList![index].showTooltip();
                                Clipboard.setData(ClipboardData(text: couponController.customerCouponModel!.available![index].code!));

                                Future.delayed(const Duration(milliseconds: 750), () {
                                  _availableToolTipControllerList![index].hideTooltip();
                                });
                              },
                              child: CouponCardWidget(couponList: couponController.customerCouponModel!.available, toolTipController: _availableToolTipControllerList, index: index),
                            ),
                          );
                        },
                      ),
                    ],
                  ))),
                ),
              ],
            ),
          ),
        ) : isDesktop ? SingleChildScrollView(
          child: Column(
            children: [
              WebScreenTitleWidget(title: 'coupon'.tr),

              FooterViewWidget(
                child: NoDataScreen(title: 'no_coupon_available'.tr, isEmptyCoupon: true),
              ),

            ],
          ),
        ) : NoDataScreen(title: 'no_coupon_available'.tr, isEmptyCoupon: true) : Center(
          child: SizedBox(
            height: 28,
            width: 28,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colors.accent,
            ),
          ),
        );
      }) : NotLoggedInScreen(callBack: (bool value)  {
        _initCall();
        setState(() {});
      }),
    );
  }
}
