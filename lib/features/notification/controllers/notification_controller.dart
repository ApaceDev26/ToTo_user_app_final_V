import 'package:flutter/scheduler.dart';
import 'package:toto_user/common/enums/data_source_enum.dart';
import 'package:toto_user/features/notification/domain/models/notification_model.dart';
import 'package:toto_user/features/notification/domain/service/notification_service_interface.dart';
import 'package:get/get.dart';

class NotificationController extends GetxController implements GetxService {
  final NotificationServiceInterface notificationServiceInterface;
  NotificationController({required this.notificationServiceInterface});

  List<NotificationModel>? _notificationList;
  List<NotificationModel>? get notificationList => _notificationList;

  bool _hasNotification = false;
  bool get hasNotification => _hasNotification;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _fetchInFlight = false;

  /// Safe update — never during build.
  void _safeUpdate() {
    final phase = SchedulerBinding.instance.schedulerPhase;
    if (phase == SchedulerPhase.idle ||
        phase == SchedulerPhase.postFrameCallbacks) {
      update();
    } else {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (!isClosed) {
          update();
        }
      });
    }
  }

  Future<void> getNotificationList(bool reload,
      {DataSourceEnum dataSource = DataSourceEnum.local,
      bool fromRecall = false}) async {
    if (_fetchInFlight && !fromRecall) {
      return;
    }
    if (_notificationList != null && !reload && !fromRecall) {
      return;
    }

    if (!fromRecall) {
      _fetchInFlight = true;
      _isLoading = true;
      if (reload) {
        _notificationList = null;
      }
      _safeUpdate();
    }

    try {
      if (dataSource == DataSourceEnum.local) {
        final localList = await notificationServiceInterface.getList(
            source: DataSourceEnum.local);
        if (localList != null) {
          _applyNotificationList(localList);
        }

        await getNotificationList(false,
            dataSource: DataSourceEnum.client, fromRecall: true);
        return;
      }

      final remoteList = await notificationServiceInterface.getList(
          source: DataSourceEnum.client);
      if (remoteList != null) {
        _applyNotificationList(remoteList);
      } else if (_notificationList == null) {
        _notificationList = [];
        _hasNotification = false;
        _safeUpdate();
      }
    } catch (_) {
      if (_notificationList == null) {
        _notificationList = [];
        _hasNotification = false;
        _safeUpdate();
      }
    } finally {
      if (!fromRecall) {
        _isLoading = false;
        _fetchInFlight = false;
        if (_notificationList == null) {
          _notificationList = [];
          _hasNotification = false;
        }
        _safeUpdate();
      }
    }
  }

  void _applyNotificationList(List<NotificationModel> notificationList) {
    final deletedIds = getDeletedNotificationIds();
    _notificationList = notificationList
        .where((notification) => !deletedIds.contains(notification.id))
        .toList();

    final seenIds = getSeenNotificationIdList();
    final seenIdsExcludingDeleted =
        seenIds.where((id) => !deletedIds.contains(id)).toList();

    _hasNotification =
        _notificationList!.length != seenIdsExcludingDeleted.length;
    _safeUpdate();
  }

  void saveSeenNotificationCount(int count) {
    notificationServiceInterface.saveSeenNotificationCount(count);
  }

  int? getSeenNotificationCount() {
    return notificationServiceInterface.getSeenNotificationCount();
  }

  void clearNotification() {
    _notificationList = null;
    _hasNotification = false;
    _safeUpdate();
  }

  void addSeenNotificationId(int id) {
    final idList = <int>[
      ...notificationServiceInterface.getNotificationIdList(),
      id,
    ];
    notificationServiceInterface.addSeenNotificationIdList(idList);
    _safeUpdate();
  }

  List<int> getSeenNotificationIdList() {
    return notificationServiceInterface.getNotificationIdList();
  }

  Future<bool> deleteNotification(int notificationId) async {
    final success =
        await notificationServiceInterface.deleteNotification(notificationId);
    if (success) {
      _notificationList
          ?.removeWhere((notification) => notification.id == notificationId);

      final deletedIds = getDeletedNotificationIds();
      final seenIds = getSeenNotificationIdList();
      final seenIdsExcludingDeleted =
          seenIds.where((id) => !deletedIds.contains(id)).toList();

      _hasNotification =
          (_notificationList?.length ?? 0) != seenIdsExcludingDeleted.length;
      _safeUpdate();
    }
    return success;
  }

  List<int> getDeletedNotificationIds() {
    return notificationServiceInterface.getDeletedNotificationIds();
  }

  Future<void> saveDeletedNotificationIds(List<int> deletedIds) async {
    await notificationServiceInterface.saveDeletedNotificationIds(deletedIds);
  }

  Map<String, int> getNotificationCounts() {
    final deletedIds = getDeletedNotificationIds();
    final seenIds = getSeenNotificationIdList();
    final seenIdsExcludingDeleted =
        seenIds.where((id) => !deletedIds.contains(id)).toList();

    return {
      'totalNotifications': _notificationList?.length ?? 0,
      'seenNotifications': seenIdsExcludingDeleted.length,
      'deletedNotifications': deletedIds.length,
      'hasNotification': _hasNotification ? 1 : 0,
    };
  }
}
