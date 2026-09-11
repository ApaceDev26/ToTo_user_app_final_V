import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/refer%20and%20earn/controllers/refer_and_earn_controller.dart';
import 'package:toto_user/features/refer%20and%20earn/widgets/bottom_sheet_view_widget.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/not_logged_in_screen.dart';
import 'package:toto_user/common/widgets/web_page_title_widget.dart';
import 'package:expandable_bottom_sheet/expandable_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:share_plus/share_plus.dart';

class ReferAndEarnScreen extends StatefulWidget {
  const ReferAndEarnScreen({super.key});

  @override
  State<ReferAndEarnScreen> createState() => _ReferAndEarnScreenState();
}

class _ReferAndEarnScreenState extends State<ReferAndEarnScreen> {
  final ScrollController scrollController = ScrollController();
  final JustTheController tooltipController = JustTheController();
  GlobalKey<ExpandableBottomSheetState> key = GlobalKey();

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall(){
    Get.find<ReferAndEarnController>().getUserInfo();
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBarWidget(title: 'refer_and_earn'.tr),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: ExpandableBottomSheet(
        background: isLoggedIn ? SingleChildScrollView(
          controller: scrollController,
          padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : AppSpacing.xl),
          child: Column(children: [
            
            WebScreenTitleWidget(title: 'refer_and_earn'.tr),

            FooterViewWidget(
              child: Center(
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: GetBuilder<ReferAndEarnController>(builder: (referAndEarnController) {
                    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [

                      SizedBox(height: isDesktop ? AppSpacing.x4l : AppSpacing.x3l),

                      Image.asset(
                        Images.referImage, width: 500,
                        height: isDesktop ? 250 : 200, fit: BoxFit.contain,
                      ),
                      const SizedBox(height: AppSpacing.x4l),

                      Text(isDesktop ? 'invite_friends_and_earn_money_on_Every_Referral'.tr : 'invite_friends_and_business'.tr ,
                          style: AppTypography.titleMd(colors.ink), textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.xs),

                      isDesktop ? Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text(
                          '${'one_referral'.tr}= ', style: AppTypography.labelMd(colors.accent),
                        ),
                        Text(
                          PriceConverter.convertPrice(Get.find<SplashController>().configModel != null
                              ? Get.find<SplashController>().configModel!.refEarningExchangeRate!.toDouble() : 0.0),
                          style: AppTypography.labelMd(colors.accent), textDirection: TextDirection.ltr,
                        ),
                      ]) : const SizedBox(),
                      isDesktop ?  const SizedBox(height: AppSpacing.x4l) : const SizedBox(),

                      isDesktop ? const SizedBox() : Text('copy_your_code_share_it_with_your_friends'.tr , style: AppTypography.bodySm(colors.inkMuted), textAlign: TextAlign.center),
                      isDesktop ? const SizedBox() : const SizedBox(height: AppSpacing.x4l + AppSpacing.xs),

                      isDesktop ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 250),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text('your_personal_code'.tr , style: AppTypography.bodySm(colors.inkMuted), textAlign: TextAlign.start),
                        ),
                      ) : const SizedBox(),

                      isDesktop ? const SizedBox() : Text('your_personal_code'.tr , style: AppTypography.bodySm(colors.inkFaint), textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.lg),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: isDesktop ? 250 : AppSpacing.lg),
                        child: DottedBorder(
                          color: isDesktop ? colors.accent.withValues(alpha: 0.7) : colors.accent.withValues(alpha: 0.3),
                          strokeWidth: 1,
                          strokeCap: StrokeCap.butt,
                          dashPattern: const [5, 5],
                          padding: const EdgeInsets.all(0),
                          borderType: BorderType.RRect,
                          radius: Radius.circular(isDesktop ? AppRadius.md : AppRadius.pill),
                          child: SizedBox(
                            height: 50,
                            child: (referAndEarnController.userInfoModel != null) ? Row(children: [
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: AppSpacing.xl, right: AppSpacing.xl),
                                  child: Text(
                                    referAndEarnController.userInfoModel != null ? referAndEarnController.userInfoModel!.refCode ?? '' : '',
                                    style: AppTypography.bodyMd(colors.ink),
                                  ),
                                ),
                              ),

                              JustTheTooltip(
                                backgroundColor: colors.ink,
                                controller: tooltipController,
                                preferredDirection: AxisDirection.up,
                                tailLength: 14,
                                tailBaseWidth: 20,
                                triggerMode: TooltipTriggerMode.manual,
                                content: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                  child: Text('copied'.tr, style: AppTypography.bodyMd(colors.onAccent)),
                                ),
                                child: InkWell(
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    if(referAndEarnController.userInfoModel!.refCode!.isNotEmpty){
                                      tooltipController.showTooltip();
                                      Clipboard.setData(ClipboardData(text: '${referAndEarnController.userInfoModel != null ? referAndEarnController.userInfoModel!.refCode : ''}'));
                                    }

                                    Future.delayed(const Duration(seconds: 2), () {
                                      tooltipController.hideTooltip();
                                    });
                                  },
                                  child: Container(
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(color: colors.accent, borderRadius: BorderRadius.circular(isDesktop ? AppRadius.md : AppRadius.pill)),
                                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
                                    margin: const EdgeInsets.all(AppSpacing.xs),
                                    child: Text('copy'.tr, style: AppTypography.labelMd(colors.onAccent)),
                                  ),
                                ),
                              ),

                            ]) : const CircularProgressIndicator(),
                          ),
                        ),
                      ),
                      SizedBox(height: isDesktop ? AppSpacing.x3l : AppSpacing.xl),

                      Text('or_share'.tr , style: AppTypography.bodySm(colors.inkMuted), textAlign: TextAlign.center),
                      const SizedBox(height: AppSpacing.xl),

                      Wrap(children: [
                        InkWell(
                          onTap: () => Share.share(
                            Get.find<SplashController>().configModel?.appUrlAndroid != null ? '${AppConstants.appName} ${'referral_code'.tr}: ${referAndEarnController.userInfoModel!.refCode} \n${'download_app_from_this_link'.tr}: ${Get.find<SplashController>().configModel?.appUrlAndroid}'
                             : '${AppConstants.appName} ${'referral_code'.tr}: ${referAndEarnController.userInfoModel!.refCode}'
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: colors.surface,
                              boxShadow: AppShadows.of(context, 1),
                            ),
                            padding: const EdgeInsets.all(AppSpacing.sm),
                            child: Icon(Icons.share, color: colors.ink),
                          ),
                        )
                      ]),

                      isDesktop ? const Padding(
                        padding: EdgeInsets.only(
                          top: AppSpacing.x3l, bottom: AppSpacing.x2l,
                          left: 100, right: 100,
                        ),
                        child: BottomSheetViewWidget(),
                      ) : const SizedBox(),

                    ]);
                  }),
                ),
              ),
            ),
          ]),
        ) : NotLoggedInScreen(callBack: (value){
          _initCall();
          setState(() {});
        }),

        key: key,
        persistentHeader: !isLoggedIn || ResponsiveHelper.isDesktop(context) ? null :  InkWell(
          onTap: (){
            if(key.currentState?.expansionStatus == ExpansionStatus.expanded){
              setState(() {
                key.currentState!.contract();
              });

            } else {
              setState(() {
                key.currentState!.expand();
              });
            }
          },
          child: Container(
            constraints: const BoxConstraints.expand(height: 60),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(AppRadius.xl), topRight: Radius.circular(AppRadius.xl)),
              color: colors.surface,
              border: Border(
                top: BorderSide(color: colors.accent, width: 0.3),
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius : const BorderRadius.only(
                  topLeft: Radius.circular(AppRadius.xl),
                  topRight : Radius.circular(AppRadius.xl),
                ),
              ),
              child: Column(children: [
                Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: AppSpacing.lg),
                    height: 3, width: 40,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: AppRadius.xsAll,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.lg, top: AppSpacing.sm, right: AppSpacing.lg),
                  child: Row(children: [
                    Icon(Icons.error_outline, size: 16, color: colors.ink),
                    const SizedBox(width: AppSpacing.xs),
                    Text('how_it_works'.tr , style: AppTypography.labelLg(colors.ink), textAlign: TextAlign.center),
                  ]),
                ),
              ]),
            ),
          ),
        ),
        expandableContent: isDesktop || !isLoggedIn ? const SizedBox() : const BottomSheetViewWidget(),
      ),
    );
  }
}
