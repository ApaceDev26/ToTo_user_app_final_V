import 'package:toto_user/common/widgets/custom_ink_well_widget.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/category/controllers/category_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/no_data_screen_widget.dart';
import 'package:toto_user/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<CategoryController>().getCategoryList(false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: CustomAppBarWidget(title: 'categories'.tr),
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: scrollController, child: FooterViewWidget(
            child: Column(children: [
              WebScreenTitleWidget(title: 'categories'.tr),

              Center(child: SizedBox(
                width: Dimensions.webMaxWidth,
                child: GetBuilder<CategoryController>(builder: (catController) {
                  return catController.categoryList != null ? catController.categoryList!.isNotEmpty ? GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 6 : ResponsiveHelper.isTab(context) ? 4 : 3,
                      childAspectRatio: (1/1),
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    itemCount: catController.categoryList!.length,
                    itemBuilder: (context, index) {
                      return Container(
                        decoration: BoxDecoration(
                          color: colors.surface,
                          borderRadius: AppRadius.mdAll,
                          boxShadow: AppShadows.of(context, 1),
                        ),
                        child: CustomInkWellWidget(
                          onTap: () => Get.toNamed(RouteHelper.getCategoryProductRoute(
                            catController.categoryList![index].id, catController.categoryList![index].name!,
                          )),
                          radius: AppRadius.md,
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                            ClipRRect(
                              borderRadius: AppRadius.xsAll,
                              child: CustomImageWidget(
                                height: 50, width: 50, fit: BoxFit.cover,
                                image: '${catController.categoryList![index].imageFullUrl}',
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),

                            Text(
                              catController.categoryList![index].name!, textAlign: TextAlign.center,
                              style: AppTypography.labelMd(colors.ink),
                              maxLines: 2, overflow: TextOverflow.ellipsis,
                            ),

                          ]),
                        ),
                      );
                    },
                  ) : NoDataScreen(title: 'no_category_found'.tr) : const Center(child: CircularProgressIndicator());
                }),
              )),
            ],
          )),
        ),
      ),
    );
  }
}
