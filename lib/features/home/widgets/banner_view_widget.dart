import 'package:carousel_slider/carousel_slider.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/home/controllers/home_controller.dart';
import 'package:toto_user/features/restaurant/screens/restaurant_screen.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/features/product/domain/models/basic_campaign_model.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/common/models/restaurant_model.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/product_bottom_sheet_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class BannerViewWidget extends StatelessWidget {
  const BannerViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return GetBuilder<HomeController>(builder: (homeController) {
      return (homeController.bannerImageList != null &&
              homeController.bannerImageList!.isEmpty)
          ? const SizedBox()
          : Container(
              width: MediaQuery.of(context).size.width,
              height: GetPlatform.isDesktop ? 500 : 230,
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: homeController.bannerImageList != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: 190,
                          child: CarouselSlider.builder(
                            options: CarouselOptions(
                              aspectRatio: 1,
                              enlargeFactor: 0.5,
                              autoPlay: true,
                              height: 190,
                              viewportFraction: 1 - 0.08,
                              enlargeCenterPage: true,
                              disableCenter: true,
                              autoPlayInterval: const Duration(seconds: 7),
                              onPageChanged: (index, reason) {
                                homeController.setCurrentIndex(index, true);
                              },
                            ),
                            itemCount: homeController.bannerImageList!.isEmpty
                                ? 1
                                : homeController.bannerImageList!.length,
                            itemBuilder: (context, index, _) {
                              return InkWell(
                                onTap: () {
                                  if (homeController.bannerDataList![index]
                                      is Product) {
                                    Product? product =
                                        homeController.bannerDataList![index];
                                    ResponsiveHelper.isMobile(context)
                                        ? showModalBottomSheet(
                                            context: context,
                                            isScrollControlled: true,
                                            backgroundColor: Colors.transparent,
                                            builder: (con) =>
                                                ProductBottomSheetWidget(
                                                    product: product),
                                          )
                                        : showDialog(
                                            context: context,
                                            builder: (con) => Dialog(
                                                child: ProductBottomSheetWidget(
                                                    product: product)),
                                          );
                                  } else if (homeController
                                      .bannerDataList![index] is Restaurant) {
                                    Restaurant restaurant =
                                        homeController.bannerDataList![index];
                                    Get.toNamed(
                                      RouteHelper.getRestaurantRoute(
                                          restaurant.id),
                                      arguments: RestaurantScreen(
                                          restaurant: restaurant),
                                    );
                                  } else if (homeController
                                          .bannerDataList![index]
                                      is BasicCampaignModel) {
                                    BasicCampaignModel campaign =
                                        homeController.bannerDataList![index];
                                    Get.toNamed(
                                        RouteHelper.getBasicCampaignRoute(
                                            campaign));
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: colors.surface,
                                    borderRadius: AppRadius.lgAll,
                                    boxShadow: AppShadows.of(context, 2),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: AppRadius.lgAll,
                                    child: GetBuilder<SplashController>(
                                      builder: (splashController) {
                                        return CustomImageWidget(
                                          image:
                                              '${homeController.bannerImageList![index]}',
                                          fit: BoxFit.cover,
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: homeController.bannerImageList!
                              .asMap()
                              .entries
                              .map((entry) {
                            final index = entry.key;
                            final active =
                                index == homeController.currentIndex;
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.xxs),
                              child: AnimatedContainer(
                                duration: AppDurations.fast,
                                height: 4,
                                width: active ? 20 : 10,
                                decoration: BoxDecoration(
                                  borderRadius: AppRadius.pillAll,
                                  color: active
                                      ? colors.accent
                                      : colors.lineStrong,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm),
                      child: ClipRRect(
                        borderRadius: AppRadius.lgAll,
                        child: Shimmer(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: AppRadius.lgAll,
                              color: colors.line,
                            ),
                          ),
                        ),
                      ),
                    ),
            );
    });
  }
}
