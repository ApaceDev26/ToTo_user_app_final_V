import 'package:carousel_slider/carousel_slider.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:toto_user/features/home/widgets/new_item_card_widget.dart';
import 'package:toto_user/features/product/controllers/product_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewPopularFoodsNearbyViewWidget extends StatefulWidget {
  const NewPopularFoodsNearbyViewWidget({super.key});

  @override
  State<NewPopularFoodsNearbyViewWidget> createState() =>
      _NewPopularFoodsNearbyViewWidgetState();
}

class _NewPopularFoodsNearbyViewWidgetState
    extends State<NewPopularFoodsNearbyViewWidget> {
  CarouselSliderController carouselController = CarouselSliderController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!Get.isRegistered<ProductController>()) return;
      final productController = Get.find<ProductController>();
      if (productController.popularProductList == null) {
        productController.getPopularProductList(false, 'all', true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final titleStyle = AppTypography.displayMd(colors.ink).copyWith(
      fontSize: isDesktop ? 26 : 22,
      height: 1.2,
      letterSpacing: -0.4,
    );
    return GetBuilder<ProductController>(builder: (productController) {
      return (productController.popularProductList != null &&
              productController.popularProductList!.isEmpty)
          ? const SizedBox()
          : Padding(
              padding: EdgeInsets.symmetric(
                  vertical: ResponsiveHelper.isMobile(context)
                      ? Dimensions.paddingSizeDefault
                      : Dimensions.paddingSizeLarge),
              child: SizedBox(
                  // Title + shorter landscape card.
                  height: ResponsiveHelper.isMobile(context) ? 320 : 345,
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      isDesktop
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 45),
                              child: Text('popular_foods_nearby'.tr,
                                  style: titleStyle),
                            )
                          : Padding(
                              padding: const EdgeInsets.only(
                                left: Dimensions.paddingSizeDefault,
                                right: Dimensions.paddingSizeDefault,
                                bottom: Dimensions.paddingSizeLarge,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text('popular_foods_nearby'.tr,
                                        style: titleStyle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                  ArrowIconButtonWidget(
                                      onTap: () => Get.toNamed(
                                          RouteHelper.getPopularFoodRoute(
                                              true))),
                                ],
                              )),
                      Expanded(
                        child: Row(
                          children: [
                            isDesktop
                                ? ArrowIconButtonWidget(
                                    isLeft: true,
                                    onTap: () =>
                                        carouselController.previousPage(),
                                  )
                                : const SizedBox(),
                            productController.popularProductList != null
                                ? Expanded(
                                    child: CarouselSlider.builder(
                                      carouselController: carouselController,
                                      options: CarouselOptions(
                                        height: ResponsiveHelper.isMobile(
                                                context)
                                            ? 240
                                            : 250,
                                        viewportFraction: isDesktop ? 0.2 : 0.47,
                                        enlargeFactor: isDesktop ? 0.2 : 0.35,
                                        enlargeCenterPage: true,
                                        disableCenter: true,
                                        enableInfiniteScroll: productController
                                                .popularProductList!.length >
                                            2,
                                        autoPlay: true,
                                        pauseAutoPlayOnTouch: true,
                                      ),
                                      itemCount: productController
                                          .popularProductList!.length,
                                      itemBuilder: (context, index, _) {
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0),
                                          child: NewItemCardWidget(
                                            product: productController
                                                    .popularProductList![
                                                index],
                                            isBestItem: true,
                                            isPopularNearbyItem: true,
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : const Expanded(
                                    child: NewItemCardShimmer(
                                      isPopularNearbyItem: true,
                                    ),
                                  ),
                            ResponsiveHelper.isDesktop(context)
                                ? ArrowIconButtonWidget(
                                    onTap: () =>
                                        carouselController.nextPage(),
                                  )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                    ],
                  )),
            );
    });
  }
}
