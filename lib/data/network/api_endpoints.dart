class ApiEndpoints {
  static const String baseUrl = 'http://localhost:5001'; // Change for production

  // Auth
  static const String login = '$baseUrl/api/auth/login';
  static const String register = '$baseUrl/api/auth/register';
  static const String me = '$baseUrl/api/auth/me';

static const String changePassword =
    '$baseUrl/api/auth/change-password';
  // Members
  static const String members = '$baseUrl/api/v2/members';
  // Plans
  static const String plans = '$baseUrl/api/plans';

  // Trainers
  static const String trainers = '$baseUrl/api/trainers';

  // Subscriptions
  static const String subscriptions = '$baseUrl/api/subscriptions';

  // Payments
  static const String payments = '$baseUrl/api/payments';

  // Attendance
  static const String attendance = '$baseUrl/api/attendance';

  // Diet Plans
  static const String dietPlans = '$baseUrl/api/diet-plans';

  // Workout Plans
  static const String workoutPlans = '$baseUrl/api/workout-plans';

  // Goals
  static const String goals = '$baseUrl/api/goals';

  // Achievements
  static const String achievements = '$baseUrl/api/achievements';

  // Timeline
  static const String timeline = '$baseUrl/api/timeline';

  // Notifications
  static const String notifications = '$baseUrl/api/notifications';

  // Uploads
  static const String uploadImage = '$baseUrl/api/upload/image';
  static const String uploadPdf = '$baseUrl/api/upload/pdf';

  // AI
  static const String aiChat = '$baseUrl/api/ai/chat';
  static const String bodyProgress = '$baseUrl/api/body-progress';
  static const String gymConfig = '$baseUrl/api/gym-config';
  static const String mealReminders = '$baseUrl/api/meal-reminders';
  static const String chatMessages = '$baseUrl/api/ai/chat';
  static const String mealLogs = '$baseUrl/api/meal-logs';
  static const String users = '$baseUrl/api/users';
 static const String workoutLogs = '$baseUrl/api/workout-logs';
}