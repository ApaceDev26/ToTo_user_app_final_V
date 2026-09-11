import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/features/home/widgets/new_item_card_widget.dart';
import 'package:flutter/material.dart';

/// Thin delegate — Lumen Atelier presentation lives in [NewItemCardWidget].
class New2ItemCardWidget extends StatelessWidget {
  final Product product;
  final bool? isBestItem;
  final bool? isPopularNearbyItem;
  final bool isCampaignItem;
  final double width;

  const New2ItemCardWidget({
    super.key,
    required this.product,
    this.isBestItem,
    this.isPopularNearbyItem = false,
    this.isCampaignItem = false,
    this.width = 190,
  });

  @override
  Widget build(BuildContext context) {
    return NewItemCardWidget(
      product: product,
      isBestItem: isBestItem,
      isPopularNearbyItem: isPopularNearbyItem,
      isCampaignItem: isCampaignItem,
      width: width,
    );
  }
}
