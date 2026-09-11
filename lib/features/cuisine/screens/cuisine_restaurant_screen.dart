import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/cuisine/controllers/cuisine_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/paginated_list_view_widget.dart';
import 'package:toto_user/common/widgets/product_view_widget.dart';
import 'package:toto_user/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CuisineRestaurantScreen extends StatefulWidget {
  final int cuisineId;
  final String? name;
  const CuisineRestaurantScreen({
    super.key,
    required this.cuisineId,
    required this.name,
  });

  @override
  State<CuisineRestaurantScreen> createState() =>
      _CuisineRestaurantScreenState();
}

class _CuisineRestaurantScreenState extends State<CuisineRestaurantScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Get.find<CuisineController>().initialize();
    Get.find<CuisineController>()
        .getCuisineRestaurantList(widget.cuisineId, 1, false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final title = '${widget.name ?? ''} ${'cuisines'.tr}'.trim();

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBarWidget(title: title),
      endDrawer: const MenuDrawerWidget(),
      endDrawerEnableOpenDragGesture: false,
      body: RefreshIndicator(
        color: colors.accent,
        backgroundColor: colors.surface,
        onRefresh: () async {
          await Get.find<CuisineController>()
              .getCuisineRestaurantList(widget.cuisineId, 1, true);
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          child: FooterViewWidget(
            child: Center(
              child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isDesktop) WebScreenTitleWidget(title: title),
                    if (!isDesktop)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.md,
                          AppSpacing.lg,
                          AppSpacing.sm,
                        ),
                        child: Text(
                          title,
                          style: AppTypography.displayMd(colors.ink).copyWith(
                            fontSize: 22,
                            height: 1.2,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                    GetBuilder<CuisineController>(
                      builder: (cuisineController) {
                        return PaginatedListViewWidget(
                          scrollController: _scrollController,
                          totalSize: cuisineController
                              .cuisineRestaurantsModel?.totalSize,
                          offset: cuisineController.cuisineRestaurantsModel !=
                                  null
                              ? int.parse(cuisineController
                                  .cuisineRestaurantsModel!.offset!)
                              : null,
                          onPaginate: (int? offset) async =>
                              await cuisineController.getCuisineRestaurantList(
                            widget.cuisineId,
                            offset!,
                            false,
                          ),
                          productView: ProductViewWidget(
                            isRestaurant: true,
                            products: null,
                            restaurants: cuisineController
                                .cuisineRestaurantsModel?.restaurants,
                            showTheme1Restaurant: true,
                            padding: EdgeInsets.only(
                              left: isDesktop
                                  ? AppSpacing.sm
                                  : AppSpacing.lg,
                              right: isDesktop
                                  ? AppSpacing.sm
                                  : AppSpacing.lg,
                              top: isDesktop
                                  ? AppSpacing.sm
                                  : AppSpacing.md,
                              bottom: isDesktop ? AppSpacing.sm : 0,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
