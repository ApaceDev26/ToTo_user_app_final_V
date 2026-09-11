import 'package:carousel_slider/carousel_slider.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/home/widgets/arrow_icon_button_widget.dart';
import 'package:toto_user/features/home/widgets/best_reviewed_item_card_widget.dart';
import 'package:toto_user/features/review/controllers/review_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NewBestReviewItemViewWidget extends StatefulWidget {
  final bool isPopular;

  const NewBestReviewItemViewWidget({super.key, required this.isPopular});

  @override
  State<NewBestReviewItemViewWidget> createState() =>
      _NewBestReviewItemViewWidgetState();
}

class _NewBestReviewItemViewWidgetState
    extends State<NewBestReviewItemViewWidget> {
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final titleStyle = AppTypography.displayMd(colors.ink).copyWith(
      fontSize: isDesktop ? 26 : 22,
      height: 1.2,
      letterSpacing: -0.4,
    );

    return GetBuilder<ReviewController>(builder: (reviewController) {
      return (reviewController.reviewedProductList != null &&
              reviewController.reviewedProductList!.isEmpty)
          ? const SizedBox()
          : Padding(
              padding: EdgeInsets.symmetric(
                vertical: ResponsiveHelper.isMobile(context)
                    ? Dimensions.paddingSizeExtraSmall
                    : Dimensions.paddingSizeLarge,
              ),
              child: ColoredBox(
                color: colors.canvas,
                child: SizedBox(
                  width: Dimensions.webMaxWidth,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          Dimensions.paddingSizeSmall,
                          AppSpacing.md,
                          Dimensions.paddingSizeSmall,
                          AppSpacing.md,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'best_reviewed_food'.tr,
                                style: titleStyle,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ArrowIconButtonWidget(
                              onTap: () => Get.toNamed(
                                RouteHelper.getPopularFoodRoute(
                                    widget.isPopular),
                              ),
                            ),
                          ],
                        ),
                      ),
                      reviewController.reviewedProductList != null
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: Dimensions.paddingSizeSmall,
                              ),
                              child: CarouselSlider.builder(
                                carouselController: _carouselController,
                                options: CarouselOptions(
                                  height:
                                      BestReviewedItemCardWidget.cardHeight +
                                          12,
                                  // Exactly 2 full cards; padEnds:false avoids
                                  // half | full | half centering.
                                  viewportFraction: 0.5,
                                  padEnds: false,
                                  autoPlay: true,
                                  autoPlayInterval: const Duration(seconds: 4),
                                  autoPlayAnimationDuration:
                                      const Duration(milliseconds: 800),
                                  pauseAutoPlayOnTouch: true,
                                  enableInfiniteScroll: reviewController
                                          .reviewedProductList!.length >
                                      2,
                                  enlargeCenterPage: false,
                                  disableCenter: true,
                                ),
                                itemCount: reviewController
                                    .reviewedProductList!.length,
                                itemBuilder: (context, index, _) {
                                  // Same trailing gap on every slide so odd→even
                                  // pairs (1|2, 3|4, …) never stick together.
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                      right: AppSpacing.sm,
                                      top: AppSpacing.xs,
                                      bottom: AppSpacing.sm,
                                    ),
                                    child: BestReviewedItemCardWidget(
                                      width: double.infinity,
                                      rank: index + 1,
                                      product: reviewController
                                          .reviewedProductList![index],
                                    ),
                                  );
                                },
                              ),
                            )
                          : const BestReviewedItemCardShimmer(),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
              ),
            );
    });
  }
}
