import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toto_user/common/widgets/custom_asset_image_widget.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_durations.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/design_system/components/app_button.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/onboard/controllers/onboard_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/address_helper.dart';
import 'package:toto_user/helper/route_helper.dart';

/// Lumen Atelier onboarding — editorial, airy. Logic unchanged.
class OnBoardingScreen extends StatelessWidget {
  OnBoardingScreen({super.key});
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    Get.find<OnBoardingController>().getOnBoardingList();
    final colors = AppColors.of(context);

    return GetBuilder<OnBoardingController>(builder: (onBoardingController) {
      final list = onBoardingController.onBoardingList;
      final index = onBoardingController.selectedIndex;
      final isLast = list != null && index >= (list.length - 1);

      return Scaffold(
        backgroundColor: colors.canvas,
        body: list == null
            ? Center(
                child: CircularProgressIndicator(color: colors.accent),
              )
            : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Align(
                        alignment: Alignment.centerRight,
                        child: isLast
                            ? const SizedBox(height: 48)
                            : TextButton(
                                onPressed: _configureToRouteInitialPage,
                                child: Text(
                                  'skip'.tr,
                                  style: AppTypography.labelMd(colors.inkMuted),
                                ),
                              ),
                      ),
                      Expanded(
                        child: PageView.builder(
                          controller: _pageController,
                          itemCount: list.length,
                          onPageChanged: onBoardingController.changeSelectIndex,
                          itemBuilder: (context, i) {
                            final item = list[i];
                            return Column(
                              children: [
                                Expanded(
                                  flex: 5,
                                  child: Center(
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 360,
                                      ),
                                      child: ClipRRect(
                                        borderRadius: AppRadius.xlAll,
                                        child: ColoredBox(
                                          color: colors.accentSoft,
                                          child: CustomAssetImageWidget(
                                            item.imageUrl,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.x3l),
                                Text(
                                  item.title,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.displayMd(colors.ink),
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Text(
                                  item.description,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyLg(colors.inkMuted),
                                ),
                                const SizedBox(height: AppSpacing.x2l),
                              ],
                            );
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(list.length, (i) {
                          final selected = i == index;
                          return AnimatedContainer(
                            duration: AppDurations.fast,
                            margin: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.xs,
                            ),
                            width: selected ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: selected
                                  ? colors.accent
                                  : colors.lineStrong,
                              borderRadius: AppRadius.pillAll,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: AppSpacing.x2l),
                      AppButton(
                        label: isLast ? 'continue'.tr : 'next'.tr,
                        onPressed: () {
                          if (!isLast) {
                            _pageController.nextPage(
                              duration: AppDurations.normal,
                              curve: AppDurations.defaultCurve,
                            );
                          } else {
                            _configureToRouteInitialPage();
                          }
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
      );
    });
  }

  void _configureToRouteInitialPage() async {
    Get.find<SplashController>().disableIntro();

    await Get.toNamed(RouteHelper.getSignInRoute('onboard-flow'));

    if (!Get.find<AuthController>().isLoggedIn()) {
      await Get.find<AuthController>().guestLogin();
    }

    if (AddressHelper.getAddressFromSharedPref() != null) {
      Get.offNamed(RouteHelper.getInitialRoute(fromSplash: true));
    } else {
      Get.find<SplashController>()
          .navigateToLocationScreen('splash', offNamed: true);
    }
  }
}
