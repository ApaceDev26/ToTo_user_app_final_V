import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_icons.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/auth/widgets/sign_in/sign_in_view.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';

class SignInScreen extends StatefulWidget {
  final bool exitFromApp;
  final bool backFromThis;
  final bool fromResetPassword;
  const SignInScreen(
      {super.key,
      required this.exitFromApp,
      required this.backFromThis,
      this.fromResetPassword = false});

  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  bool _canExit = GetPlatform.isWeb ? true : false;
  final ScrollController _scrollController = ScrollController();
  double _initialScrollPosition = 0.0;
  bool _keyboardWasVisible = false;
  static const double _maxScrollWhenKeyboardVisible = 20.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _checkKeyboardAndUpdateInitialPosition() {
    if (!mounted || !_scrollController.hasClients) return;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    if (isKeyboardVisible && !_keyboardWasVisible) {
      // Keyboard just appeared, save initial scroll position
      _initialScrollPosition = _scrollController.offset;
      _keyboardWasVisible = true;
    } else if (!isKeyboardVisible && _keyboardWasVisible) {
      // Keyboard disappeared, reset tracking
      _keyboardWasVisible = false;
    }
  }

  void _handleScroll() {
    if (!mounted || !_scrollController.hasClients) return;

    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardVisible = keyboardHeight > 0;

    // Update initial position if keyboard state changed
    _checkKeyboardAndUpdateInitialPosition();

    if (isKeyboardVisible && _keyboardWasVisible) {
      // Calculate how much user has scrolled since keyboard appeared
      final scrollDelta = _scrollController.offset - _initialScrollPosition;

      // If scrolled more than 15px, dismiss keyboard and reset
      if (scrollDelta.abs() > _maxScrollWhenKeyboardVisible) {
        FocusScope.of(context).unfocus();
        _keyboardWasVisible = false;
        // Reset scroll to initial position
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _scrollController.hasClients) {
            _scrollController.jumpTo(_initialScrollPosition);
          }
        });
      } else {
        // Limit scroll to 15px max
        final maxAllowedOffset =
            _initialScrollPosition + _maxScrollWhenKeyboardVisible;
        final minAllowedOffset =
            _initialScrollPosition - _maxScrollWhenKeyboardVisible;

        if (_scrollController.offset > maxAllowedOffset) {
          _scrollController.jumpTo(maxAllowedOffset);
        } else if (_scrollController.offset < minAllowedOffset) {
          _scrollController.jumpTo(minAllowedOffset);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    // Check keyboard visibility on each build to track state changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkKeyboardAndUpdateInitialPosition();
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.exitFromApp) {
          if (_canExit) {
            if (GetPlatform.isAndroid) {
              SystemNavigator.pop();
            } else if (GetPlatform.isIOS) {
              exit(0);
            } else {
              Navigator.pushNamed(context, RouteHelper.getInitialRoute());
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('back_press_again_to_exit'.tr,
                  style: const TextStyle(color: Colors.white)),
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(Dimensions.paddingSizeSmall),
            ));
            _canExit = true;
            Timer(const Duration(seconds: 2), () {
              _canExit = false;
            });
          }
        } else {
          if (Get.find<AuthController>().isOtpViewEnable) {
            Get.find<AuthController>().enableOtpView(enable: false);
          } else {
            Get.back();
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: ResponsiveHelper.isDesktop(context)
            ? Colors.transparent
            : colors.canvas,
        appBar: ResponsiveHelper.isDesktop(context) ? null : null,
        body: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollUpdateNotification) {
              _handleScroll();
            }
            return false;
          },
          child: CustomScrollView(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
            slivers: [
              SliverAppBar(
                pinned: true,
                floating: false,
                snap: false,
                expandedHeight: 168,
                elevation: 0,
                scrolledUnderElevation: 0,
                leading: IconButton(
                  onPressed: () => (GetPlatform.isWeb)
                      ? Get.back(result: false)
                      : Get.back(),
                  icon: Icon(Icons.close_rounded,
                      size: AppIcons.md, color: colors.ink),
                ),
                backgroundColor: colors.canvas,
                surfaceTintColor: Colors.transparent,
                automaticallyImplyLeading: false,
                primary: true,
                collapsedHeight: 112,
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
                          'Get Started'.tr,
                          style: AppTypography.displayMd(colors.ink),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Please Enter Your Phone Number'.tr,
                          style: AppTypography.bodyLg(colors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom +
                        AppSpacing.x2l,
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Container(
                      width: context.width > 700 ? 500 : context.width,
                      padding: context.width > 700
                          ? const EdgeInsets.all(AppSpacing.x5l)
                          : EdgeInsets.symmetric(
                              horizontal: AppSpacing.page(context)),
                      margin: context.width > 700
                          ? const EdgeInsets.all(AppSpacing.x5l)
                          : EdgeInsets.zero,
                      decoration: context.width > 700
                          ? BoxDecoration(
                              color: colors.surface,
                              borderRadius: AppRadius.mdAll,
                              boxShadow: ResponsiveHelper.isDesktop(context)
                                  ? null
                                  : AppShadows.of(context, 2),
                            )
                          : null,
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
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
                            SignInView(
                              exitFromApp: widget.exitFromApp,
                              backFromThis: widget.backFromThis,
                              fromResetPassword: widget.fromResetPassword,
                              isOtpViewEnable: (v) {},
                            ),
                          ]),
                    ),
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
