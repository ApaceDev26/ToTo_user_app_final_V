import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/home/widgets/cuisine_card_widget.dart';
import 'package:toto_user/features/cuisine/controllers/cuisine_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CuisineScreen extends StatefulWidget {
  const CuisineScreen({super.key});

  @override
  State<CuisineScreen> createState() => _CuisineScreenState();
}

class _CuisineScreenState extends State<CuisineScreen> {
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    Get.find<CuisineController>().getCuisineList();
  }
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: CustomAppBarWidget(title: 'cuisines'.tr),
      backgroundColor: colors.canvas,
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: SingleChildScrollView(
        controller: scrollController,
        child: Column(children: [

          SizedBox(height: ResponsiveHelper.isDesktop(context) ? 0 : AppSpacing.xl),
          WebScreenTitleWidget(title: 'cuisines'.tr),

          Center(child: FooterViewWidget(
            child: SizedBox(
              width: Dimensions.webMaxWidth,
              child: Column(children: [
                RefreshIndicator(
                  color: colors.accent,
                  backgroundColor: colors.surface,
                  onRefresh: () async {
                    await Get.find<CuisineController>().getCuisineList();
                  },
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: ResponsiveHelper.isDesktop(context) ? 0 : AppSpacing.lg,
                      right: ResponsiveHelper.isDesktop(context) ? 0 : AppSpacing.lg,
                    ),
                    child: GetBuilder<CuisineController>(builder: (cuisineController) {
                      return cuisineController.cuisineModel != null ? GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: ResponsiveHelper.isMobile(context) ? 4 : ResponsiveHelper.isDesktop(context) ? 8 : 6,
                          mainAxisSpacing: AppSpacing.lg,
                          crossAxisSpacing: ResponsiveHelper.isDesktop(context) ? 35 : AppSpacing.lg,
                          childAspectRatio: 1,
                        ),
                        shrinkWrap: true,
                        itemCount: cuisineController.cuisineModel!.cuisines!.length,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index){
                          return InkWell(
                            hoverColor: Colors.transparent,
                            onTap: (){
                              Get.toNamed(RouteHelper.getCuisineRestaurantRoute(cuisineController.cuisineModel!.cuisines![index].id, cuisineController.cuisineModel!.cuisines![index].name));
                            },
                            child: SizedBox(
                              height: 130,
                              child: CuisineCardWidget(
                                image: '${cuisineController.cuisineModel!.cuisines![index].imageFullUrl}',
                                name: cuisineController.cuisineModel!.cuisines![index].name!,
                                fromCuisinesPage: true,
                              ),
                            ),
                          );
                        }) : Center(
                          child: CircularProgressIndicator(
                            color: colors.accent,
                            backgroundColor: colors.accentSoft,
                          ),
                        );
                    }),
                  ),
                ),
              ]),
            ),
          )),
        ]),
      ),
    );
  }
}
