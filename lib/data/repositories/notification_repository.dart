// import 'package:hive/hive.dart';
// import '../local/hive_boxes.dart';
// import '../models/notification_model.dart';
// import 'base_repository.dart';
// class NotificationRepository {
//   Box<NotificationModel> get _box => Hive.box<NotificationModel>(HiveBoxes.notifications);

//   List<NotificationModel> getAll() => _box.values.toList();

//   List<NotificationModel> getForMember(String memberId) =>
//       _box.values.where((n) => n.memberId == memberId).toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));

//   int getUnreadCount(String memberId) =>
//       _box.values.where((n) => n.memberId == memberId && !n.isRead).length;

//   Future<void> add(NotificationModel notification) async => await _box.put(notification.id, notification);

//   Future<void> markAsRead(String id) async {
//     final notif = _box.get(id);
//     if (notif != null) {
//       notif.isRead = true;
//       await notif.save();
//     }
//   }

//   Future<void> markAllRead(String memberId) async {
//     final notifications = _box.values.where((n) => n.memberId == memberId && !n.isRead).toList();
//     for (var n in notifications) {
//       n.isRead = true;
//       await n.save();
//     }
//   }
// }
import 'package:gym_management_app/data/local/hive_boxes.dart';
import 'package:gym_management_app/data/network/api_endpoints.dart';
import '../models/notification_model.dart';
import 'base_repository.dart';

class NotificationRepository extends BaseRepository<NotificationModel> {
  // Pass the Hive box name and API endpoint to the BaseRepository
  NotificationRepository() : super(HiveBoxes.notifications, ApiEndpoints.notifications);

  // GET ALL NOTIFICATIONS (Local Cache)
  List<NotificationModel> getAll() => box.values.toList();

  // GET FOR MEMBER (Local Filter & Sort)
  List<NotificationModel> getForMember(String memberId) =>
      box.values.where((n) => n.memberId == memberId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  // GET UNREAD COUNT
  int getUnreadCount(String memberId) =>
      box.values.where((n) => n.memberId == memberId && !n.isRead).length;

  // MARK AS READ (Optimistic + Queue)
  Future<void> markAsRead(String id) async {
    final notif = box.get(id);
    if (notif != null) {
      notif.isRead = true;
      // Using BaseRepository 'update' triggers the SyncQueue
      await update(notif, id: id);
    }
  }

  // MARK ALL AS READ
  Future<void> markAllRead(String memberId) async {
    final notifications = box.values.where((n) => n.memberId == memberId && !n.isRead).toList();
    for (var n in notifications) {
      n.isRead = true;
      await update(n, id: n.id);
    }
  }
}