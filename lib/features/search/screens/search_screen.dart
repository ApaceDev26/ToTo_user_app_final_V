import 'package:flutter/cupertino.dart';
import 'package:shimmer_animation/shimmer_animation.dart';
import 'package:toto_user/common/widgets/custom_asset_image_widget.dart';
import 'package:toto_user/common/widgets/search_field_widget.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_icons.dart';
import 'package:toto_user/design_system/app_radius.dart';
import 'package:toto_user/design_system/app_shadows.dart';
import 'package:toto_user/design_system/app_spacing.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/home/widgets/cuisine_card_widget.dart';
import 'package:toto_user/features/search/controllers/search_controller.dart'
    as search;
import 'package:toto_user/features/search/widgets/filter_widget.dart';
import 'package:toto_user/features/search/widgets/search_result_widget.dart';
import 'package:toto_user/features/cuisine/controllers/cuisine_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/web_menu_bar.dart';
import 'package:toto_user/helper/in_app_messaging_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'dart:async';

import '../../home/widgets/location_banner_view_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  SearchScreenState createState() => SearchScreenState();
}

class SearchScreenState extends State<SearchScreen> {
  final ScrollController scrollController = ScrollController();
  final GlobalKey _searchBarKey = GlobalKey();

  late bool _isLoggedIn;
  final TextEditingController _searchTextEditingController =
      TextEditingController();

  List<String> _foodsAndRestaurants = <String>[];
  bool _showSuggestion = false;
  Timer? _searchDebounce;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    _isLoggedIn = Get.find<AuthController>().isLoggedIn();
    Get.find<search.SearchController>().setSearchMode(true, canUpdate: false);
    if (_isLoggedIn) {
      Get.find<search.SearchController>().getSuggestedFoods();
    }
    Get.find<CuisineController>().getCuisineList();
    Get.find<search.SearchController>().getHistoryList();

