import 'package:toto_user/common/widgets/not_logged_in_screen.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/address/controllers/address_controller.dart';
import 'package:toto_user/features/address/widgets/address_confirmation_dialogue_widget.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/custom_snackbar_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/no_data_screen_widget.dart';
import 'package:toto_user/common/widgets/web_page_title_widget.dart';
import 'package:toto_user/features/address/widgets/address_card_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _initCall();
  }

  void _initCall() {
    if (Get.find<AuthController>().isLoggedIn()) {
      Get.find<AddressController>().getAddressList();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isLoggedIn = Get.find<AuthController>().isLoggedIn();
    final colors = AppColors.of(context);

    return GetBuilder<AddressController>(builder: (addressController) {
      return Scaffold(
        backgroundColor: colors.canvas,
        appBar: CustomAppBarWidget(title: 'my_address'.tr),
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        floatingActionButton: ResponsiveHelper.isDesktop(context) || !isLoggedIn
            ? null
            : (addressController.addressList?.isEmpty ?? true)
                ? null
                : FloatingActionButton(
                    backgroundColor: colors.accent,
                    onPressed: () =>
                        Get.toNamed(RouteHelper.getAddAddressRoute(false, 0)),
                    child: Icon(Icons.add, color: colors.onAccent),
                  ),
        floatingActionButtonLocation: ResponsiveHelper.isDesktop(context)
            ? FloatingActionButtonLocation.centerFloat
            : null,
        body: GetBuilder<AddressController>(builder: (addressController) {
          return isLoggedIn
              ? RefreshIndicator(
                  color: colors.accent,
                  onRefresh: () async {
                    await addressController.getAddressList();
                  },
                  child: Container(
                    height: context.height,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: addressController.addressList != null
                            ? AssetImage(
                                addressController.addressList!.isNotEmpty
                                    ? Images.city
                                    : Images.cityWhite)
                            : const AssetImage(Images.city),
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                    child: SingleChildScrollView(
                      controller: scrollController,
                      physics: const BouncingScrollPhysics(),
                      child: Column(children: [
                        WebScreenTitleWidget(title: 'address'.tr),
                        Center(
                            child: FooterViewWidget(
                          child: SizedBox(
                            width: Dimensions.webMaxWidth,
                            child: Column(children: [
                              ResponsiveHelper.isDesktop(context)
                                  ? const SizedBox(
                                      height: AppSpacing.xl)
                                  : const SizedBox(),
                              addressController.addressList != null
                                  ? addressController.addressList!.isNotEmpty
                                      ? Padding(
                                          padding: ResponsiveHelper.isMobile(
                                                  context)
                                              ? const EdgeInsets.all(
                                                  AppSpacing.sm)
                                              : EdgeInsets.zero,
                                          child: GridView.builder(
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisSpacing:
                                                  AppSpacing.xl,
                                              mainAxisSpacing: ResponsiveHelper
                                                      .isDesktop(context)
                                                  ? AppSpacing.sm
                                                  : 0.01,
                                              childAspectRatio:
                                                  ResponsiveHelper.isDesktop(
                                                          context)
                                                      ? 4
                                                      : 5,
                                              crossAxisCount:
                                                  ResponsiveHelper.isMobile(
                                                          context)
                                                      ? 1
                                                      : ResponsiveHelper.isTab(
                                                              context)
                                                          ? 2
                                                          : 3,
                                            ),
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            padding: EdgeInsets.all(
                                                ResponsiveHelper.isTab(context)
                                                    ? AppSpacing.sm
                                                    : 0),
                                            shrinkWrap: true,
                                            itemCount:
                                                ResponsiveHelper.isDesktop(
                                                        context)
                                                    ? (addressController
                                                            .addressList!
                                                            .length +
                                                        1)
                                                    : addressController
                                                        .addressList!.length,
                                            itemBuilder: (context, index) {
                                              return (ResponsiveHelper
                                                          .isDesktop(context) &&
                                                      (index ==
                                                          addressController
                                                              .addressList!
                                                              .length))
                                                  ? Padding(
                                                      padding: const EdgeInsets
                                                          .only(
                                                          bottom: AppSpacing.sm),
                                                      child: InkWell(
                                                        onTap: () => Get
                                                            .toNamed(RouteHelper
                                                                .getAddAddressRoute(
                                                                    false, 0)),
                                                        child: Container(
                                                          padding: const EdgeInsets
                                                              .all(AppSpacing.sm),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: colors.surface,
                                                            borderRadius:
                                                                AppRadius.mdAll,
                                                            boxShadow: AppShadows.of(context, 2),
                                                          ),
                                                          child: Column(
                                                              crossAxisAlignment:
                                                                  CrossAxisAlignment
                                                                      .start,
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .add_circle_outline,
                                                                    color: colors.accent),
                                                                const SizedBox(
                                                                    height: AppSpacing.sm),
                                                                Text(
                                                                    'add_new_address'
                                                                        .tr,
                                                                    style: AppTypography.bodySm(colors.accent)),
                                                              ]),
                                                        ),
                                                      ),
                                                    )
                                                  : AddressCardWidget(
                                                      address: addressController
                                                          .addressList![index],
                                                      fromAddress: true,
                                                      onTap: () {
                                                        Get.toNamed(RouteHelper
                                                            .getMapRoute(
                                                          addressController
                                                                  .addressList![
                                                              index],
                                                          'address',
                                                        ));
                                                      },
                                                      onEditPressed: () {
                                                        Get.toNamed(RouteHelper
                                                            .getEditAddressRoute(
                                                                addressController
                                                                        .addressList![
                                                                    index]));
                                                      },
                                                      onRemovePressed: () {
                                                        if (Get
                                                            .isSnackbarOpen) {
                                                          Get.back();
                                                        }
                                                        Get.dialog(
                                                            AddressConfirmDialogueWidget(
                                                          icon: Images
                                                              .locationConfirm,
                                                          title:
                                                              'are_you_sure'.tr,
                                                          description:
                                                              'you_want_to_delete_this_location'
                                                                  .tr,
                                                          onYesPressed: () {
                                                            addressController
                                                                .deleteAddress(
                                                                    addressController
                                                                        .addressList![
                                                                            index]
                                                                        .id,
                                                                    index)
                                                                .then(
                                                                    (response) {
                                                              Get.back();
                                                              showCustomSnackBar(
                                                                  response
                                                                      .message,
                                                                  isError: !response
                                                                      .isSuccess);
                                                            });
                                                          },
                                                        ));
                                                      },
                                                    );
                                            },
                                          ),
                                        )
                                      : NoDataScreen(
                                          title: 'no_address_found'.tr,
                                          isEmptyAddress: true,
                                          fromAddress: true)
                                  : Center(
                                      child: Padding(
                                      padding: EdgeInsets.only(
                                          top: context.height * 0.4),
                                      child: CircularProgressIndicator(),
                                    )),
                            ]),
                          ),
                        )),
                      ]),
                    ),
                  ),
                )
              : NotLoggedInScreen(callBack: (value) {
                  _initCall();
                  setState(() {});
                });
        }),
      );
    });
  }
}
