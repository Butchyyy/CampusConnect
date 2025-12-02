class NotificationService {
  static Future<void> init() async {

    print('Notification service initialized');
  }

  static Future<void> scheduleClassReminder({
    required int id,
    required String className,
    required DateTime scheduledTime,
    String? location,
  }) async {
    print('Scheduled reminder for $className at $scheduledTime');
  }

  static Future<void> sendStreakNotification(int streak) async {
    print('Streak notification: $streak days');
  }

  static Future<void> sendAchievementNotification({
    required String achievementName,
    required String description,
  }) async {
    print('Achievement unlocked: $achievementName');
  }


  static Future<void> scheduleAssignmentReminder({
    required String assignmentId,
    required String assignmentTitle,
    required String subjectName,
    required DateTime dueDate,
  }) async {

    final oneDayBefore = dueDate.subtract(const Duration(days: 1));
    print('Scheduled assignment reminder for $assignmentTitle ($subjectName) - 1 day before: $oneDayBefore');


    print('Scheduled assignment reminder for $assignmentTitle ($subjectName) - due date: $dueDate');
  }

  static Future<void> cancelAssignmentNotification(String assignmentId) async {
    print('Cancelled notification for assignment: $assignmentId');
  }
}