    // Trigger in-app messages for search screen
    Future.delayed(const Duration(milliseconds: 800), () {
      InAppMessagingHelper.triggerForScreen('search');
      // Also check for immediate messages
      InAppMessagingHelper.checkForImmediateMessages();
    });
  }

  Future<void> _searchSuggestions(String query) async {
    _foodsAndRestaurants = [];
    if (query == '') {
      _showSuggestion = false;
      _foodsAndRestaurants = [];
    } else {
      _showSuggestion = true;
      _foodsAndRestaurants =
          await Get.find<search.SearchController>().getSearchSuggestions(query);
    }
    setState(() {});
  }

  void _actionOnBackButton() {
    if (!Get.find<search.SearchController>().isSearchMode) {
      Get.find<search.SearchController>().setSearchMode(true);
      _searchTextEditingController.text = '';
      _showSuggestion = false;
    } else if (_searchTextEditingController.text.isNotEmpty) {
      _searchTextEditingController.text = '';
      _showSuggestion = false;
      setState(() {});
    } else {
      Future.delayed(const Duration(milliseconds: 10),
          () => Get.offAllNamed(RouteHelper.getInitialRoute()));
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = ResponsiveHelper.isDesktop(context);
    final colors = AppColors.of(context);
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        _actionOnBackButton();
      },
      child: Scaffold(
        backgroundColor: colors.canvas,
        appBar: isDesktop ? const WebMenuBar() : null,
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        body: SafeArea(child:
            GetBuilder<search.SearchController>(builder: (searchController) {
          return Column(children: [
            Container(
              height: isDesktop ? 100 : 80,
              decoration: BoxDecoration(
                color: colors.canvas,
                boxShadow: AppShadows.of(context, 1),
                border: Border(
                  bottom: BorderSide(color: colors.line, width: 1),
                ),
              ),
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                    SizedBox(
                        width: Dimensions.webMaxWidth,
                        child: Row(children: [
                          SizedBox(
                              width: ResponsiveHelper.isMobile(context)
                                  ? AppSpacing.sm
                                  : AppSpacing.xs),
                          !isDesktop
                              ? IconButton(
                                  onPressed: () => _actionOnBackButton(),
                                  icon: Icon(Icons.arrow_back_ios_new_rounded,
                                      size: AppIcons.sm, color: colors.ink),
                                )
                              : const SizedBox(),
                          Expanded(
                              child: Container(
                            width: double.infinity,
                            height: 50,
                            decoration: BoxDecoration(
                              color: colors.surfaceElevated,
                              borderRadius: AppRadius.mdAll,
                              border: Border.all(color: colors.line, width: 1),
                            ),
                            padding: const EdgeInsets.only(left: AppSpacing.lg),
                            child: Row(children: [
                              Expanded(
                                child: SearchFieldWidget(
                                  controller: _searchTextEditingController,
                                  hint: 'search_food_or_restaurant'.tr,
                                  onChanged: (value) {
                                    _searchSuggestions(value);
                                    _searchDebounce?.cancel();
                                    if (value.trim().isNotEmpty) {
                                      _searchDebounce = Timer(
                                          const Duration(milliseconds: 400),
                                          () {
                                        _actionSearch(
                                            context, searchController, true);
                                      });
                                    } else {
                                      searchController.clearSearchResults();
                                    }
                                  },
                                  onSubmit: (value) {
                                    _searchDebounce?.cancel();
                                    _actionSearch(
                                        context, searchController, true);
                                    if (!searchController.isSearchMode &&
                                        _searchTextEditingController
                                            .text.isEmpty) {
                                      searchController.setSearchMode(true);
                                    }
                                  },
                                ),
                              ),
                              IconButton(
                                key: _searchBarKey,
                                onPressed: () {
                                  _actionSearch(
                                      context, searchController, false);
                                },
                                icon: Icon(
                                  !searchController.isSearchMode
                                      ? Icons.filter_list_rounded
                                      : Icons.search_rounded,
                                  size: AppIcons.lg,
                                  color: colors.accent,
                                ),
                              ),
                            ]),
                          )),
                          SizedBox(width: isDesktop ? 0 : AppSpacing.x3l),
                        ])),
                  ])),
            ),
            Expanded(
                child: searchController.isSearchMode
                    ? _showSuggestion
                        ? showSuggestions(
                            context,
                            searchController,
                            _foodsAndRestaurants,
                          )
                        : SingleChildScrollView(
                            controller: scrollController,
                            physics: const BouncingScrollPhysics(),
                            padding: isDesktop
                                ? EdgeInsets.zero
                                : const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm),
                            child: FooterViewWidget(
                              child: SizedBox(
                                  width: Dimensions.webMaxWidth,
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(height: AppSpacing.xs),
                                        searchController.historyList.isNotEmpty
                                            ? Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                    Text('recent_search'.tr,
                                                        style: AppTypography
                                                            .titleSm(
                                                                colors.ink)),
                                                    InkWell(
                                                      onTap: () => searchController
                                                          .clearSearchAddress(),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                    AppSpacing
                                                                        .sm,
                                                                horizontal: 4),
                                                        child: Text(
                                                            'clear_all'.tr,
                                                            style: AppTypography
                                                                .labelMd(colors
                                                                    .danger)),
                                                      ),
                                                    ),
                                                  ])
                                            : const SizedBox(),
                                        SizedBox(
                                            height: searchController
                                                    .historyList.isNotEmpty
                                                ? AppSpacing.xs
                                                : 0),
                                        SizedBox(
                                          child: ListView.builder(
                                            itemCount: searchController
                                                        .historyList.length >
                                                    10
                                                ? 10
                                                : searchController
                                                    .historyList.length,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () {
                                                  _searchTextEditingController
                                                          .text =
                                                      searchController
                                                          .historyList[index];
                                                  searchController.searchData1(
                                                      searchController
                                                          .historyList[index],
                                                      1);
                                                },
                                                child: Row(children: [
                                                  Icon(CupertinoIcons.search,
                                                      size: 18,
                                                      color: colors.inkFaint),
                                                  const SizedBox(
                                                      width: AppSpacing.sm),
                                                  Expanded(
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical:
                                                              AppSpacing.sm),
                                                      child: Text(
                                                        searchController
                                                            .historyList[index],
                                                        style: AppTypography
                                                            .bodyMd(colors.ink),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                    onTap: () =>
                                                        searchController
                                                            .removeHistory(
                                                                index),
                                                    child: Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical:
                                                              AppSpacing.xs),
                                                      child: Icon(Icons.close,
                                                          color:
                                                              colors.inkFaint,
                                                          size: 20),
                                                    ),
                                                  )
                                                ]),
                                              );
                                            },
                                          ),
                                        ),
                                        SizedBox(
                                            height: searchController.historyList
                                                        .isNotEmpty &&
                                                    _isLoggedIn
                                                ? AppSpacing.xl
                                                : 0),
                                        _isLoggedIn
                                            ? (searchController
                                                            .suggestedFoodList ==
                                                        null ||
                                                    (searchController
                                                                .suggestedFoodList !=
                                                            null &&
                                                        searchController
                                                            .suggestedFoodList!
                                                            .isNotEmpty))
                                                ? Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom:
                                                                AppSpacing.lg),
                                                    child: Text(
                                                      'recommended'.tr,
                                                      style:
                                                          AppTypography.titleSm(
                                                              colors.ink),
                                                    ),
                                                  )
                                                : const SizedBox()
                                            : const SizedBox(),
                                        _isLoggedIn
                                            ? searchController
                                                        .suggestedFoodList !=
                                                    null
                                                ? searchController
                                                        .suggestedFoodList!
                                                        .isNotEmpty
                                                    ? Wrap(
                                                        children: searchController
                                                            .suggestedFoodList!
                                                            .map((product) {
                                                          return Padding(
                                                            padding: const EdgeInsets
                                                                .only(
                                                                right:
                                                                    AppSpacing
                                                                        .sm,
                                                                bottom:
                                                                    AppSpacing
                                                                        .sm),
                                                            child: InkWell(
                                                              onTap: () {
                                                                _searchTextEditingController
                                                                        .text =
                                                                    product
                                                                        .name!;
                                                                searchController
                                                                    .searchData1(
                                                                        product
                                                                            .name!,
                                                                        1);
                                                              },
                                                              borderRadius:
                                                                  AppRadius
                                                                      .smAll,
                                                              child: Container(
                                                                padding: const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        AppSpacing
                                                                            .sm,
                                                                    vertical:
                                                                        AppSpacing
                                                                            .sm),
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: colors
                                                                      .accentSoft,
                                                                  borderRadius:
                                                                      AppRadius
                                                                          .smAll,
                                                                  border: Border.all(
                                                                      color: colors
                                                                          .line),
                                                                ),
                                                                child: Text(
                                                                  product.name!,
                                                                  style: AppTypography
                                                                      .labelMd(
                                                                          colors
                                                                              .accent),
                                                                  maxLines: 1,
                                                                  overflow:
                                                                      TextOverflow
                                                                          .ellipsis,
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        }).toList(),
                                                      )
                                                    : const SizedBox()
                                                : Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: Wrap(
                                                      children: [
                                                        0,
                                                        1,
                                                        2,
                                                        3,
                                                        4,
                                                        5
                                                      ].map((n) {
                                                        return Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(
                                                                  right:
                                                                      AppSpacing
                                                                          .sm,
                                                                  bottom:
                                                                      AppSpacing
                                                                          .sm),
                                                          child: Shimmer(
                                                              child: Container(
                                                                  height: 30,
                                                                  width:
                                                                      n % 3 == 0
                                                                          ? 100
                                                                          : 150,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: colors
                                                                        .line,
                                                                    borderRadius:
                                                                        AppRadius
                                                                            .smAll,
                                                                  ))),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  )
                                            : const SizedBox(),
                                        const SizedBox(height: AppSpacing.xl),
                                        GetBuilder<CuisineController>(
                                            builder: (cuisineController) {
                                          return (cuisineController
                                                          .cuisineModel !=
                                                      null &&
                                                  cuisineController
                                                      .cuisineModel!
                                                      .cuisines!
                                                      .isEmpty)
                                              ? const SizedBox()
                                              : Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    (cuisineController
                                                                .cuisineModel !=
                                                            null)
                                                        ? Text(
                                                            'cuisines'.tr,
                                                            style: AppTypography
                                                                .titleSm(
                                                                    colors.ink),
                                                          )
                                                        : const SizedBox(),
                                                    const SizedBox(
                                                        height: AppSpacing.lg),
                                                    (cuisineController
                                                                .cuisineModel !=
                                                            null)
                                                        ? cuisineController
                                                                .cuisineModel!
                                                                .cuisines!
                                                                .isNotEmpty
                                                            ? GetBuilder<
                                                                    CuisineController>(
                                                                builder:
                                                                    (cuisineController) {
                                                                return cuisineController
                                                                            .cuisineModel !=
                                                                        null
                                                                    ? GridView.builder(
                                                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                                                          crossAxisCount: isDesktop
                                                                              ? 8
                                                                              : ResponsiveHelper.isTab(context)
                                                                                  ? 6
                                                                                  : 4,
                                                                          mainAxisSpacing:
                                                                              15,
                                                                          crossAxisSpacing: isDesktop
                                                                              ? 35
                                                                              : 15,
                                                                          childAspectRatio: isDesktop
                                                                              ? 1
                                                                              : 1,
                                                                        ),
                                                                        shrinkWrap: true,
                                                                        itemCount: cuisineController.cuisineModel!.cuisines!.length,
                                                                        scrollDirection: Axis.vertical,
                                                                        physics: const NeverScrollableScrollPhysics(),
                                                                        itemBuilder: (context, index) {
                                                                          return InkWell(
                                                                            onTap:
                                                                                () {
                                                                              Get.toNamed(RouteHelper.getCuisineRestaurantRoute(cuisineController.cuisineModel!.cuisines![index].id, cuisineController.cuisineModel!.cuisines![index].name));
                                                                            },
                                                                            child:
                                                                                SizedBox(
                                                                              height: 130,
                                                                              child: CuisineCardWidget(
                                                                                image: '${cuisineController.cuisineModel!.cuisines![index].imageFullUrl}',
                                                                                name: cuisineController.cuisineModel!.cuisines![index].name!,
                                                                                fromSearchPage: true,
                                                                              ),
                                                                            ),
                                                                          );
                                                                        })
                                                                    : Center(child: CircularProgressIndicator(color: colors.accent));
                                                              })
                                                            : Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        top:
                                                                            10),
                                                                child: Text(
                                                                    'no_suggestions_available'
                                                                        .tr,
                                                                    style: AppTypography
                                                                        .bodyMd(
                                                                            colors.inkMuted)))
                                                        : const SizedBox(),
                                                    const SizedBox(
                                                        height: AppSpacing.lg),
                                                  ],
                                                );
                                        }),
                                        LocationBannerViewWidget()
                                      ])),
                            ),
                          )
                    : SearchResultWidget(
                        searchText: _searchTextEditingController.text.trim())),
          ]);
        })),
        bottomNavigationBar: const SizedBox(),
      ),
    );
  }

  Widget showSuggestions(
      BuildContext context,
      search.SearchController searchController,
      List<String> foodsAndRestaurants) {
    final colors = AppColors.of(context);
    return SingleChildScrollView(
      child: FooterViewWidget(
        child: SizedBox(
          width: Dimensions.webMaxWidth,
          child: foodsAndRestaurants.isNotEmpty
              ? ListView.builder(
                  itemCount: foodsAndRestaurants.length,
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(foodsAndRestaurants[index],
                          style: AppTypography.bodyMd(colors.ink)),
                      leading:
                          Icon(Icons.search_rounded, color: colors.inkFaint),
                      trailing: Icon(Icons.north_west_rounded,
                          color: colors.inkFaint),
                      onTap: () async {
                        _searchTextEditingController.text =
                            foodsAndRestaurants[index];
                        _actionSearch(context, searchController, true);
                      },
                    );
                  },
                )
              : Padding(
                  padding: EdgeInsets.only(top: context.height * 0.2),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const CustomAssetImageWidget(Images.emptyRestaurant),
                        const SizedBox(height: AppSpacing.xl),
                        Text('no_suggestions_found'.tr,
                            style: AppTypography.titleSm(colors.inkMuted)),
                      ]),
                ),
        ),
      ),
    );
  }

  void _actionSearch(BuildContext context,
      search.SearchController searchController, bool isSubmit) {
    if (searchController.isSearchMode || isSubmit) {
      if (_searchTextEditingController.text.trim().isNotEmpty) {
        searchController.searchData1(
            _searchTextEditingController.text.trim(), 1);
      } else {
        showCustomSnackBar('search_food_or_restaurant'.tr);
      }
    } else {
      double? maxValue =
          searchController.upperValue > 0 ? searchController.upperValue : 1000;
      double? minValue = searchController.lowerValue;
      ResponsiveHelper.isMobile(context)
          ? Get.bottomSheet(
              FilterWidget(
                  maxValue: maxValue,
                  minValue: minValue,
                  isRestaurant: searchController.isRestaurant),
              isScrollControlled: true)
          : /*Get.dialog(Dialog(
        // insetPadding: const EdgeInsets.all(30),
        child: FilterWidget(maxValue: maxValue, minValue: minValue, isRestaurant: searchController.isRestaurant),
      )) */
          _showSearchDialog(maxValue, minValue, searchController.isRestaurant);
    }
  }

  Future<void> _showSearchDialog(
      double? maxValue, double? minValue, bool isRestaurant) async {
    RenderBox renderBox =
        _searchBarKey.currentContext!.findRenderObject() as RenderBox;
    final searchBarPosition = renderBox.localToGlobal(Offset.zero);

    await showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        final colors = AppColors.of(context);
        return Stack(children: [
          Positioned(
            top: searchBarPosition.dy + 40,
            left: searchBarPosition.dx - 400,
            width: renderBox.size.width + 400,
            height: renderBox.size.height +
                MediaQuery.of(context).size.height * 0.6,
            child: Material(
              color: colors.surface,
              elevation: 0,
              borderRadius: AppRadius.xlAll,
              child: FilterWidget(
                  maxValue: maxValue,
                  minValue: minValue,
                  isRestaurant: isRestaurant),
            ),
          ),
        ]);
      },
    );
  }
}
