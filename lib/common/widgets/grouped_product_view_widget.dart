import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/common/widgets/no_data_screen_widget.dart';
import 'package:toto_user/common/widgets/product_widget.dart';
import 'package:toto_user/design_system/app_colors.dart';
import 'package:toto_user/design_system/app_typography.dart';
import 'package:toto_user/features/category/domain/models/category_model.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class GroupedProductViewWidget extends StatelessWidget {
  final List<Product?>? products;
  final List<CategoryModel>? categoryList;
  final Map<int, GlobalKey> categoryKeys;
  final bool inRestaurantPage;

  const GroupedProductViewWidget({
    super.key,
    required this.products,
    required this.categoryList,
    required this.categoryKeys,
    this.inRestaurantPage = false,
  });

  @override
  Widget build(BuildContext context) {
    // Wait only while initial fetch is pending.
    if (products == null) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
        child: Center(
          child: CircularProgressIndicator(
            color: Theme.of(context).primaryColor,
          ),
        ),
      );
    }

    // Restaurant has no food
    if (products!.isEmpty) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
        child: NoDataScreen(
          isEmptyFood: true,
          title: 'there_is_no_food'.tr,
        ),
      );
    }

    // No categories to group by — show a flat product list instead of blank UI.
    if (categoryList == null || categoryList!.isEmpty) {
      return _FlatProductList(
        products: products!,
        inRestaurantPage: inRestaurantPage,
      );
    }

    // Group products by category sections
    final Map<int, List<Product>> groupedProducts = {};
    final List<Product> uncategorized = [];
    for (var product in products!) {
      if (product == null) continue;
      if (product.categoryId != null) {
        final categoryId = product.categoryId!;
        groupedProducts.putIfAbsent(categoryId, () => []).add(product);
      } else {
        uncategorized.add(product);
      }
    }

    // Build list of categories in order, with their products
    final List<MapEntry<int, List<Product>>> categorySections = [];

    for (var category in categoryList!) {
      if (category.id != null && groupedProducts.containsKey(category.id)) {
        categorySections
            .add(MapEntry(category.id!, groupedProducts[category.id]!));
        groupedProducts.remove(category.id);
      }
    }
    // Any product categories not in restaurant categoryList still need a section.
    for (final entry in groupedProducts.entries) {
      categorySections.add(entry);
    }
    if (uncategorized.isNotEmpty) {
      categorySections.add(MapEntry(-1, uncategorized));
    }

    if (categorySections.isEmpty) {
      return _FlatProductList(
        products: products!,
        inRestaurantPage: inRestaurantPage,
      );
    }

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final crossAxisCount = ResponsiveHelper.isMobile(context) ? 1 : 3;
    final productHeight = isDesktop ? 142.0 : 150.0;
    final mainAxisSpacing =
        isDesktop ? Dimensions.paddingSizeLarge : Dimensions.paddingSizeSmall;

    return Column(
      children: [
        for (var i = 0; i < categorySections.length; i++) ...[
          Builder(builder: (context) {
            final entry = categorySections[i];
            final categoryId = entry.key;
            final categoryProducts = entry.value;

            final category = categoryId == -1
                ? CategoryModel(id: -1, name: 'items'.tr)
                : categoryList!.firstWhere(
                    (cat) => cat.id == categoryId,
                    orElse: () =>
                        CategoryModel(id: categoryId, name: 'Category'),
                  );

            if (!categoryKeys.containsKey(categoryId)) {
              categoryKeys[categoryId] = GlobalKey();
            }
            final categoryKey = categoryKeys[categoryId]!;

            return Column(
              key: categoryKey,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeDefault,
                    vertical: Dimensions.paddingSizeExtraSmall,
                  ),
                  child: Text(
                    category.name ?? 'Category',
                    style: AppTypography.displayMd(AppColors.of(context).ink)
                        .copyWith(
                      fontSize: isDesktop ? 22 : 18,
                      height: 1.2,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                _ProductGrid(
                  categoryId: categoryId,
                  categoryProducts: categoryProducts,
                  crossAxisCount: crossAxisCount,
                  mainAxisSpacing: mainAxisSpacing,
                  productHeight: productHeight,
                  crossAxisSpacing: Dimensions.paddingSizeLarge,
                  inRestaurantPage: inRestaurantPage,
                ),
                const SizedBox(height: Dimensions.paddingSizeSmall),
              ],
            );
          }),
        ],
      ],
    );
  }
}

class _FlatProductList extends StatelessWidget {
  final List<Product?> products;
  final bool inRestaurantPage;

  const _FlatProductList({
    required this.products,
    required this.inRestaurantPage,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);
    final items = products.whereType<Product>().toList();
    if (items.isEmpty) {
      return Padding(
        padding:
            const EdgeInsets.symmetric(vertical: Dimensions.paddingSizeLarge),
        child: NoDataScreen(
          isEmptyFood: true,
          title: 'there_is_no_food'.tr,
        ),
      );
    }
    return _ProductGrid(
      categoryId: 0,
      categoryProducts: items,
      crossAxisCount: ResponsiveHelper.isMobile(context) ? 1 : 3,
      mainAxisSpacing: isDesktop ? Dimensions.paddingSizeLarge : 0.01,
      productHeight: isDesktop ? 142.0 : 150.0,
      crossAxisSpacing: Dimensions.paddingSizeLarge,
      inRestaurantPage: inRestaurantPage,
    );
  }
}

/// Manual grid layout avoids GridView shrinkWrap/layout issues in nested scroll views.
class _ProductGrid extends StatelessWidget {
  final int categoryId;
  final List<Product> categoryProducts;
  final int crossAxisCount;
  final double mainAxisSpacing;
  final double productHeight;
  final double crossAxisSpacing;
  final bool inRestaurantPage;

  const _ProductGrid({
    required this.categoryId,
    required this.categoryProducts,
    required this.crossAxisCount,
    required this.mainAxisSpacing,
    required this.productHeight,
    required this.crossAxisSpacing,
    required this.inRestaurantPage,
  });

  @override
  Widget build(BuildContext context) {
    final rowCount = (categoryProducts.length / crossAxisCount).ceil();
    final padding = Dimensions.paddingSizeDefault;

    return Padding(
      key: ValueKey('category_$categoryId'),
      padding: EdgeInsets.only(
        left: padding,
        right: padding,
        top: Dimensions.paddingSizeExtraSmall,
        bottom: Dimensions.paddingSizeExtraSmall,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int row = 0; row < rowCount; row++) ...[
            if (row > 0) SizedBox(height: mainAxisSpacing),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int col = 0; col < crossAxisCount; col++) ...[
                  if (col > 0) SizedBox(width: crossAxisSpacing),
                  Expanded(
                    child: (row * crossAxisCount + col) <
                            categoryProducts.length
                        ? SizedBox(
                            height: productHeight,
                            child: ProductWidget(
                              isRestaurant: false,
                              product:
                                  categoryProducts[row * crossAxisCount + col],
                              restaurant: null,
                              index: row * crossAxisCount + col,
                              length: categoryProducts.length,
                              isCampaign: false,
                              inRestaurant: inRestaurantPage,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}
