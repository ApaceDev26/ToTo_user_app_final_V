import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:toto_user/features/home/widgets/restaurants_card_widget.dart';
import 'package:toto_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/features/restaurant/screens/restaurant_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewOnStackFoodViewWidget extends StatelessWidget {
  final bool isLatest;
  const NewOnStackFoodViewWidget({super.key, required this.isLatest});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final titleStyle = AppTypography.displayMd(colors.ink).copyWith(
      fontSize: isDesktop ? 26 : 22,
      height: 1.2,
      letterSpacing: -0.4,
    );
    return GetBuilder<RestaurantController>(builder: (restController) {
        return (restController.latestRestaurantList != null && restController.latestRestaurantList!.isEmpty) ? const SizedBox() : Padding(
          padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context) ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
          child: Container(
            width: Dimensions.webMaxWidth,
            height: 210,
            color: colors.canvas,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Expanded(
                      child: Text(
                        '${'new_on'.tr} ${AppConstants.appName}',
                        style: titleStyle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    ArrowIconButtonWidget(
                      onTap: () => Get.toNamed(RouteHelper.getAllRestaurantRoute(isLatest ? 'latest' : '')),
                    ),
                  ]),
                ),


                restController.latestRestaurantList != null ? SizedBox(
                  height: 130,
                  child: ListView.builder(
                    padding: const EdgeInsets.only(right: Dimensions.paddingSizeDefault),
                    itemCount: restController.latestRestaurantList!.length,
                      shrinkWrap: true,
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(left: Dimensions.paddingSizeDefault),
                          child: InkWell(
                            onTap: () {
                              Get.toNamed(
                                RouteHelper.getRestaurantRoute(restController.latestRestaurantList![index].id),
                                arguments: RestaurantScreen(restaurant: restController.latestRestaurantList![index]),
                              );
                            },
                            child: RestaurantsCardWidget(
                              isNewOnStackFood: true,
                              restaurant: restController.latestRestaurantList![index],
                            ),
                          ),
                        );
                      },
                  ),
                ) : const RestaurantsCardShimmer(isNewOnStackFood: false),
             ],
            ),

          ),
        );
      }
    );
  }
}
