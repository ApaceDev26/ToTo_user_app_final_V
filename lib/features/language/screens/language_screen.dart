import 'package:flutter/material.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/custom_asset_image_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/language/controllers/localization_controller.dart';
import 'package:toto_user/features/language/screens/web_language_screen.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/features/language/widgets/language_card_widget.dart';
import 'package:get/get.dart';

class LanguageScreen extends StatefulWidget {
  final bool fromMenu;
  const LanguageScreen({super.key, required this.fromMenu});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: (widget.fromMenu || ResponsiveHelper.isDesktop(context)) ? CustomAppBarWidget(title: 'language'.tr, isBackButtonExist: true) : null,
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      backgroundColor: colors.canvas,
      body: GetBuilder<LocalizationController>(builder: (localizationController) {
        return ResponsiveHelper.isDesktop(context) ? const WebLanguageScreen() : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SizedBox(height: AppSpacing.x4l),

          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: AppRadius.xlAll,
              ),
              child: const CustomAssetImageWidget(
                Images.languageBg,
                height: 210, width: 210,
                fit: BoxFit.contain,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text('choose_your_language'.tr, style: AppTypography.titleMd(colors.ink)),
          ),
          const SizedBox(height: AppSpacing.xs),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text('choose_your_language_to_proceed'.tr, style: AppTypography.bodySm(colors.inkMuted)),
          ),
          const SizedBox(height: AppSpacing.x2l),

          Expanded(
            child: SingleChildScrollView(
              child: GridView.builder(
                itemCount: localizationController.languages.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: AppSpacing.sm,
                  mainAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 2,
                ),
                itemBuilder: (context, index) {
                  return LanguageCardWidget(
                    languageModel: localizationController.languages[index],
                    localizationController: localizationController,
                    index: index,
                  );
                },
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.x2l),
            decoration: BoxDecoration(
              color: colors.surface,
              boxShadow: AppShadows.of(context, 2),
            ),
            child: CustomButtonWidget(
              buttonText: 'next'.tr,
              onPressed: () {
                if(localizationController.languages.isNotEmpty && localizationController.selectedLanguageIndex != -1) {
                  localizationController.setLanguage(Locale(
                    AppConstants.languages[localizationController.selectedLanguageIndex].languageCode!,
                    AppConstants.languages[localizationController.selectedLanguageIndex].countryCode,
                  ));
                  if (widget.fromMenu) {
                    Navigator.pop(context);
                  } else {
                    Get.offNamed(RouteHelper.getOnBoardingRoute());
                  }
                }else {
                  showCustomSnackBar('select_a_language'.tr);
                }
              },
            ),
          ),

        ]);
      }),

    );
  }
}
