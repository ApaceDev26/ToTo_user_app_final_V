import 'package:toto_user/common/widgets/web_menu_bar.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_icons.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/cart_widget.dart';
import 'package:toto_user/common/widgets/veg_filter_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CustomAppBarWidget extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final bool isBackButtonExist;
  final Function? onBackPressed;
  final bool showCart;
  final Color? bgColor;
  final Function(String value)? onVegFilterTap;
  final String? type;
  final List<Widget>? actions;
  const CustomAppBarWidget(
      {super.key,
      required this.title,
      this.isBackButtonExist = true,
      this.onBackPressed,
      this.showCart = false,
      this.bgColor,
      this.onVegFilterTap,
      this.type,
      this.actions});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final Color background = bgColor ?? colors.canvas;
    final bool onAccent = bgColor != null && bgColor != colors.canvas;
    final Color ink = onAccent ? colors.onAccent : colors.ink;

    return ResponsiveHelper.isDesktop(context)
        ? const WebMenuBar()
        : AppBar(
            title: Text(title, style: AppTypography.titleMd(ink)),
            centerTitle: true,
            leading: isBackButtonExist
                ? IconButton(
                    icon: Icon(Icons.arrow_back_ios_new_rounded,
                        size: AppIcons.sm, color: ink),
                    onPressed: () => onBackPressed != null
                        ? onBackPressed!()
                        : Navigator.pop(context),
                  )
                : const SizedBox(),
            backgroundColor: background,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            actions: showCart || onVegFilterTap != null
                ? [
                    showCart
                        ? IconButton(
                            onPressed: () =>
                                Get.toNamed(RouteHelper.getCartRoute()),
                            icon: CartWidget(
                                color: onAccent ? colors.onAccent : colors.accent,
                                size: 25),
                          )
                        : const SizedBox(),
                    onVegFilterTap != null
                        ? VegFilterWidget(
                            type: type,
                            onSelected: onVegFilterTap,
                            fromAppBar: true,
                            iconColor:
                                onAccent ? colors.onAccent : colors.accent,
                          )
                        : const SizedBox(),
                    const SizedBox(width: AppSpacing.sm),
                  ]
                : actions ?? [const SizedBox()],
          );
  }

  @override
  Size get preferredSize =>
      Size(Dimensions.webMaxWidth, GetPlatform.isDesktop ? 100 : 56);
}
