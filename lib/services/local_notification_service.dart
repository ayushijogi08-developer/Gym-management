import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import '../data/models/meal_reminder_model.dart';

class LocalNotificationService {
  static FlutterLocalNotificationsPlugin? _notifications;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) {
      print('✅ LocalNotificationService already initialized');
      return;
    }

    try {
      // Initialize timezone
      tz.initializeTimeZones();

      // Android initialization settings
      const AndroidInitializationSettings androidSettings = 
          AndroidInitializationSettings('@mipmap/ic_launcher');
      
      // iOS initialization settings
      const DarwinInitializationSettings iosSettings = 
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );
      
      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      _notifications = FlutterLocalNotificationsPlugin();
      await _notifications!.initialize(
        settings,
        onDidReceiveNotificationResponse: (details) {
          print('📱 Notification tapped: ${details.payload}');
        },
      );

      // ✅ CREATE NOTIFICATION CHANNEL - THIS IS CRITICAL FOR ANDROID
      final androidPlugin = _notifications!.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        await androidPlugin.createNotificationChannel(
          AndroidNotificationChannel(
            'meal_reminder_channel',
            'Meal Reminders',
            description: 'Notifications for meal reminders',
            importance: Importance.high,
            enableVibration: true,
            playSound: true,
            showBadge: true,
          ),
        );
        print('✅ Notification channel created');
      }

      _initialized = true;
      print('✅ LocalNotificationService initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize LocalNotificationService: $e');
      rethrow;
    }
  }

  // Show immediate reminder - FIXED
  static Future<void> showMealReminder(
    String message,
    String mealType,
    String id,
  ) async {
    if (!_initialized || _notifications == null) {
      print('⚠️ Cannot show reminder: Service not initialized');
      // Try to initialize on the fly
      try {
        await init();
      } catch (e) {
        print('❌ Failed to initialize: $e');
        return;
      }
    }
    
    try {
      print('🔔 Showing immediate reminder: $message');

      // For testing on Android, use a simple notification
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'meal_reminder_channel',
        'Meal Reminders',
        channelDescription: 'Notifications for meal reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        enableVibration: true,
        playSound: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'meal_reminder',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications!.show(
        id.hashCode,
        '🍽️ Meal Time!',
        message,
        platformDetails,
      );

      print('✅ Immediate notification shown');
    } catch (e) {
      print('❌ Error showing notification: $e');
    }
  }

  // Schedule a meal reminder
  static Future<void> scheduleMealReminder(
    MealReminderModel reminder,
    String mealName,
  ) async {
    if (!_initialized || _notifications == null) {
      print('⚠️ Cannot schedule reminder: Service not initialized');
      return;
    }
    
    if (!reminder.isEnabled) {
      print('🔕 Reminder disabled, not scheduling');
      return;
    }

    try {
      final timeParts = reminder.scheduledTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final now = DateTime.now();
      var scheduledTime = DateTime(now.year, now.month, now.day, hour, minute);

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      print('⏰ Scheduling reminder for: $scheduledTime');

      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'meal_reminder_channel',
        'Meal Reminders',
        channelDescription: 'Notifications for meal reminders',
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
        enableVibration: true,
      );

      const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
        categoryIdentifier: 'meal_reminder',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications!.zonedSchedule(
        reminder.id.hashCode,
        '🍽️ Meal Time!',
        reminder.customMessage ?? 'Time for $mealName!',
        tz.TZDateTime.from(scheduledTime, tz.local),
        platformDetails,
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation: 
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      print('✅ Notification scheduled for $mealName at ${reminder.scheduledTime}');
    } catch (e) {
      print('❌ Error scheduling notification: $e');
    }
  }

  // Cancel a reminder
  static Future<void> cancelReminder(String id) async {
    if (!_initialized || _notifications == null) {
      print('⚠️ Cannot cancel reminder: Service not initialized');
      return;
    }
    
    try {
      await _notifications!.cancel(id.hashCode);
      print('🗑️ Cancelled notification for: $id');
    } catch (e) {
      print('❌ Error cancelling notification: $e');
    }
  }

  // Cancel all reminders
  static Future<void> cancelAllReminders() async {
    if (!_initialized || _notifications == null) {
      print('⚠️ Cannot cancel all reminders: Service not initialized');
      return;
    }
    
    try {
      await _notifications!.cancelAll();
      print('🗑️ All notifications cancelled');
    } catch (e) {
      print('❌ Error cancelling all notifications: $e');
    }
  }

  // Get pending notifications
  static Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    if (!_initialized || _notifications == null) {
      print('⚠️ Cannot get pending notifications: Service not initialized');
      return [];
    }
    
    try {
      return await _notifications!.pendingNotificationRequests();
    } catch (e) {
      print('❌ Error getting pending notifications: $e');
      return [];
    }
  }
}