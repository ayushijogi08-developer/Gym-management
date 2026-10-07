import 'package:flutter/foundation.dart';
import '../data/models/meal_reminder_model.dart';
import '../data/repositories/meal_reminder_repository.dart';
import '../services/local_notification_service.dart';

class MealReminderProvider extends ChangeNotifier {
  final MealReminderRepository _repo = MealReminderRepository();
  List<MealReminderModel> _reminders = [];

  List<MealReminderModel> get reminders => _reminders;

  // Load from local
  void loadFromLocal() {
    _reminders = _repo.getAllLocal();
    notifyListeners();
  }

  // Get reminders for a member
  List<MealReminderModel> getAllForMember(String memberId) {
    return _reminders.where((r) => r.memberId == memberId).toList();
  }

  // Fetch from API
  Future<void> fetchForMember(String memberId) async {
    try {
      final fetched = await _repo.getForMember(memberId);
      _reminders = fetched;
      notifyListeners();
    } catch (e) {
      print("❌ Error fetching reminders: $e");
      _reminders = _repo.getForMemberLocal(memberId);
      notifyListeners();
    }
  }

  // Save reminder (CREATE or UPDATE)
  Future<void> saveReminder(MealReminderModel reminder, String mealName) async {
    print("📝 Saving reminder for: $mealName at ${reminder.scheduledTime}");
    
    // Check if reminder already exists
    final existing = _reminders.firstWhere(
      (r) => r.memberId == reminder.memberId && r.mealType == reminder.mealType,
      orElse: () => reminder,
    );

    if (existing.id == reminder.id) {
      // New reminder
      await _repo.addReminder(reminder);
    } else {
      // Update existing
      existing.scheduledTime = reminder.scheduledTime;
      existing.isEnabled = reminder.isEnabled;
      existing.customMessage = reminder.customMessage;
      await _repo.updateReminder(existing);
    }

    _reminders = _repo.getAllLocal();
    notifyListeners();

    // Schedule local notification
    if (reminder.isEnabled) {
      await LocalNotificationService.scheduleMealReminder(reminder, mealName);
      print("✅ Notification scheduled for $mealName at ${reminder.scheduledTime}");
    } else {
      await LocalNotificationService.cancelReminder(reminder.id);
      print("🔕 Notification cancelled for $mealName");
    }
  }

  // Toggle reminder
  Future<void> toggleReminder(String id, bool enabled) async {
    final reminder = _reminders.firstWhere((r) => r.id == id);
    reminder.isEnabled = enabled;
    await _repo.updateReminder(reminder);
    _reminders = _repo.getAllLocal();
    notifyListeners();

    if (enabled) {
      await LocalNotificationService.scheduleMealReminder(reminder, reminder.mealType);
    } else {
      await LocalNotificationService.cancelReminder(id);
    }
  }

  // Delete reminder
  Future<void> deleteReminder(String id) async {
    await _repo.deleteReminder(id);
    _reminders = _repo.getAllLocal();
    await LocalNotificationService.cancelReminder(id);
    notifyListeners();
  }
}