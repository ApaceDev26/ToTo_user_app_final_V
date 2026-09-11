import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/home/widgets/filter_view_widget.dart';
import 'package:toto_user/features/home/widgets/restaurant_filter_button_widget.dart';
import 'package:toto_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllRestaurantFilterWidget extends StatelessWidget {
  const AllRestaurantFilterWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final titleStyle = AppTypography.displayMd(colors.ink).copyWith(
      fontSize: isDesktop ? 26 : 22,
      height: 1.2,
      letterSpacing: -0.4,
    );
    return GetBuilder<RestaurantController>(builder: (restaurantController) {
      return Center(
        child: isDesktop
            ? Container(
                height: 70,
                width: Dimensions.webMaxWidth,
                color: colors.canvas,
                child: Row(
                  children: [
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('all_restaurants'.tr, style: titleStyle),
                          Text(
                            '${restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.totalSize : 0} ${'restaurants_near_you'.tr}',
                            style: robotoRegular.copyWith(
                                color: Theme.of(context).hintColor,
                                fontSize: Dimensions.fontSizeSmall),
                          ),
                        ]),
                    const Expanded(child: SizedBox()),
                    filter(context, restaurantController),
                    const SizedBox(width: Dimensions.paddingSizeSmall),
                  ],
                ))
            : Container(
                transform: Matrix4.translationValues(0, -2, 0),
                color: colors.canvas,
                padding: const EdgeInsets.symmetric(
                  horizontal: Dimensions
                      .paddingSizeDefault, /*vertical: Dimensions.paddingSizeExtraSmall*/
                ),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('all_restaurants'.tr, style: titleStyle),
                          Flexible(
                            child: Text(
                              '${restaurantController.restaurantModel != null ? restaurantController.restaurantModel!.totalSize : 0} ${'restaurants_near_you'.tr}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).hintColor,
                                  fontSize: Dimensions.fontSizeSmall),
                            ),
                          ),
                        ]),
                  ),
                  Divider(),
                ]),
              ),
      );
    });
  }

  Widget filter(
      BuildContext context, RestaurantController restaurantController) {
    return SizedBox(
      height: ResponsiveHelper.isDesktop(context) ? 40 : 30,
      child: ListView(
        scrollDirection: Axis.horizontal,
        shrinkWrap: true,
        children: [
          ResponsiveHelper.isDesktop(context)
              ? const SizedBox()
              : const FilterViewWidget(),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          RestaurantsFilterButtonWidget(
            buttonText: 'top_rated'.tr,
            onTap: () => restaurantController.setTopRated(),
            isSelected: restaurantController.topRated == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          RestaurantsFilterButtonWidget(
            buttonText: 'discounted'.tr,
            onTap: () => restaurantController.setDiscount(),
            isSelected: restaurantController.discount == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          RestaurantsFilterButtonWidget(
            buttonText: 'veg'.tr,
            onTap: () => restaurantController.setVeg(),
            isSelected: restaurantController.veg == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          RestaurantsFilterButtonWidget(
            buttonText: 'non_veg'.tr,
            onTap: () => restaurantController.setNonVeg(),
            isSelected: restaurantController.nonVeg == 1,
          ),
          const SizedBox(width: Dimensions.paddingSizeSmall),
          ResponsiveHelper.isDesktop(context)
              ? const FilterViewWidget()
              : const SizedBox(),
        ],
      ),
    );
  }
}
