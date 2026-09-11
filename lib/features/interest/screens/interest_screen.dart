import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/interest/controllers/interest_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/common/widgets/custom_button_widget.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/no_data_screen_widget.dart';
import 'package:toto_user/common/widgets/web_menu_bar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class InterestScreen extends StatefulWidget {
  const InterestScreen({super.key});

  @override
  State<InterestScreen> createState() => _InterestScreenState();
}

class _InterestScreenState extends State<InterestScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    Get.find<InterestController>().getCategoryList(true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      backgroundColor: colors.canvas,
      appBar: ResponsiveHelper.isDesktop(context) ? const WebMenuBar() : null,
      endDrawer: const MenuDrawerWidget(), endDrawerEnableOpenDragGesture: false,
      body: SafeArea(
        child: GetBuilder<InterestController>(builder: (interestController) {
          return interestController.categoryList != null ? interestController.categoryList!.isNotEmpty ? Center(
            child: Container(
              width: Dimensions.webMaxWidth,
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: AppSpacing.xl),

                Text('choose_your_interests'.tr, style: AppTypography.titleLg(colors.ink)),
                const SizedBox(height: AppSpacing.sm),

                Text('get_personalized_recommendations'.tr, style: AppTypography.bodyMd(colors.inkMuted)),
                const SizedBox(height: AppSpacing.xl),

                Expanded(
                  child: GridView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    itemCount: interestController.categoryList!.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveHelper.isDesktop(context) ? 4 : ResponsiveHelper.isTab(context) ? 3 : 2,
                      childAspectRatio: (1/0.35),
                    ),
                    itemBuilder: (context, index) {
                      final selected = interestController.interestCategorySelectedList![index];
                      return InkWell(
                        onTap: () => interestController.addInterestSelection(index),
                        borderRadius: AppRadius.smAll,
                        child: Container(
                          margin: const EdgeInsets.all(AppSpacing.xs),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.xs, horizontal: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? colors.accent : colors.surface,
                            borderRadius: AppRadius.smAll,
                            border: Border.all(
                              color: selected ? colors.accent : colors.line,
                            ),
                            boxShadow: selected ? null : AppShadows.of(context, 1),
                          ),
                          alignment: Alignment.center,
                          child: Row(children: [
                            CustomImageWidget(
                              image: '${interestController.categoryList![index].imageFullUrl}',
                              height: 30, width: 30,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Flexible(child: Text(
                              interestController.categoryList![index].name!,
                              style: AppTypography.labelMd(
                                selected ? colors.onAccent : colors.ink,
                              ),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            )),
                          ]),
                        ),
                      );
                    },
                  ),
                ),

                CustomButtonWidget(
                  buttonText: 'save_and_continue'.tr,
                  isLoading: interestController.isLoading,
                  onPressed: () {
                    List<int?> interests = [];
                    for(int index=0; index<interestController.categoryList!.length; index++) {
                      if(interestController.interestCategorySelectedList![index]) {
                        interests.add(interestController.categoryList![index].id);
                      }
                    }
                    interestController.saveInterest(interests).then((isSuccess) {
                      if(isSuccess) {
                        Get.offAllNamed(RouteHelper.getInitialRoute());
                      }
                    });
                  },
                ),

              ]),
            ),
          ) : NoDataScreen(title: 'no_category_found'.tr) : Center(
            child: CircularProgressIndicator(
              color: colors.accent,
              backgroundColor: colors.accentSoft,
            ),
          );
        }),
      ),
    );
  }
}
