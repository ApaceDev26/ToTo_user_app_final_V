import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/custom_asset_image_widget.dart';
import 'package:toto_user/features/wallet/controllers/withdraw_controller.dart';
import 'package:toto_user/features/wallet/widgets/withdraw_widget.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/util/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class WithdrawHistoryScreen extends StatelessWidget {
  const WithdrawHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.find<WithdrawController>().getWithdrawList();

    return Scaffold(
      backgroundColor: Theme.of(context).cardColor,
      appBar: CustomAppBarWidget(
          title: 'withdraw_request_history'.tr,
          actions: [
            PopupMenuButton(
              itemBuilder: (context) {
                return <PopupMenuEntry>[
                  getMenuItem(
                      Get.find<WithdrawController>().statusList[0], context),
                  const PopupMenuDivider(),
                  getMenuItem(
                      Get.find<WithdrawController>().statusList[1], context),
                  const PopupMenuDivider(),
                  getMenuItem(
                      Get.find<WithdrawController>().statusList[2], context),
                  const PopupMenuDivider(),
                  getMenuItem(
                      Get.find<WithdrawController>().statusList[3], context),
                ];
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall)),
              offset: const Offset(-25, 25),
              child: Container(
                margin: const EdgeInsets.only(
                    right: Dimensions.paddingSizeSmall,
                    top: Dimensions.paddingSizeExtraSmall,
                    bottom: Dimensions.paddingSizeSmall),
                padding: const EdgeInsets.all(Dimensions.paddingSizeExtraSmall),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Dimensions.radiusSmall),
                  border: Border.all(
                      color:
                          Theme.of(context).hintColor.withValues(alpha: 0.2)),
                ),
                child: Icon(Icons.filter_list_outlined,
                    size: 25,
                    color: Theme.of(context).hintColor.withValues(alpha: 0.5)),
              ),
              onSelected: (dynamic value) {
                int index =
                    Get.find<WithdrawController>().statusList.indexOf(value);
                Get.find<WithdrawController>().filterWithdrawList(index);
              },
            ),
          ],
          onBackPressed: () {
            Get.find<WithdrawController>().filterWithdrawList(0);
            Get.back();
          }),
      body: GetBuilder<WithdrawController>(builder: (withdrawController) {
        if (withdrawController.isLoading &&
            withdrawController.withdrawList == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return withdrawController.withdrawList != null &&
                withdrawController.withdrawList!.isNotEmpty
            ? RefreshIndicator(
                onRefresh: () async {
                  await withdrawController.getWithdrawList();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: Dimensions.paddingSizeSmall),
                  child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: withdrawController.withdrawList!.length,
                    padding: const EdgeInsets.all(Dimensions.paddingSizeSmall),
                    itemBuilder: (context, index) {
                      return WithdrawWidget(
                        withdrawModel: withdrawController.withdrawList![index],
                        showDivider: index !=
                            withdrawController.withdrawList!.length - 1,
                      );
                    },
                  ),
                ),
              )
            : Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                    CustomAssetImageWidget(Images.emptyTransaction,
                        height: 50, width: 50),
                    const SizedBox(height: Dimensions.paddingSizeSmall),
                    Text('${'no_transaction_yet'.tr}!',
                        style: robotoMedium.copyWith(
                            color: Theme.of(context).hintColor)),
                  ]));
      }),
    );
  }

  PopupMenuItem getMenuItem(String status, BuildContext context) {
    return PopupMenuItem(
      value: status,
      height: 30,
      child: Text(status.toLowerCase().tr,
          style: robotoRegular.copyWith(
            color: status == 'Pending'
                ? const Color(0xff9DA7BC)
                : status == 'Approved'
                    ? const Color(0xff9DA7BC)
                    : status == 'Denied'
                        ? const Color(0xff9DA7BC)
                        : null,
            fontSize: Dimensions.fontSizeLarge,
          )),
    );
  }
}
