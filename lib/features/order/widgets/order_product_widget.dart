import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/order/domain/models/order_details_model.dart';
import 'package:toto_user/features/order/domain/models/order_model.dart';
import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/helper/price_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OrderProductWidget extends StatelessWidget {
  final OrderModel order;
  final OrderDetailsModel orderDetails;
  final int? itemLength;
  final int? index;
  const OrderProductWidget({
    super.key,
    required this.order,
    required this.orderDetails,
    this.itemLength,
    this.index,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    String addOnText = '';
    for (var addOn in orderDetails.addOns!) {
      addOnText =
          '$addOnText${(addOnText.isEmpty) ? '' : ',  '}${addOn.name} (${addOn.quantity})';
    }

    String? variationText = '';
    if (orderDetails.variation!.isNotEmpty) {
      for (Variation variation in orderDetails.variation!) {
        variationText =
            '${variationText!}${variationText.isNotEmpty ? ', ' : ''}${variation.name} (';
        for (VariationValue value in variation.variationValues!) {
          variationText =
              '${variationText!}${variationText.endsWith('(') ? '' : ', '}${value.level}';
        }
        variationText = '${variationText!})';
      }
    } else if (orderDetails.oldVariation!.isNotEmpty) {
      List<String> variationTypes =
          orderDetails.oldVariation![0].type!.split('-');
      if (variationTypes.length ==
          orderDetails.foodDetails!.choiceOptions!.length) {
        int i = 0;
        for (var choice in orderDetails.foodDetails!.choiceOptions!) {
          variationText =
              '${variationText!}${(i == 0) ? '' : ',  '}${choice.title} - ${variationTypes[i]}';
          i = i + 1;
        }
      } else {
        variationText = orderDetails.oldVariation![0].type;
      }
    }

    final hasImage = orderDetails.foodDetails!.imageFullUrl != null &&
        orderDetails.foodDetails!.imageFullUrl!.isNotEmpty;
    final isLast = !ResponsiveHelper.isDesktop(context) &&
        index != null &&
        itemLength != null &&
        index == itemLength! - 1;

    return Container(
      color: colors.surface,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: ClipRRect(
                    borderRadius: AppRadius.smAll,
                    child: CustomImageWidget(
                      height: 72,
                      width: 72,
                      fit: BoxFit.cover,
                      image: '${orderDetails.foodDetails!.imageFullUrl}',
                      isFood: true,
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            orderDetails.foodDetails!.name!,
                            style: AppTypography.titleSm(colors.ink),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          '×${orderDetails.quantity}',
                          style: AppTypography.labelMd(colors.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      PriceConverter.convertPrice(orderDetails.price),
                      style: AppTypography.labelMd(colors.ink),
                      textDirection: TextDirection.ltr,
                    ),
                    if (addOnText.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${'addons'.tr}: $addOnText',
                        style: AppTypography.bodySm(colors.inkMuted),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          if (variationText != '' &&
              orderDetails.foodDetails!.variations != null &&
              orderDetails.foodDetails!.variations!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(left: hasImage ? 84 : 0, top: AppSpacing.xs),
              child: Text(
                '${'variations'.tr}: $variationText',
                style: AppTypography.bodySm(colors.inkMuted),
              ),
            ),
          if (!isLast) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: colors.line),
          ],
        ],
      ),
    );
  }
}
