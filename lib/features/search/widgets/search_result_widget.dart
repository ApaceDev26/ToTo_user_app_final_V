import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/features/search/controllers/search_controller.dart'
    as search;
import 'package:toto_user/features/search/widgets/item_view_widget.dart';
import 'package:toto_user/features/cart/controllers/cart_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchResultWidget extends StatefulWidget {
  final String searchText;
  const SearchResultWidget({super.key, required this.searchText});

  @override
  SearchResultWidgetState createState() => SearchResultWidgetState();
}

class SearchResultWidgetState extends State<SearchResultWidget>
    with TickerProviderStateMixin {
  TabController? _tabController;

  ScrollController scrollController = ScrollController();
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();

    search.SearchController searchController =
        Get.find<search.SearchController>();

    _tabController = TabController(length: 2, initialIndex: 0, vsync: this);

    scrollController.addListener(() {
      // Show/hide back to top button based on scroll position
      if (scrollController.hasClients) {
        final shouldShow = scrollController.position.pixels > 200;
        if (shouldShow != _showBackToTop) {
          setState(() {
            _showBackToTop = shouldShow;
          });
        }
      }

      if (scrollController.position.pixels ==
              scrollController.position.maxScrollExtent &&
          searchController.totalSize != null &&
          searchController.pageOffset != null) {
        int totalPage = (searchController.totalSize! / 10).ceil();
        if (searchController.pageOffset! < totalPage) {
          searchController.searchData1(
              searchController.searchText, searchController.pageOffset! + 1);
          searchController.pageOffset = searchController.pageOffset! + 1;
        }
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    _tabController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          GetBuilder<search.SearchController>(builder: (searchController) {
            bool isNull = true;
            int length = 0;
            if (searchController.isRestaurant) {
              isNull = searchController.searchRestList == null;
              if (!isNull) {
                length = searchController.searchRestList!.length;
              }
            } else {
              isNull = searchController.searchProductList == null;
              if (!isNull) {
                length = searchController.totalSize ?? 0;
              }
            }
            return isNull
                ? const SizedBox()
                : Center(
                    child: SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Padding(
                          padding:
                              const EdgeInsets.all(Dimensions.paddingSizeSmall),
                          child: Row(children: [
                            Text(
                              length.toString(),
                              style: robotoBold.copyWith(
                                  color: Theme.of(context).primaryColor,
                                  fontSize: Dimensions.fontSizeSmall),
                            ),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Text(
                              'results_found'.tr,
                              style: robotoRegular.copyWith(
                                  color: Theme.of(context).disabledColor,
                                  fontSize: Dimensions.fontSizeSmall),
                            ),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            Text(
                              '"${widget.searchText}"',
                              style: robotoBold.copyWith(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color,
                                  fontSize: Dimensions.fontSizeSmall),
                            ),
                          ]),
                        )));
          }),

          Center(
              child: Container(
            width: Dimensions.webMaxWidth,
            color: AppColors.of(context).canvas,
            child: Align(
              alignment: ResponsiveHelper.isDesktop(context)
                  ? Alignment.centerLeft
                  : Alignment.center,
              child: Container(
                width: ResponsiveHelper.isDesktop(context)
                    ? 250
                    : Dimensions.webMaxWidth,
                color: ResponsiveHelper.isDesktop(context)
                    ? Colors.transparent
                    : AppColors.of(context).canvas,
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).primaryColor,
                  indicatorWeight: 3,
                  labelColor: Theme.of(context).primaryColor,
                  unselectedLabelColor: Theme.of(context).disabledColor,
                  unselectedLabelStyle: robotoRegular.copyWith(
                      color: Theme.of(context).disabledColor,
                      fontSize: Dimensions.fontSizeSmall),
                  labelStyle: robotoBold.copyWith(
                      fontSize: Dimensions.fontSizeSmall,
                      color: Theme.of(context).primaryColor),
                  onTap: (int index) {
                    Get.find<search.SearchController>()
                        .setRestaurant(index == 1);
                    Get.find<search.SearchController>()
                        .searchData1(widget.searchText, 1);
                  },
                  tabs: [
                    Tab(text: 'food'.tr),
                    Tab(text: 'restaurants'.tr),
                  ],
                ),
              ),
            ),
          )),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: NeverScrollableScrollPhysics(),
              children: [
                ItemViewWidget(
                    isRestaurant: false, scrollController: scrollController),
                ItemViewWidget(
                    isRestaurant: true, scrollController: scrollController),
              ],
            ),
          ),

          // Expanded(child: NotificationListener(
          //   onNotification: (dynamic scrollNotification) {
          //     if (scrollNotification is ScrollEndNotification) {
          //       Get.find<search.SearchController>().setRestaurant(_tabController!.index == 1);
          //       Get.find<search.SearchController>().searchData1(widget.searchText, 1);
          //     }
          //     return false;
          //   },
          //   child: TabBarView(
          //     controller: _tabController,
          //     children: [
          //       ItemViewWidget(isRestaurant: false, scrollController: scrollController),
          //       ItemViewWidget(isRestaurant: true, scrollController: scrollController),
          //     ],
          //   ),
          // )),
        ]),
        // Back to top button
        if (_showBackToTop)
          GetBuilder<CartController>(builder: (cartController) {
            // Adjust bottom position based on cart visibility
            final bool hasCart = cartController.cartList.isNotEmpty &&
                !ResponsiveHelper.isDesktop(context);
            final double bottomPosition =
                hasCart ? (GetPlatform.isIOS ? 120 : 90) : 20;

            return Positioned(
              right: ResponsiveHelper.isDesktop(context) ? 30 : 20,
              bottom: bottomPosition,
              child: Material(
                elevation: 4,
                shape: const CircleBorder(),
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  onPressed: () {
                    scrollController.animateTo(
                      0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_upward,
                      size: 20,
                      color: Get.isDarkMode ? Colors.white : Colors.white,
                    ),
                  ),
                ),
              ),
            );
          }),
      ],
    );
  }
}
