import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toto_user/common/models/restaurant_model.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/custom_asset_image_widget.dart';
import 'package:toto_user/common/widgets/custom_bottom_sheet_widget.dart';
import 'package:toto_user/common/widgets/custom_distance_cliper_widget.dart';
import 'package:toto_user/common/widgets/custom_favourite_widget.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/custom_ink_well_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/paginated_list_view_widget.dart';
import 'package:toto_user/common/widgets/restaurant_distance_text.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/dine_in/controllers/dine_in_controller.dart';
import 'package:toto_user/features/dine_in/widgets/dine_in_restaurant_filter_bottom_sheet.dart';
import 'package:toto_user/features/dine_in/widgets/dine_in_restaurant_shimmer_widget.dart';
import 'package:toto_user/features/favourite/controllers/favourite_controller.dart';
import 'package:toto_user/features/restaurant/screens/restaurant_screen.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';

class DineInRestaurantScreen extends StatefulWidget {
  const DineInRestaurantScreen({super.key});

  @override
  State<DineInRestaurantScreen> createState() => _DineInRestaurantScreenState();
}

class _DineInRestaurantScreenState extends State<DineInRestaurantScreen> {

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<DineInController>().initSetup(willUpdate: false);
    Get.find<DineInController>().getDineInRestaurantList(1, false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBarWidget(
        title: 'restaurant_list'.tr,
        actions: [
          IconButton(
            onPressed: () {
              showCustomBottomSheet(child: const DineRestaurantFilterBottomSheet());
            },
            icon: Icon(Icons.filter_list_outlined, color: colors.accent),
          ),
        ],
      ),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      floatingActionButton: ResponsiveHelper.isDesktop(context) ? null : Align(
        alignment: ResponsiveHelper.isDesktop(context) ? Alignment.bottomRight : Alignment.bottomCenter,
        child: Padding(
          padding: const EdgeInsets.only(left: 25),
          child: FloatingActionButton.extended(
            backgroundColor: colors.ink,
            foregroundColor: colors.canvas,
            onPressed: () {
              Get.toNamed(RouteHelper.getMapViewRoute(fromDineInScreen: true));
            },
            label: Row(children: [

              CustomAssetImageWidget(Images.dineInMap, height: 24, width: 24),
              const SizedBox(width: AppSpacing.sm),

              Text('view_from_map'.tr, style: AppTypography.labelLg(colors.canvas)),

            ]),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        child: FooterViewWidget(
          child: Center(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(mainAxisSize: MainAxisSize.min,
                children: [

                  const SizedBox(height: AppSpacing.sm),

                  ResponsiveHelper.isDesktop(context) ? Container(
                    height: 64, color: colors.accentSoft,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Row(children: [
                      Text(
                        'restaurant_list'.tr,
                        style: AppTypography.titleSm(colors.ink),
                      ),

                      const Spacer(),

                      InkWell(
                        onTap: () => Get.toNamed(RouteHelper.getMapViewRoute(fromDineInScreen: true)),
                        borderRadius: AppRadius.smAll,
                        child: Container(
                          width: 180,
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.smAll,
                            color: colors.ink,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [

                            CustomAssetImageWidget(Images.dineInMap, height: 24, width: 24),
                            const SizedBox(width: AppSpacing.sm),

                            Text('view_from_map'.tr, style: AppTypography.labelMd(colors.canvas)),

                          ]),
                        ),
                      ),

                      const SizedBox(width: AppSpacing.sm),

                      InkWell(
                        onTap: () {
                          Get.dialog(Dialog(child: const DineRestaurantFilterBottomSheet()));
                        },
                        borderRadius: AppRadius.smAll,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: AppRadius.smAll,
                            border: Border.all(color: colors.accent),
                            color: colors.surface,
                          ),
                          padding: const EdgeInsets.all(AppSpacing.xs),
                          child: Icon(Icons.filter_list_outlined, color: colors.accent),
                        ),
                      ),
                    ]),
                  ) : const SizedBox(),

                  SizedBox(height: ResponsiveHelper.isDesktop(context) ? AppSpacing.xl : 0),

                  GetBuilder<DineInController>(builder: (dineInController) {
                    return dineInController.dineInModel != null ? dineInController.dineInModel!.restaurants!.isNotEmpty ?
                    PaginatedListViewWidget(
                      scrollController: _scrollController,
                      totalSize: dineInController.dineInModel!.totalSize,
                      offset: dineInController.dineInModel!.offset,
                      onPaginate: (int? offset) async => await dineInController.getDineInRestaurantList(offset!, false),
                      productView: dineInRestaurant(dineInController.dineInModel!.restaurants!),
                    ) : Center(child: Padding(
                      padding: EdgeInsets.only(top: context.height * 0.3),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(AppSpacing.xl),
                            decoration: BoxDecoration(
                              color: colors.accentSoft,
                              shape: BoxShape.circle,
                            ),
                            child: const CustomAssetImageWidget(Images.emptyRestaurant, height: 80, width: 80),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Text('there_is_no_restaurant'.tr, style: AppTypography.bodyMd(colors.inkMuted)),
                        ],
                      ),
                    )) : DineInRestaurantShimmerWidget();
                  }),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget dineInRestaurant(List<Restaurant> restaurants) {
    final colors = AppColors.of(context);

    return GridView.builder(
      shrinkWrap: true,
      itemCount: restaurants.length,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 3,
        mainAxisSpacing: AppSpacing.xl,
        crossAxisSpacing: AppSpacing.xl,
        mainAxisExtent: 230,
      ),
      padding: ResponsiveHelper.isDesktop(context) ? EdgeInsets.zero : const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg, bottom: 100),
      itemBuilder: (context, index) {

        Restaurant restaurant = restaurants[index];
        bool isAvailable = restaurant.open == 1 && restaurant.active!;

        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Container(
            height: 195,
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: AppRadius.mdAll,
              boxShadow: AppShadows.of(context, 1),
            ),
            child: CustomInkWellWidget(
              onTap: () {
                if(restaurant.restaurantStatus == 1){
                  Get.toNamed(RouteHelper.getRestaurantRoute(restaurant.id, fromDinIn: true),
                    arguments: RestaurantScreen(restaurant: restaurant, fromDineIn: true),
                  );
                }else if(restaurant.restaurantStatus == 0){
                  showCustomSnackBar('restaurant_is_not_available'.tr);
                }
              },
              radius: AppRadius.md,
              child: Column(children: [

                Stack(clipBehavior: Clip.none, children: [
                  SizedBox(
                    height: 114,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.md),
                        topRight: Radius.circular(AppRadius.md),
                      ),
                      child: CustomImageWidget(
                        image: restaurant.coverPhotoFullUrl ?? '',
                        width: double.infinity,
                        fit: BoxFit.cover,
                        isRestaurant: true,
                      ),
                    ),
                  ),

                  Positioned(
                    top: AppSpacing.sm, right: AppSpacing.sm,
                    child: GetBuilder<FavouriteController>(builder: (favouriteController) {
                      bool isWished = favouriteController.wishRestIdList.contains(restaurant.id);
                      return CustomFavouriteWidget(
                        isWished: isWished,
                        isRestaurant: true,
                        restaurant: restaurant,
                      );
                    }),
                  ),

                  !isAvailable ? Positioned(child: Container(
                    height: 114, width: double.infinity,
                    decoration: BoxDecoration(
                      color: colors.overlay,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppRadius.md),
                        topRight: Radius.circular(AppRadius.md),
                      ),
                    ),
                  )) : const SizedBox(),

                  !isAvailable ? Positioned(top: 10, left: 10, child: Container(
                    decoration: BoxDecoration(
                        color: colors.danger.withValues(alpha: 0.5),
                        borderRadius: AppRadius.lgAll,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l, vertical: AppSpacing.xs),
                    child: Row(children: [
                      Icon(Icons.access_time, size: 12, color: colors.onAccent),
                      const SizedBox(width: AppSpacing.xs),

                      Text(
                        restaurant.restaurantOpeningTime == 'closed' ? 'closed_now'.tr : '${'closed_now'.tr} ${!restaurant.active! ? '' : '(${'open_at'.tr} ${DateConverter.convertRestaurantOpenTime(restaurant.restaurantOpeningTime!)})'}',
                        style: AppTypography.labelMd(colors.onAccent),
                      ),
                    ]),
                  )) : const SizedBox(),

                  Positioned(
                    top: 91, right: 10,
                    child: ClipPath(
                      clipper: CurvedTopClipper(),
                      child: Container(
                        height: 25,
                        color: colors.surface,
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                        child: Center(
                          child: RestaurantDistanceText(
                            latitude: restaurant.latitude!,
                            longitude: restaurant.longitude!,
                            fractionDigits: 2,
                            style: AppTypography.labelSm(colors.accent),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: 105, left: 10,
                    child: Column(
                      children: [
                        Container(
                          height: 80, width: 80,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            borderRadius: AppRadius.xsAll,
                            border: Border.all(color: colors.line, width: 2.5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3.5),
                            child: CustomImageWidget(
                              image: restaurant.logoFullUrl ?? '',
                              fit: BoxFit.cover, height: 70, width: 70,
                              isRestaurant: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ]),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 100, right: AppSpacing.sm,
                    top: AppSpacing.sm, bottom: AppSpacing.sm,
                  ),
                  child: Row(children: [

                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                        Text(
                          restaurant.name ?? '',
                          style: AppTypography.titleSm(colors.ink),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),

                        Text(
                          restaurant.address ?? '',
                          style: AppTypography.bodySm(colors.inkMuted),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),

                      ]),
                    ),
                    const SizedBox(width: AppSpacing.sm),

                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xl),
                      decoration: BoxDecoration(
                        color: colors.accentSoft,
                        borderRadius: AppRadius.xsAll,
                      ),
                      child: Row(children: [

                        Icon(Icons.star, color: colors.rating, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Text(restaurant.avgRating!.toStringAsFixed(1), style: AppTypography.labelMd(colors.ink)),

                      ]),
                    ),

                  ]),
                ),

              ]),
            ),
          ),
        );
      },
    );
  }
}
