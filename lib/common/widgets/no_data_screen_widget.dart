import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/components/app_states.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Empty state — Lumen Atelier. Flags preserved for call-site compat.
class NoDataScreen extends StatelessWidget {
  final String? title;
  final bool fromAddress;
  final bool isEmptyAddress;
  final bool isEmptyCart;
  final bool isEmptyChat;
  final bool isEmptyOrder;
  final bool isEmptyCoupon;
  final bool isEmptyFood;
  final bool isEmptyNotification;
  final bool isEmptyRestaurant;
  final bool isEmptySearchFood;
  final bool isEmptyTransaction;
  final bool isEmptyWishlist;

  const NoDataScreen({
    super.key,
    required this.title,
    this.fromAddress = false,
    this.isEmptyAddress = false,
    this.isEmptyCart = false,
    this.isEmptyChat = false,
    this.isEmptyOrder = false,
    this.isEmptyCoupon = false,
    this.isEmptyFood = false,
    this.isEmptyNotification = false,
    this.isEmptyRestaurant = false,
    this.isEmptySearchFood = false,
    this.isEmptyTransaction = false,
    this.isEmptyWishlist = false,
  });

  AppEmptyType get _type {
    if (isEmptyCart) return AppEmptyType.cart;
    if (isEmptyOrder) return AppEmptyType.orders;
    if (isEmptySearchFood) return AppEmptyType.search;
    if (isEmptyWishlist) return AppEmptyType.favourites;
    if (isEmptyAddress || fromAddress) return AppEmptyType.address;
    if (isEmptyNotification) return AppEmptyType.notification;
    if (isEmptyChat) return AppEmptyType.chat;
    if (isEmptyCoupon) return AppEmptyType.coupon;
    return AppEmptyType.generic;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: fromAddress ? MediaQuery.sizeOf(context).height * 0.12 : 0,
      ),
      child: AppEmptyState(
        type: _type,
        title: title ?? 'no_data_found'.tr,
        subtitle: fromAddress
            ? 'please_add_your_address_for_your_better_experience'.tr
            : null,
        actionLabel: fromAddress ? 'add_address'.tr : null,
        onAction: fromAddress
            ? () => Get.toNamed(RouteHelper.getAddAddressRoute(false, 0))
            : null,
      ),
    );
  }
}

/// Thin loader using accent.
class AppLoaderCenter extends StatelessWidget {
  const AppLoaderCenter({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 28,
        height: 28,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: AppColors.of(context).accent,
        ),
      ),
    );
  }
}
