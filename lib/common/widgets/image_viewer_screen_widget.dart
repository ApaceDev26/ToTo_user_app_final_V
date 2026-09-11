import 'package:toto_user/common/models/product_model.dart';
import 'package:toto_user/features/product/controllers/product_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerScreenWidget extends StatefulWidget {
  final Product product;
  const ImageViewerScreenWidget({super.key, required this.product});

  @override
  State<ImageViewerScreenWidget> createState() => _ImageViewerScreenWidgetState();
}

class _ImageViewerScreenWidgetState extends State<ImageViewerScreenWidget> {
  @override
  Widget build(BuildContext context) {
    Get.find<ProductController>().setImageIndex(0, false);

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'product_images'.tr),
      body: SafeArea(
        child: GetBuilder<ProductController>(builder: (_) {
          return Column(children: [

            Expanded(
              child: PhotoView(
                imageProvider: NetworkImage('${widget.product.imageFullUrl}'),
                initialScale: PhotoViewComputedScale.contained,
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 2.5,
                strictScale: true,
                loadingBuilder: (context, event) => Center(
                  child: SizedBox(
                    width: 20.0,
                    height: 20.0,
                    child: CircularProgressIndicator(
                      value: event == null ? 0 : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
                    ),
                  ),
                ),
                backgroundDecoration: BoxDecoration(
                  color: ResponsiveHelper.isDesktop(context) ? Theme.of(context).canvasColor : Theme.of(context).cardColor,
                ),
                heroAttributes: const PhotoViewHeroAttributes(tag: 'product_image'),
              ),
            ),

          ]);
        }),
      ),
    );
  }
}