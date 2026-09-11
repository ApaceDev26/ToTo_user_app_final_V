import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/not_available_widget.dart';
import 'package:toto_user/common/widgets/rating_bar_widget.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/product_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/util/styles.dart';

class HorizontalFoodCard extends StatelessWidget {
  const HorizontalFoodCard({
    super.key,
    required this.productList,
    required this.index,
  });

  final List<Product>? productList;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 250,
      padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 1))
        ],
      ),
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                child: CustomImageWidget(
                  image: '${productList![index].imageFullUrl}',
                  height: 80,
                  width: 80,
                  fit: BoxFit.cover,
                  isFood: true,
                ),
              ),
              // Positioned(
              //   child: DiscountTagWidget(
              //     discount:
              //         ProductHelper.getDiscount(
              //             productList[index]),
              //     discountType: ProductHelper
              //         .getDiscountType(
              //             productList[index]),
              //   ),
              // ),
              ProductHelper.isAvailable(productList![index])
                  ? const SizedBox()
                  : const NotAvailableWidget(),
            ]),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: Dimensions.paddingSizeExtraSmall),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              productList![index].name!,
                              style: robotoMedium.copyWith(
                                  fontSize: Dimensions.fontSizeSmall),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(
                                width: Dimensions.paddingSizeExtraSmall),
                            (Get.find<SplashController>()
                                    .configModel!
                                    .toggleVegNonVeg!)
                                ? Image.asset(
                                    productList![index].veg == 0
                                        ? Images.nonVegImage
                                        : Images.vegImage,
                                    height: 10,
                                    width: 10,
                                    fit: BoxFit.contain,
                                  )
                                : const SizedBox(),
                          ]),
                      const SizedBox(height: Dimensions.paddingSizeExtraSmall),
                      Text(
                        productList![index].restaurantName!,
                        style: robotoMedium.copyWith(
                            fontSize: Dimensions.fontSizeExtraSmall,
                            color: Theme.of(context).disabledColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      RatingBarWidget(
                        rating: productList![index].avgRating,
                        size: 12,
                        ratingCount: productList![index].ratingCount,
                      ),
                      Row(children: [
                        Expanded(
                          child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                productList![index].discount! > 0
                                    ? Flexible(
                                        child: Text(
                                        PriceConverter.convertPrice(
                                            productList![index].price),
                                        style: robotoMedium.copyWith(
                                          fontSize:
                                              Dimensions.fontSizeExtraSmall,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error,
                                          decoration:
                                              TextDecoration.lineThrough,
                                        ),
                                      ))
                                    : const SizedBox(),
                                SizedBox(
                                    width: productList![index].discount! > 0
                                        ? Dimensions.paddingSizeExtraSmall
                                        : 0),
                                Text(
                                  PriceConverter.convertPrice(
                                    productList![index].price,
                                    discount: productList![index].discount,
                                    discountType:
                                        productList![index].discountType,
                                  ),
                                  style: robotoBold.copyWith(
                                      fontSize: Dimensions.fontSizeSmall),
                                ),
                              ]),
                        ),
                        Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).primaryColor),
                          child: const Icon(Icons.add,
                              size: 20, color: Colors.white),
                        ),
                      ]),
                    ]),
              ),
            ),
          ]),
    );
  }
}
