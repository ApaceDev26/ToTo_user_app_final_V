import 'dart:convert';

import 'package:toto_user/api/api_client.dart';
import 'package:toto_user/api/local_client.dart';
import 'package:toto_user/common/enums/data_source_enum.dart';
import 'package:toto_user/features/notification/domain/models/notification_model.dart';
import 'package:toto_user/features/notification/domain/repository/notification_repository_interface.dart';
import 'package:toto_user/util/app_constants.dart';
import 'package:get/get_connect.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationRepository implements NotificationRepositoryInterface {
  final ApiClient apiClient;
  final SharedPreferences sharedPreferences;
  NotificationRepository(
      {required this.apiClient, required this.sharedPreferences});

  @override
  void saveSeenNotificationCount(int count) {
    sharedPreferences.setInt(AppConstants.notificationCount, count);
  }

  @override
  int? getSeenNotificationCount() {
    return sharedPreferences.getInt(AppConstants.notificationCount);
  }

  @override
  List<int> getNotificationIdList() {
    List<String>? list = [];
    if (sharedPreferences.containsKey(AppConstants.notificationIdList)) {
      list = sharedPreferences.getStringList(AppConstants.notificationIdList);
    }
    List<int> notificationIdList = [];
    for (var id in list!) {
      notificationIdList.add(jsonDecode(id));
    }
    return notificationIdList;
  }

  @override
  void addSeenNotificationIdList(List<int> notificationList) {
    List<String> list = [];
    for (int id in notificationList) {
      list.add(jsonEncode(id));
    }
    sharedPreferences.setStringList(AppConstants.notificationIdList, list);
  }

  @override
  Future add(value) {
    throw UnimplementedError();
  }

  @override
  Future delete(int? id) {
    throw UnimplementedError();
  }

  @override
  Future get(String? id) {
    throw UnimplementedError();
  }

  @override
  Future<List<NotificationModel>?> getList(
      {int? offset, DataSourceEnum? source}) async {
    List<NotificationModel>? notificationList;
    String cacheId = AppConstants.notificationUri;

    try {
      switch (source!) {
        case DataSourceEnum.client:
          Response response =
              await apiClient.getData(AppConstants.notificationUri);
          if (response.statusCode == 200 && response.body is List) {
            notificationList = [];
            for (final notification in response.body) {
              try {
                notificationList.add(NotificationModel.fromJson(
                    Map<String, dynamic>.from(notification)));
              } catch (_) {}
            }
            LocalClient.organize(DataSourceEnum.client, cacheId,
                jsonEncode(response.body), apiClient.getHeader());
          }
        case DataSourceEnum.local:
          String? cacheResponseData = await LocalClient.organize(
              DataSourceEnum.local, cacheId, null, null);
          if (cacheResponseData != null) {
            notificationList = [];
            final decoded = jsonDecode(cacheResponseData);
            if (decoded is List) {
              for (final notification in decoded) {
                try {
                  notificationList.add(NotificationModel.fromJson(
                      Map<String, dynamic>.from(notification)));
                } catch (_) {}
              }
            }
          }
      }
    } catch (_) {
      return notificationList;
    }
    return notificationList;
  }

  @override
  Future update(Map<String, dynamic> body, int? id) {
    throw UnimplementedError();
  }

  @override
  Future<bool> deleteNotification(int notificationId) async {
    // Since the backend doesn't support notification deletion,
    // we'll implement local-only deletion by storing deleted notification IDs
    List<int> deletedIds = getDeletedNotificationIds();
    if (!deletedIds.contains(notificationId)) {
      deletedIds.add(notificationId);
      await saveDeletedNotificationIds(deletedIds);
    }
    return true; // Always return true for local deletion
  }

  List<int> getDeletedNotificationIds() {
    List<String>? list = [];
    if (sharedPreferences.containsKey(AppConstants.deletedNotificationIds)) {
      list =
          sharedPreferences.getStringList(AppConstants.deletedNotificationIds);
    }
    List<int> deletedIds = [];
    for (var id in list!) {
      deletedIds.add(jsonDecode(id));
    }
    return deletedIds;
  }

  Future<void> saveDeletedNotificationIds(List<int> deletedIds) async {
    List<String> list = [];
    for (int id in deletedIds) {
      list.add(jsonEncode(id));
    }
    await sharedPreferences.setStringList(
        AppConstants.deletedNotificationIds, list);
  }
}
