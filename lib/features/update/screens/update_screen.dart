import 'package:toto_user/common/widgets/dotted_divider.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher_string.dart';

class UpdateScreen extends StatelessWidget {
  final bool isUpdate;
  const UpdateScreen({super.key, required this.isUpdate});

  @override
  Widget build(BuildContext context) {

    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: GetBuilder<SplashController>(builder: (splashController) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

              Container(
                padding: const EdgeInsets.all(AppSpacing.xl),
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  borderRadius: AppRadius.xlAll,
                ),
                child: Image.asset(
                  isUpdate ? Images.update : Images.maintenance,
                  width: 280, height: 180,
                ),
              ),
              const SizedBox(height: AppSpacing.x5l),

              Text(
                isUpdate ? 'update'.tr : splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.maintenanceMessage ?? 'we_are_cooking_up_something_special'.tr,
                style: isUpdate
                    ? AppTypography.titleLg(colors.ink)
                    : AppTypography.titleMd(colors.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.lg),

              SizedBox(
                width: isDesktop ? 500 : context.width,
                child: Text(
                  isUpdate ? 'your_app_is_deprecated'.tr : splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.messageBody ?? 'maintenance_mode'.tr,
                  style: AppTypography.bodyMd(colors.inkMuted),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: isUpdate ? AppSpacing.x4l : isDesktop ? AppSpacing.x3l : AppSpacing.xl),

              isUpdate ? const SizedBox() : Column(children: [

                splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessEmail == 1
                || splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? Column(
                  children: [

                    SizedBox(
                      width: isDesktop ? 500 : context.width,
                      child: DottedDivider(dashWidth: 10, color: colors.line),
                    ),
                    SizedBox(height: isDesktop ? AppSpacing.x3l : AppSpacing.xl),

                    Text(
                      'any_query_feel_free_to_contact_us'.tr,
                      style: AppTypography.labelMd(colors.ink),
                    ),
                    const SizedBox(height: AppSpacing.xl),

                    splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? InkWell(
                      onTap: () async {
                        if(await canLaunchUrlString('tel:${splashController.configModel?.phone}')) {
                          launchUrlString('tel:${splashController.configModel?.phone}', mode: LaunchMode.externalApplication);
                        }else {
                          showCustomSnackBar('${'can_not_launch'.tr} ${splashController.configModel?.phone}');
                        }
                      },
                      child: Text(
                        splashController.configModel?.phone ?? '',
                        style: AppTypography.labelMd(colors.accent).copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: colors.accent,
                        ),
                      ),
                    ) : const SizedBox(),
                    SizedBox(height: splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessNumber == 1 ? AppSpacing.xs : 0),

                    splashController.configModel!.maintenanceModeData?.maintenanceMessageSetup?.businessEmail == 1 ? InkWell(
                      onTap: () async {
                        if(await canLaunchUrlString('mailto:${splashController.configModel?.email}')) {
                          launchUrlString('mailto:${splashController.configModel?.email}', mode: LaunchMode.externalApplication);
                        }else {
                          showCustomSnackBar('${'can_not_launch'.tr} ${splashController.configModel?.email}');
                        }
                      },
                      child: Text(
                        splashController.configModel?.email ?? '',
                        style: AppTypography.labelMd(colors.accent).copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: colors.accent,
                        ),
                      ),
                    ) : const SizedBox(),
                  ],
                ) : const SizedBox(),

              ]),

              isUpdate ? CustomButtonWidget(buttonText: 'update_now'.tr, onPressed: () async {
                String? appUrl = 'https://google.com';
                if(GetPlatform.isAndroid) {
                  appUrl = splashController.configModel!.appUrlAndroid;
                }else if(GetPlatform.isIOS) {
                  appUrl = splashController.configModel!.appUrlIos;
                }
                if(await canLaunchUrlString(appUrl!)) {
                  launchUrlString(appUrl, mode: LaunchMode.externalApplication);
                }else {
                  showCustomSnackBar('${'can_not_launch'.tr} $appUrl');
                }
              }) : const SizedBox(),

            ]),
          ),
        );
      }),
    );
  }
}
