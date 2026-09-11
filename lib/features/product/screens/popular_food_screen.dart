import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/restaurant/controllers/restaurant_controller.dart';
import 'package:toto_user/features/product/controllers/product_controller.dart';
import 'package:toto_user/features/review/controllers/review_controller.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/product_view_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PopularFoodScreen extends StatefulWidget {
  final bool isPopular;
  final bool fromIsRestaurantFood;
  final int? restaurantId;
  const PopularFoodScreen({super.key, required this.isPopular, required this.fromIsRestaurantFood, this.restaurantId});

  @override
  State<PopularFoodScreen> createState() => _PopularFoodScreenState();
}

class _PopularFoodScreenState extends State<PopularFoodScreen> {
  final ScrollController scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  List<Product>? _filteredProducts(List<Product>? products) {
    if (products == null) return null;
    if (_searchQuery.isEmpty) return products;
    final query = _searchQuery.toLowerCase();
    return products
        .where((product) => (product.name ?? '').toLowerCase().contains(query))
        .toList();
  }

  @override
  void initState() {
    super.initState();

    if(widget.isPopular) {
      Get.find<ProductController>().getPopularProductList(true, Get.find<ProductController>().popularType, false);
    } else if(widget.fromIsRestaurantFood) {
      Get.find<RestaurantController>().getRestaurantRecommendedItemList(widget.restaurantId, false);
    } else {
      Get.find<ReviewController>().getReviewedProductList(true, Get.find<ReviewController>().reviewType, false);
    }
  }
  @override
  Widget build(BuildContext context) {

    return GetBuilder<ProductController>(builder: (productController) {
      return GetBuilder<ReviewController>(builder: (reviewController) {
        return Scaffold(
          appBar: CustomAppBarWidget(
            title: widget.isPopular ? widget.fromIsRestaurantFood? 'popular_in_this_restaurant'.tr : 'popular_foods_nearby'.tr : 'best_reviewed_food'.tr,
            showCart: true,
            type: widget.isPopular ? productController.popularType : reviewController.reviewType,
            onVegFilterTap: widget.fromIsRestaurantFood ? null : (String type) {
              if(widget.isPopular) {
                productController.getPopularProductList(true, type, true);
              }else {
                reviewController.getReviewedProductList(true, type, true);
              }
            },
          ),
          endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
          body: SingleChildScrollView(controller: scrollController, child: FooterViewWidget(
            child: Center(child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: GetBuilder<ProductController>(builder: (productController) {
                return GetBuilder<RestaurantController>(
                  builder: (restaurantController) {

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            Dimensions.paddingSizeDefault,
                            Dimensions.paddingSizeSmall,
                            Dimensions.paddingSizeDefault,
                            0,
                          ),
                          child: AppSearchBar(
                            controller: _searchController,
                            hint: 'search'.tr,
                            onChanged: (value) {
                              setState(() {
                                _searchQuery = value.trim();
                              });
                            },
                          ),
                        ),
                        ProductViewWidget(
                          isRestaurant: false, restaurants: null,
                          products: _filteredProducts(
                            widget.isPopular ? productController.popularProductList : widget.fromIsRestaurantFood ? restaurantController.recommendedProductModel?.products : reviewController.reviewedProductList,
                          ),
                          padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
                        ),
                      ],
                    );
                  }
                );
              }),
            )),
          )),
        );
      });
    });
  }
}
