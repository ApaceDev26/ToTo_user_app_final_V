import 'package:toto_user/common/widgets/custom_asset_image_widget.dart';
import 'package:toto_user/design_system/design_system.dart';
import 'package:toto_user/features/auth/controllers/auth_controller.dart';
import 'package:toto_user/features/notification/controllers/notification_controller.dart';
import 'package:toto_user/features/notification/widgets/add_fund_bottom_sheet.dart';
import 'package:toto_user/features/notification/widgets/notification_bottom_sheet.dart';
import 'package:toto_user/features/notification/widgets/notification_dialog_widget.dart';
import 'package:toto_user/features/profile/controllers/profile_controller.dart';
import 'package:toto_user/features/splash/controllers/splash_controller.dart';
import 'package:toto_user/helper/date_converter.dart';
import 'package:toto_user/helper/responsive_helper.dart';
import 'package:toto_user/helper/route_helper.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:toto_user/util/dimensions.dart';
import 'package:toto_user/util/images.dart';
import 'package:toto_user/common/widgets/custom_app_bar_widget.dart';
import 'package:toto_user/common/widgets/custom_image_widget.dart';
import 'package:toto_user/common/widgets/footer_view_widget.dart';
import 'package:toto_user/common/widgets/menu_drawer_widget.dart';
import 'package:toto_user/common/widgets/no_data_screen_widget.dart';
import 'package:toto_user/common/widgets/not_logged_in_screen.dart';
import 'package:toto_user/common/widgets/web_page_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationScreen extends StatefulWidget {
  final bool fromNotification;
  const NotificationScreen({super.key, this.fromNotification = false});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final ScrollController scrollController = ScrollController();

  void _loadData() async {
    final notificationController = Get.find<NotificationController>();
    if (Get.find<SplashController>().configModel == null) {
      await Get.find<SplashController>().getConfigData();
    }
    final isLoggedIn = Get.find<AuthController>().isLoggedIn();
    if (isLoggedIn) {
      await notificationController.getNotificationList(true);
      if (Get.find<ProfileController>().userInfoModel?.walletBalance == null) {
        await Get.find<ProfileController>().getUserInfo();
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadData();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return PopScope(
      canPop: Navigator.canPop(context),
      onPopInvokedWithResult: (didPop, result) async {
        if (widget.fromNotification) {
          Get.offAllNamed(RouteHelper.getInitialRoute());
        } else {
          return;
        }
      },
      child: Scaffold(
        backgroundColor: colors.canvas,
        appBar: CustomAppBarWidget(
            title: 'notification'.tr,
            onBackPressed: () {
              if (widget.fromNotification) {
                Get.offAllNamed(RouteHelper.getInitialRoute());
              } else {
                Get.back();
              }
            }),
        endDrawer: const MenuDrawerWidget(),
        endDrawerEnableOpenDragGesture: false,
        body: Get.find<AuthController>().isLoggedIn()
            ? GetBuilder<NotificationController>(
                builder: (notificationController) {
                final list = notificationController.notificationList;
                if (list != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    notificationController
                        .saveSeenNotificationCount(list.length);
                  });
                }
                List<DateTime> dateTimeList = [];
                return list != null
                    ? list.isNotEmpty
                        ? RefreshIndicator(
                            color: colors.accent,
                            onRefresh: () async {
                              await notificationController
                                  .getNotificationList(true);
                            },
                            child: SingleChildScrollView(
                              controller: scrollController,
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: FooterViewWidget(
                                child: Column(
                                  children: [
                                    WebScreenTitleWidget(
                                        title: 'notification'.tr),
                                    Center(
                                        child: SizedBox(
                                            width: Dimensions.webMaxWidth,
                                            child: ListView.builder(
                                              itemCount: notificationController
                                                  .notificationList!.length,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemBuilder: (context, index) {
                                                DateTime originalDateTime =
                                                    DateConverter
                                                        .dateTimeStringToDate(
                                                            notificationController
                                                                .notificationList![
                                                                    index]
                                                                .createdAt!);
                                                DateTime convertedDate =
                                                    DateTime(
                                                        originalDateTime.year,
                                                        originalDateTime.month,
                                                        originalDateTime.day);
                                                bool addTitle = false;
                                                if (!dateTimeList
                                                    .contains(convertedDate)) {
                                                  addTitle = true;
                                                  dateTimeList
                                                      .add(convertedDate);
                                                }
                                                bool isSeen = notificationController
                                                    .getSeenNotificationIdList()
                                                    .contains(
                                                        notificationController
                                                            .notificationList![
                                                                index]
                                                            .id);

                                                return Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      addTitle
                                                          ? Padding(
                                                              padding: const EdgeInsets
                                                                  .symmetric(
                                                                  vertical:
                                                                      AppSpacing
                                                                          .xl,
                                                                  horizontal:
                                                                      AppSpacing
                                                                          .xl),
                                                              child: Text(
                                                                DateConverter.dateTimeStringToDateOnly(
                                                                    notificationController
                                                                        .notificationList![
                                                                            index]
                                                                        .createdAt!),
                                                                style: AppTypography
                                                                    .labelLg(
                                                                        colors
                                                                            .ink),
                                                              ),
                                                            )
                                                          : const SizedBox(),
                                                      Dismissible(
                                                        key: Key(
                                                            notificationController
                                                                .notificationList![
                                                                    index]
                                                                .id
                                                                .toString()),
                                                        direction:
                                                            DismissDirection
                                                                .endToStart,
                                                        confirmDismiss:
                                                            (direction) async {
                                                          return await showDialog(
                                                            context: context,
                                                            builder:
                                                                (BuildContext
                                                                    context) {
                                                              return AlertDialog(
                                                                backgroundColor:
                                                                    colors
                                                                        .surface,
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius:
                                                                        AppRadius
                                                                            .lgAll),
                                                                title: Text(
                                                                    'Delete Notification'
                                                                        .tr,
                                                                    style: AppTypography
                                                                        .titleSm(
                                                                            colors.ink)),
                                                                content: Text(
                                                                    'Are you sure you want to delete this notification?'
                                                                        .tr,
                                                                    style: AppTypography
                                                                        .bodyMd(
                                                                            colors.inkMuted)),
                                                                actions: [
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(false),
                                                                    child: Text(
                                                                        'cancel'
                                                                            .tr,
                                                                        style: AppTypography.labelLg(
                                                                            colors.inkMuted)),
                                                                  ),
                                                                  TextButton(
                                                                    onPressed: () =>
                                                                        Navigator.of(context)
                                                                            .pop(true),
                                                                    child: Text(
                                                                        'delete'
                                                                            .tr,
                                                                        style: AppTypography.labelLg(
                                                                            colors.danger)),
                                                                  ),
                                                                ],
                                                              );
                                                            },
                                                          );
                                                        },
                                                        onDismissed:
                                                            (direction) async {
                                                          bool success = await notificationController
                                                              .deleteNotification(
                                                                  notificationController
                                                                      .notificationList![
                                                                          index]
                                                                      .id!);
                                                          if (!success) {
                                                            // Show error message if deletion failed
                                                            Get.snackbar(
                                                                'error'.tr,
                                                                'failed_to_delete_notification'
                                                                    .tr);
                                                          }
                                                        },
                                                        background: Container(
                                                          alignment: Alignment
                                                              .centerRight,
                                                          padding: const EdgeInsets
                                                              .only(
                                                              right: AppSpacing
                                                                  .xl),
                                                          color: colors.danger,
                                                          child: Icon(
                                                              Icons.delete,
                                                              color: colors
                                                                  .onAccent),
                                                        ),
                                                        child: InkWell(
                                                          onTap: () {
                                                            notificationController
                                                                .addSeenNotificationId(
                                                                    notificationController
                                                                        .notificationList![
                                                                            index]
                                                                        .id!);

                                                            if (notificationController.notificationList![index].data!.type == 'push_notification' ||
                                                                notificationController
                                                                        .notificationList![
                                                                            index]
                                                                        .data!
                                                                        .type ==
                                                                    'referral_code' ||
                                                                notificationController
                                                                        .notificationList![
                                                                            index]
                                                                        .data!
                                                                        .type ==
                                                                    'referral_earn') {
                                                              ResponsiveHelper
                                                                      .isDesktop(
                                                                          context)
                                                                  ? showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (BuildContext
                                                                              context) {
                                                                        return NotificationDialogWidget(
                                                                            notificationModel:
                                                                                notificationController.notificationList![index]);
                                                                      })
                                                                  : showModalBottomSheet(
                                                                      isScrollControlled:
                                                                          true,
                                                                      useRootNavigator:
                                                                          true,
                                                                      context: Get
                                                                          .context!,
                                                                      backgroundColor:
                                                                          colors
                                                                              .surface,
                                                                      shape:
                                                                          const RoundedRectangleBorder(
                                                                        borderRadius:
                                                                            AppRadius.sheetTop,
                                                                      ),
                                                                      builder:
                                                                          (context) {
                                                                        return ConstrainedBox(
                                                                          constraints:
                                                                              BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
                                                                          child:
                                                                              NotificationBottomSheet(notificationModel: notificationController.notificationList![index]),
                                                                        );
                                                                      },
                                                                    );
                                                            } else if (notificationController
                                                                    .notificationList![
                                                                        index]
                                                                    .data!
                                                                    .type ==
                                                                'order_status') {
                                                              if (notificationController
                                                                          .notificationList![
                                                                              index]
                                                                          .data!
                                                                          .orderStatus ==
                                                                      AppConstants
                                                                          .pickedUp ||
                                                                  notificationController
                                                                          .notificationList![
                                                                              index]
                                                                          .data!
                                                                          .orderStatus ==
                                                                      AppConstants
                                                                          .handover) {
                                                                Get.toNamed(RouteHelper.getOrderTrackingRoute(
                                                                    notificationController
                                                                        .notificationList![
                                                                            index]
                                                                        .data!
                                                                        .orderId!,
                                                                    null));
                                                              } else {
                                                                Get.toNamed(RouteHelper.getOrderDetailsRoute(
                                                                    notificationController
                                                                        .notificationList![
                                                                            index]
                                                                        .data!
                                                                        .orderId!,
                                                                    fromGuestTrack:
                                                                        true));
                                                              }
                                                            } else if (notificationController
                                                                    .notificationList![
                                                                        index]
                                                                    .data!
                                                                    .type ==
                                                                'add_fund') {
                                                              ResponsiveHelper
                                                                      .isMobile(
                                                                          context)
                                                                  ? Get
                                                                      .bottomSheet(
                                                                      AddFundBottomSheet(
                                                                          notificationModel:
                                                                              notificationController.notificationList![index]),
                                                                      backgroundColor:
                                                                          Colors
                                                                              .transparent,
                                                                      isScrollControlled:
                                                                          true,
                                                                    )
                                                                  : Get.dialog(
                                                                      Dialog(
                                                                          child:
                                                                              AddFundBottomSheet(notificationModel: notificationController.notificationList![index])),
                                                                    );
                                                            }
                                                          },
                                                          child: Container(
                                                            color: isSeen
                                                                ? colors.surface
                                                                : colors
                                                                    .accentSoft
                                                                    .withValues(
                                                                        alpha:
                                                                            0.55),
                                                            padding: const EdgeInsets
                                                                .symmetric(
                                                                vertical:
                                                                    AppSpacing
                                                                        .xl,
                                                                horizontal:
                                                                    AppSpacing
                                                                        .xl),
                                                            child: Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  CustomAssetImageWidget(
                                                                    notificationController.notificationList![index].data!.type ==
                                                                            'push_notification'
                                                                        ? Images
                                                                            .pushNotificationIcon
                                                                        : notificationController.notificationList![index].data!.type ==
                                                                                'referral_code'
                                                                            ? Images.referPersonIcon
                                                                            : notificationController.notificationList![index].data!.type == 'referral_earn'
                                                                                ? Images.referEarnIcon
                                                                                : notificationController.notificationList![index].data!.orderStatus == AppConstants.pickedUp || notificationController.notificationList![index].data!.orderStatus == AppConstants.handover
                                                                                    ? Images.orderOnTheWaYIcon
                                                                                    : Images.orderConfirmIcon,
                                                                    height: 34,
                                                                    width: 34,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                  const SizedBox(
                                                                      width: AppSpacing
                                                                          .sm),
                                                                  Expanded(
                                                                      child: Column(
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start,
                                                                          children: [
                                                                        Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  notificationController.notificationList![index].data!.title ?? '',
                                                                                  maxLines: 1,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: AppTypography.labelLg(
                                                                                    isSeen ? colors.inkMuted : colors.ink,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              Padding(
                                                                                padding: const EdgeInsets.only(left: AppSpacing.sm),
                                                                                child: Text(
                                                                                  DateConverter.dateTimeStringToFormattedTime(notificationController.notificationList![index].createdAt!),
                                                                                  style: AppTypography.bodySm(
                                                                                    isSeen ? colors.inkFaint : colors.inkMuted,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ]),
                                                                        const SizedBox(
                                                                            height:
                                                                                AppSpacing.xs),
                                                                        Row(
                                                                            crossAxisAlignment:
                                                                                CrossAxisAlignment.start,
                                                                            children: [
                                                                              Expanded(
                                                                                child: Text(
                                                                                  notificationController.notificationList![index].data!.description ?? '',
                                                                                  maxLines: 2,
                                                                                  overflow: TextOverflow.ellipsis,
                                                                                  style: AppTypography.bodyMd(
                                                                                    isSeen ? colors.inkFaint : colors.inkMuted,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(width: AppSpacing.sm),

                                                                              notificationController.notificationList![index].data!.type == 'push_notification'
                                                                                  ? ClipRRect(
                                                                                      borderRadius: AppRadius.smAll,
                                                                                      child: CustomImageWidget(
                                                                                        placeholder: Images.placeholderPng,
                                                                                        image: '${notificationController.notificationList![index].imageFullUrl}',
                                                                                        height: 45,
                                                                                        width: 75,
                                                                                        fit: BoxFit.cover,
                                                                                      ),
                                                                                    )
                                                                                  : const SizedBox.shrink(),

                                                                              const SizedBox(width: AppSpacing.sm),

                                                                              // Delete button
                                                                              InkWell(
                                                                                onTap: () async {
                                                                                  bool? shouldDelete = await showDialog(
                                                                                    context: context,
                                                                                    builder: (BuildContext context) {
                                                                                      return AlertDialog(
                                                                                        backgroundColor: colors.surface,
                                                                                        shape: RoundedRectangleBorder(
                                                                                            borderRadius: AppRadius.lgAll),
                                                                                        title: Text('Delete Notification'.tr,
                                                                                            style: AppTypography.titleSm(colors.ink)),
                                                                                        content: Text('Are you sure you want to delete this notification?'.tr,
                                                                                            style: AppTypography.bodyMd(colors.inkMuted)),
                                                                                        actions: [
                                                                                          TextButton(
                                                                                            onPressed: () => Navigator.of(context).pop(false),
                                                                                            child: Text('cancel'.tr,
                                                                                                style: AppTypography.labelLg(colors.inkMuted)),
                                                                                          ),
                                                                                          TextButton(
                                                                                            onPressed: () => Navigator.of(context).pop(true),
                                                                                            child: Text('delete'.tr,
                                                                                                style: AppTypography.labelLg(colors.danger)),
                                                                                          ),
                                                                                        ],
                                                                                      );
                                                                                    },
                                                                                  );

                                                                                  if (shouldDelete == true) {
                                                                                    bool success = await notificationController.deleteNotification(notificationController.notificationList![index].id!);
                                                                                    if (!success) {
                                                                                      Get.snackbar('error'.tr, 'failed_to_delete_notification'.tr);
                                                                                    }
                                                                                  }
                                                                                },
                                                                                child: Container(
                                                                                  padding: const EdgeInsets.all(AppSpacing.sm),
                                                                                  decoration: BoxDecoration(
                                                                                    color: colors.danger.withValues(alpha: 0.1),
                                                                                    borderRadius: AppRadius.smAll,
                                                                                  ),
                                                                                  child: Icon(
                                                                                    Icons.delete_outline,
                                                                                    color: colors.danger,
                                                                                    size: AppIcons.sm,
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ]),
                                                                      ])),
                                                                ]),
                                                          ),
                                                        ),
                                                      ),
                                                      Container(
                                                          height: 0.8,
                                                          color: colors.line),
                                                    ]);
                                              },
                                            ))),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : NoDataScreen(
                            title: 'no_notification'.tr,
                            isEmptyNotification: true)
                    : Center(
                        child: SizedBox(
                          height: 28,
                          width: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.accent,
                          ),
                        ),
                      );
              })
            : NotLoggedInScreen(callBack: (value) {
                _loadData();
                setState(() {});
              }),
      ),
    );
  }
}
