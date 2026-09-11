import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/support/widgets/custom_card_widget.dart';
import 'package:toto_user/features/support/widgets/element_widget.dart';
import 'package:toto_user/features/support/widgets/web_support_widget.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: ResponsiveHelper.isDesktop(context) ? null : AppBar(
        title: Text('help_support'.tr, style: AppTypography.titleSm(colors.onAccent)),
        centerTitle: true,
        backgroundColor: colors.accent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: colors.onAccent,
          onPressed: () => Navigator.pop(context),
        ),
        actions: [SizedBox()],
      ),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: Center(
        child: ResponsiveHelper.isDesktop(context) ? SingleChildScrollView(
            controller: scrollController,
            child: const FooterViewWidget(child: SizedBox( width: double.infinity, height: 650, child: WebSupportScreen())),
        ) : SizedBox(
          width: Dimensions.webMaxWidth,
          child: Stack(
            children: [
              Column(children: [
                Expanded(flex: 4, child: Container(color: colors.accent)),
                Expanded(flex: 7, child: Container(color: colors.surface)),
              ]),

              SingleChildScrollView(
                controller: scrollController,
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    child: Column(children: [

                      const SizedBox(height: AppSpacing.x5l),

                      Text('how_we_can_help_you'.tr, style: AppTypography.labelLg(colors.onAccent)),
                      const SizedBox(height: AppSpacing.sm),

                      Text('hey_let_us_know_your_problem'.tr, style: AppTypography.bodySm(colors.onAccent)),
                      const SizedBox(height: AppSpacing.x5l),

                      Stack(clipBehavior: Clip.none, children: [
                        Container(
                          height: size.height * 0.35,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: AppRadius.mdAll,
                            boxShadow: AppShadows.of(context, 2),
                          ),
                        ),

                        Positioned(
                          top: -20, left: 20, right: 20,
                          child: Column(children: [
                            CustomCardWidget(
                              child: ElementWidget(
                                image: Images.helpAddress,
                                title: 'address'.tr,
                                subTitle: Get.find<SplashController>().configModel!.address!,
                                onTap: (){},
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),

                            Row(children: [
                              Expanded(child: CustomCardWidget(
                                child: ElementWidget(
                                  image: Images.helpPhone, title: 'call'.tr,
                                  subTitle: Get.find<SplashController>().configModel!.phone!,
                                  onTap: ()async {
                                    if(await canLaunchUrlString('tel:${Get.find<SplashController>().configModel!.phone}')) {
                                      launchUrlString('tel:${Get.find<SplashController>().configModel!.phone}', mode: LaunchMode.externalApplication);
                                    }else {
                                      showCustomSnackBar('${'can_not_launch'.tr} ${Get.find<SplashController>().configModel!.phone}');
                                    }
                                  }
                                ),
                              )),
                              const SizedBox(width: AppSpacing.xl),

                              Expanded(child: CustomCardWidget(
                                child: ElementWidget(
                                  image: Images.helpEmail, title: 'email_us'.tr,
                                  subTitle: Get.find<SplashController>().configModel!.email!,
                                  onTap: () {
                                    final Uri emailLaunchUri = Uri(
                                      scheme: 'mailto',
                                      path: Get.find<SplashController>().configModel!.email,
                                    );
                                    launchUrlString(emailLaunchUri.toString(), mode: LaunchMode.externalApplication);
                                  },
                                ),
                              )),
                            ]),
                          ]),
                        ),

                      ])
                    ]),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
