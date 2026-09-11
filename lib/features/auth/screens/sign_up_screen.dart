import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_icons.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/auth/widgets/sign_up_widget.dart';
import 'package:toto_user/helper/responsive_helper.dart';

class SignUpScreen extends StatefulWidget {
  final bool exitFromApp;
  const SignUpScreen({super.key, this.exitFromApp = false});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: ResponsiveHelper.isDesktop(context)
          ? Colors.transparent
          : colors.canvas,
      appBar: ResponsiveHelper.isDesktop(context) ? null : null,
      body: CustomScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
        slivers: [
          if (!ResponsiveHelper.isDesktop(context))
            SliverAppBar(
              pinned: true,
              floating: false,
              snap: false,
              leading: IconButton(
                onPressed: () => Get.back(result: false),
                icon: Icon(Icons.arrow_back_ios_new_rounded,
                    size: AppIcons.sm, color: colors.ink),
              ),
              expandedHeight: 148,
              elevation: 0,
              scrolledUnderElevation: 0,
              backgroundColor: colors.canvas,
              surfaceTintColor: Colors.transparent,
              automaticallyImplyLeading: false,
              primary: true,
              collapsedHeight: 100,
              toolbarHeight: 48,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(AppSpacing.lg),
                child: SizedBox(height: AppSpacing.lg),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: colors.canvas,
                  padding: EdgeInsets.fromLTRB(
                    AppSpacing.page(context),
                    AppSpacing.x5l,
                    AppSpacing.page(context),
                    AppSpacing.lg,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign Up'.tr,
                        style: AppTypography.displayMd(colors.ink),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SafeArea(
                child: Center(
              child: Container(
                width: context.width > 700 ? 700 : context.width,
                padding: context.width > 700
                    ? const EdgeInsets.all(AppSpacing.x4l)
                    : EdgeInsets.symmetric(horizontal: AppSpacing.page(context)),
                decoration: context.width > 700
                    ? BoxDecoration(
                        color: colors.surface,
                        borderRadius: AppRadius.mdAll,
                      )
                    : null,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ResponsiveHelper.isDesktop(context)
                          ? Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () => Get.back(),
                                icon: Icon(Icons.close_rounded,
                                    color: colors.inkMuted),
                              ),
                            )
                          : const SizedBox(),
                      const SignUpWidget(),
                    ]),
              ),
            )),
          ),
        ],
      ),
    );
  }
}
