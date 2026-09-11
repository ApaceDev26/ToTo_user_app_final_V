import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/home/widgets/new2_item_card_widget.dart';
import 'package:toto_user/features/product/controllers/campaign_controller.dart';
import 'package:toto_user/features/home/widgets/item_card_widget.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TodayTrendsViewWidget extends StatefulWidget {
  const TodayTrendsViewWidget({super.key});

  @override
  State<TodayTrendsViewWidget> createState() => _TodayTrendsViewWidgetState();
}

class _TodayTrendsViewWidgetState extends State<TodayTrendsViewWidget> {
  final ScrollController _scrollController = ScrollController();
  double _progressValue = 0.2;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateProgress);
  }

  void _updateProgress() {
    double maxScrollExtent = _scrollController.position.maxScrollExtent;
    double currentScroll = _scrollController.position.pixels;
    double progress = currentScroll / maxScrollExtent;
    setState(() {
      _progressValue = progress;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateProgress);
    _scrollController.dispose();
    super.dispose();
  }

  double _calculateItemWidth(BuildContext context) {
    // Get available width (container width minus right padding)
    double containerWidth = ResponsiveHelper.isDesktop(context)
        ? Dimensions.webMaxWidth
        : MediaQuery.of(context).size.width;

    double availableWidth =
        containerWidth - Dimensions.paddingSizeDefault; // right padding

    // Determine number of items to show based on platform
    int itemCount = ResponsiveHelper.isDesktop(context) ? 5 : 3;

    // Account for left padding of each item (12 pixels per item)
    double totalItemPadding = 12.0 * itemCount;

    // Calculate width per item to fit the determined number of items
    double itemWidth = (availableWidth - totalItemPadding) / itemCount;

    // Ensure minimum width for readability
    return itemWidth > 120 ? itemWidth : 120;
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
    final subtitleStyle = AppTypography.displayMd(colors.inkMuted).copyWith(
      fontSize: isDesktop ? 16 : 14,
      height: 1.3,
      letterSpacing: -0.2,
      fontWeight: FontWeight.w500,
    );
    return GetBuilder<CampaignController>(builder: (campaignController) {
      return (campaignController.itemCampaignList != null &&
              campaignController.itemCampaignList!.isEmpty)
          ? const SizedBox()
          : Padding(
              //padding: EdgeInsets.symmetric(vertical: ResponsiveHelper.isMobile(context)  ? Dimensions.paddingSizeDefault : Dimensions.paddingSizeLarge),
              padding: EdgeInsets.only(
                top: ResponsiveHelper.isMobile(context)
                    ? 0
                    : Dimensions.paddingSizeLarge,
                bottom: ResponsiveHelper.isMobile(context)
                    ? Dimensions.paddingSizeExtraSmall
                    : Dimensions.paddingSizeDefault,
              ),
              child: Container(
                height: ResponsiveHelper.isDesktop(context) ? 460 : 300,
                width: Dimensions.webMaxWidth,
                color: colors.canvas,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                          top: Dimensions.paddingSizeDefault,
                          left: Dimensions.paddingSizeDefault,
                          right: Dimensions.paddingSizeDefault),
                      child: Text('today_trends'.tr, style: titleStyle),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                          left: Dimensions.paddingSizeDefault,
                          bottom: Dimensions.paddingSizeSmall,
                          right: Dimensions.paddingSizeDefault),
                      child: Text('here_what_you_might_like_to_taste'.tr,
                          style: subtitleStyle),
                    ),
                    Expanded(
                      child: campaignController.itemCampaignList != null
                          ? ListView.builder(
                              controller: _scrollController,
                              itemCount:
                                  campaignController.itemCampaignList!.length,
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 12),
                                  child: New2ItemCardWidget(
                                    width: _calculateItemWidth(context),
                                    product: campaignController
                                        .itemCampaignList![index],
                                    isBestItem: false,
                                    isPopularNearbyItem: false,
                                    isCampaignItem: true,
                                  ),
                                );
                              },
                            )
                          : const ItemCardShimmer(isPopularNearbyItem: false),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: Dimensions.paddingSizeSmall,
                        left: Dimensions.paddingSizeDefault,
                        right: Dimensions.paddingSizeDefault,
                        bottom: Dimensions.paddingSizeSmall,
                      ),
                      child: Center(
                        child: SizedBox(
                          height: 8,
                          width: context.width * 0.3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.all(
                                Radius.circular(Dimensions.radiusSmall)),
                            child: LinearProgressIndicator(
                              minHeight: 5,
                              value: _progressValue,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                              backgroundColor: Theme.of(context)
                                  .primaryColor
                                  .withValues(alpha: 0.25),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
    });
  }
}
