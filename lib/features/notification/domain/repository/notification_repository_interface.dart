import 'package:toto_user/common/enums/data_source_enum.dart';
import 'package:toto_user/features/notification/domain/models/notification_model.dart';
import 'package:toto_user/interface/repository_interface.dart';

abstract class NotificationRepositoryInterface extends RepositoryInterface {
  @override
  Future<List<NotificationModel>?> getList(
      {int? offset, DataSourceEnum? source});
  void saveSeenNotificationCount(int count);
  int? getSeenNotificationCount();
  List<int> getNotificationIdList();
  void addSeenNotificationIdList(List<int> notificationList);
  Future<bool> deleteNotification(int notificationId);
  List<int> getDeletedNotificationIds();
  Future<void> saveDeletedNotificationIds(List<int> deletedIds);
}
