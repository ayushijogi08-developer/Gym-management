// lib/providers/notification_provider.dart
import 'package:flutter/material.dart';
import '../data/models/notification_model.dart';
import '../data/network/api_client.dart';
import '../data/network/api_endpoints.dart';

class NotificationProvider extends ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;

  // Fetch from Node.js API
  Future<void> fetchNotifications() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.get(ApiEndpoints.notifications);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        _notifications = data.map((json) => NotificationModel.fromJson(json)).toList();
      }
    } catch (e) {
      debugPrint("Error fetching notifications: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int get unreadCount => _notifications.where((n) => n.isRead == false).length;

  // FIX: Use named parameter 'data'
  Future<void> markAsRead(String id) async {
    try {
      await ApiClient.post(
        '${ApiEndpoints.notifications}/mark-read/$id',
        data: {},
      );
      // Update locally for instant UI feedback
      final index = _notifications.indexWhere((n) => n.id == id);
      if (index != -1) {
        _notifications[index].isRead = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error marking read: $e");
    }
  }

  // FIX: Use named parameter 'data'
  Future<void> markAllRead() async {
    try {
      await ApiClient.put(
        '${ApiEndpoints.notifications}/mark-all-read',
        data: {},  // Changed to named parameter
      );
      for (var n in _notifications) {
        n.isRead = true;
      }
      notifyListeners();
    } catch (e) {
      debugPrint("Error marking all read: $e");
    }
  }

  // FIX: Use named parameter 'data'
  Future<void> addNotification(NotificationModel notification) async {
    try {
      // 1. Send to backend with named parameter
      final response = await ApiClient.post(
        ApiEndpoints.notifications,
        data: notification.toJson(),  // Changed to named parameter
      );
      
      // 2. Update local state with the actual data returned by the server
      if (response.data['success'] == true) {
        final newNotification = NotificationModel.fromJson(response.data['data']);
        _notifications.insert(0, newNotification); // Add to the top of the list
        notifyListeners();
      }
    } catch (e) {
      debugPrint("Error adding notification: $e");
      rethrow; // Optional: let the UI handle the error state
    }
  }
  
  // In notification_provider.dart
  List<NotificationModel> getNotificationsForCurrentUser(String? currentUserId) {
    if (currentUserId == null) return []; // Return empty if null
    return _notifications.where((n) => n.memberId == currentUserId).toList();
  }

  // ADD THIS METHOD
  int getUnreadCount() {
    return _notifications.where((n) => n.isRead == false).length;
  }

  // `seedDummyNotifications` was removed — the notification list is now populated
  // exclusively from the backend API via `fetchNotifications()`.
}