import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/features/language/controllers/localization_controller.dart';
import 'package:toto_user/features/language/widgets/language_bottom_sheet_widget.dart';
import 'package:toto_user/features/menu/widgets/portion_widget.dart';
import 'package:toto_user/features/profile/controllers/profile_controller.dart';
import 'package:toto_user/features/profile/widgets/profile_button_widget.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/splash/controllers/theme_controller.dart';
import 'package:toto_user/features/auth/screens/sign_in_screen.dart';
import 'package:toto_user/features/favourite/controllers/favourite_controller.dart';
import 'package:toto_user/helper/auth_helper.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/confirmation_dialog_widget.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_icons.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/design_system/components/app_states.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      body: GetBuilder<ProfileController>(builder: (profileController) {
        final bool isLoggedIn = Get.find<AuthController>().isLoggedIn();

        return Column(children: [
          _ProfileHero(
            isLoggedIn: isLoggedIn,
            profileController: profileController,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: AppSpacing.lg),
              child: Column(children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  child: Row(
                    children: [
                      Expanded(
                        child: _QuietShortcut(
                          icon: Icons.favorite_border_outlined,
                          label: 'favourite'.tr,
                          onTap: () =>
                              Get.toNamed(RouteHelper.getFavouriteScreen()),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuietShortcut(
                          icon: Icons.account_balance_wallet_outlined,
                          label: 'wallet'.tr,
                          onTap: () =>
                              Get.toNamed(RouteHelper.getWalletRoute()),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _QuietShortcut(
                          icon: Icons.card_giftcard_outlined,
                          label: 'rewards'.tr,
                          onTap: () =>
                              Get.toNamed(RouteHelper.getLoyaltyRoute()),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.x2l),
                _SettingsGroup(
                  title: 'general'.tr,
                  children: [
                    PortionWidget(
                        icon: Images.couponIcon,
                        title: 'coupon'.tr,
                        route: RouteHelper.getCouponRoute(fromCheckout: false)),
                    PortionWidget(
                        icon: Images.addressIcon,
                        title: 'my_address'.tr,
                        route: RouteHelper.getAddressRoute()),
                    PortionWidget(
                        icon: Images.languageIcon,
                        title: 'language'.tr,
                        onTap: () => _manageLanguageFunctionality(),
                        route: ''),
                    ProfileButtonWidget(
                      icon: Icons.tonality_outlined,
                      title: 'dark_mode'.tr,
                      isButtonActive: Get.isDarkMode,
                      isThemeSwitchButton: true,
                      onTap: () {
                        Get.find<ThemeController>().toggleTheme();
                      },
                    ),
                  ],
                ),
                (Get.find<SplashController>().configModel!.refEarningStatus ==
                            1) ||
                        (Get.find<SplashController>()
                                .configModel!
                                .toggleDmRegistration! &&
                            !ResponsiveHelper.isDesktop(context)) ||
                        (Get.find<SplashController>()
                                .configModel!
                                .toggleRestaurantRegistration! &&
                            !ResponsiveHelper.isDesktop(context))
                    ? _SettingsGroup(
                        title: 'earnings'.tr,
                        children: [
                          (Get.find<SplashController>()
                                      .configModel!
                                      .refEarningStatus ==
                                  1)
                              ? PortionWidget(
                                  icon: Images.referIcon,
                                  title: 'refer_and_earn'.tr,
                                  route: RouteHelper.getReferAndEarnRoute(),
                                  hideDivider: true,
                                )
                              : const SizedBox(),
                        ],
                      )
                    : const SizedBox(),
                _SettingsGroup(
                  title: 'help_and_support'.tr,
                  children: [
                    PortionWidget(
                        icon: Images.chatIcon,
                        title: 'live_chat'.tr,
                        route: RouteHelper.getConversationRoute()),
                    PortionWidget(
                        icon: Images.helpIcon,
                        title: 'help_and_support'.tr,
                        route: RouteHelper.getSupportRoute()),
                    PortionWidget(
                        icon: Images.aboutIcon,
                        title: 'about_us'.tr,
                        route: RouteHelper.getHtmlRoute('about-us')),
                    PortionWidget(
                        icon: Images.termsIcon,
                        title: 'terms_conditions'.tr,
                        route: RouteHelper.getHtmlRoute('terms-and-condition')),
                    PortionWidget(
                        icon: Images.privacyIcon,
                        title: 'privacy_policy'.tr,
                        route: RouteHelper.getHtmlRoute('privacy-policy')),
                    (Get.find<SplashController>()
                                .configModel!
                                .refundPolicyStatus ==
                            1)
                        ? PortionWidget(
                            icon: Images.refundIcon,
                            title: 'refund_policy'.tr,
                            route: RouteHelper.getHtmlRoute('refund-policy'),
                          )
                        : const SizedBox(),
                    (Get.find<SplashController>()
                                .configModel!
                                .cancellationPolicyStatus ==
                            1)
                        ? PortionWidget(
                            icon: Images.cancelationIcon,
                            title: 'cancellation_policy'.tr,
                            route:
                                RouteHelper.getHtmlRoute('cancellation-policy'),
                          )
                        : const SizedBox(),
                    (Get.find<SplashController>()
                                .configModel!
                                .shippingPolicyStatus ==
                            1)
                        ? PortionWidget(
                            icon: Images.shippingIcon,
                            title: 'shipping_policy'.tr,
                            hideDivider: true,
                            route: RouteHelper.getHtmlRoute('shipping-policy'),
                          )
                        : const SizedBox(),
                  ],
                ),
                // _SettingsGroup(
                //   title: 'developing_partner'.tr,
                //   children: [
                //     PortionWidget(
                //       icon: Images.aboutIcon,
                //       title: 'skylon_it'.tr,
                //       hideDivider: true,
                //       route: RouteHelper.getSkylonItRoute(),
                //     ),
                //   ],
                // ),
                InkWell(
                  onTap: () async {
                    if (Get.find<AuthController>().isLoggedIn()) {
                      Get.dialog(
                          ConfirmationDialogWidget(
                              icon: Images.support,
                              description: 'are_you_sure_to_logout'.tr,
                              isLogOut: true,
                              onYesPressed: () async {
                                Get.find<ProfileController>()
                                    .setForceFullyUserEmpty();
                                Get.find<AuthController>().socialLogout();
                                Get.find<AuthController>().resetOtpView();
                                Get.find<CartController>().clearCartList();
                                Get.find<FavouriteController>()
                                    .removeFavourites();
                                await Get.find<AuthController>()
                                    .clearSharedData();
                                Get.offAllNamed(RouteHelper.getInitialRoute());
                              }),
                          useSafeArea: false);
                    } else {
                      Get.find<FavouriteController>().removeFavourites();
                      await Get.toNamed(
                          RouteHelper.getSignInRoute(Get.currentRoute));
                      if (AuthHelper.isLoggedIn()) {
                        await Get.find<FavouriteController>()
                            .getFavouriteList();
                        profileController.getUserInfo();
                      }
                    }
                  },
                  borderRadius: AppRadius.smAll,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md, horizontal: AppSpacing.lg),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.power_settings_new_rounded,
                            size: AppIcons.sm,
                            color: Get.find<AuthController>().isLoggedIn()
                                ? colors.danger
                                : colors.accent,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            Get.find<AuthController>().isLoggedIn()
                                ? 'logout'.tr
                                : 'sign_in'.tr,
                            style: AppTypography.labelLg(
                              Get.find<AuthController>().isLoggedIn()
                                  ? colors.danger
                                  : colors.accent,
                            ),
                          ),
                        ]),
                  ),
                ),
                // const SizedBox(height: ),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('${'version'.tr}:',
                      style: AppTypography.bodySm(colors.inkFaint)),
                  const SizedBox(width: AppSpacing.xs),
                  Text(AppConstants.appVersion.toString(),
                      style: AppTypography.labelSm(colors.inkMuted)),
                ]),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ]);
      }),
    );
  }

  _manageLanguageFunctionality() {
    Get.find<LocalizationController>().saveCacheLanguage(null);
    Get.find<LocalizationController>().searchSelectedLanguage();

    showModalBottomSheet(
      isScrollControlled: true,
      useRootNavigator: true,
      context: Get.context!,
      backgroundColor: AppColors.of(Get.context!).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: AppRadius.sheetTop,
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8),
          child: const LanguageBottomSheetWidget(),
        );
      },
    ).then((value) => Get.find<LocalizationController>().setLanguage(
        Get.find<LocalizationController>().getCacheLocaleFromSharedPref()));
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({
    required this.isLoggedIn,
    required this.profileController,
  });

  final bool isLoggedIn;
  final ProfileController profileController;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final top = MediaQuery.paddingOf(context).top;

    return Container(
      width: double.infinity,
      color: colors.surface,
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        top + AppSpacing.xl,
        AppSpacing.xl,
        AppSpacing.x2l,
      ),
      child: InkWell(
        onTap: () => Get.toNamed(RouteHelper.getProfileRoute()),
        borderRadius: AppRadius.mdAll,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  isLoggedIn && profileController.userInfoModel == null
                      ? const AppSkeleton(width: 180, height: 28)
                      : Text(
                          isLoggedIn
                              ? '${profileController.userInfoModel?.fName} ${profileController.userInfoModel?.lName}'
                              : 'guest_user'.tr,
                          style: AppTypography.displayMd(colors.ink),
                        ),
                  const SizedBox(height: AppSpacing.xs),
                  isLoggedIn && profileController.userInfoModel != null
                      ? profileController.userInfoModel!.phone != null
                          ? Text(
                              profileController.userInfoModel!.phone!,
                              style: AppTypography.bodyMd(colors.inkMuted),
                            )
                          : Text(
                              profileController.userInfoModel!.email!,
                              style: AppTypography.bodyMd(colors.inkMuted),
                            )
                      : InkWell(
                          onTap: () async {
                            if (!ResponsiveHelper.isDesktop(context)) {
                              Get.toNamed(RouteHelper.getSignInRoute(
                                      Get.currentRoute))
                                  ?.then((value) {
                                if (AuthHelper.isLoggedIn()) {
                                  profileController.getUserInfo();
                                }
                              });
                            } else {
                              Get.dialog(const SignInScreen(
                                      exitFromApp: true, backFromThis: true))
                                  .then((value) {
                                if (AuthHelper.isLoggedIn()) {
                                  profileController.getUserInfo();
                                }
                              });
                            }
                          },
                          child: Text(
                            'login_to_view_all_feature'.tr,
                            style: AppTypography.labelMd(colors.accent),
                          ),
                        ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: colors.line, width: 1),
              ),
              padding: const EdgeInsets.all(2),
              child: ClipOval(
                child: CustomImageWidget(
                  placeholder:
                      isLoggedIn ? Images.profilePlaceholder : Images.guestIcon,
                  image:
                      '${(profileController.userInfoModel != null && isLoggedIn) ? profileController.userInfoModel!.imageFullUrl : ''}',
                  height: 64,
                  width: 64,
                  fit: BoxFit.cover,
                  imageColor: isLoggedIn ? colors.inkFaint : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuietShortcut extends StatelessWidget {
  const _QuietShortcut({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Material(
      color: colors.surface,
      borderRadius: AppRadius.smAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.smAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
              vertical: AppSpacing.md, horizontal: AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: AppRadius.smAll,
            border: Border.all(color: colors.line),
          ),
          child: Column(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: colors.accentSoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: AppIcons.sm, color: colors.accent),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                style: AppTypography.labelMd(colors.ink),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          child: Text(
            title,
            style: AppTypography.labelMd(colors.inkFaint),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(
              AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.x2l),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: colors.line),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }
}
