import 'package:toto_user/common/enums/data_source_enum.dart';
import 'package:toto_user/features/notification/domain/models/notification_model.dart';
import 'package:toto_user/features/notification/domain/repository/notification_repository_interface.dart';
import 'package:toto_user/features/notification/domain/service/notification_service_interface.dart';
import 'package:toto_user/helper/date_converter.dart';

class NotificationService implements NotificationServiceInterface {
  final NotificationRepositoryInterface notificationRepositoryInterface;
  NotificationService({required this.notificationRepositoryInterface});

  @override
  Future<List<NotificationModel>?> getList({DataSourceEnum? source}) async {
    List<NotificationModel>? notificationList =
        await notificationRepositoryInterface.getList(source: source);
    if (notificationList != null) {
      notificationList.sort((a, b) {
        final aDate = _parseNotificationDate(a.updatedAt ?? a.createdAt);
        final bDate = _parseNotificationDate(b.updatedAt ?? b.createdAt);
        return aDate.compareTo(bDate);
      });
      notificationList = notificationList.reversed.toList();
    }
    return notificationList;
  }

  DateTime _parseNotificationDate(String? value) {
    if (value == null || value.isEmpty) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }

    final parsed = DateTime.tryParse(value);
    if (parsed != null) {
      return parsed.toLocal();
    }

    try {
      return DateConverter.isoStringToLocalDate(value);
    } catch (_) {
      try {
        return DateConverter.dateTimeStringToDate(value);
      } catch (_) {
        return DateTime.fromMillisecondsSinceEpoch(0);
      }
    }
  }

  @override
  void saveSeenNotificationCount(int count) {
    return notificationRepositoryInterface.saveSeenNotificationCount(count);
  }

  @override
  int? getSeenNotificationCount() {
    return notificationRepositoryInterface.getSeenNotificationCount();
  }

  @override
  List<int> getNotificationIdList() {
    return notificationRepositoryInterface.getNotificationIdList();
  }

  @override
  void addSeenNotificationIdList(List<int> notificationList) {
    notificationRepositoryInterface.addSeenNotificationIdList(notificationList);
  }

  @override
  Future<bool> deleteNotification(int notificationId) async {
    return await notificationRepositoryInterface
        .deleteNotification(notificationId);
  }

  @override
  List<int> getDeletedNotificationIds() {
    return notificationRepositoryInterface.getDeletedNotificationIds();
  }

  @override
  Future<void> saveDeletedNotificationIds(List<int> deletedIds) async {
    await notificationRepositoryInterface
        .saveDeletedNotificationIds(deletedIds);
  }
}
