import 'package:wastenot/features/admin/activity_log/services/activity_log_notification_service.dart';

class NgoNotificationService {
  NgoNotificationService({ActivityLogNotificationService? activityService})
      : _activityService = activityService ?? ActivityLogNotificationService();

  final ActivityLogNotificationService _activityService;

  Stream<List<Map<String, dynamic>>> notificationsForNgo({
    required String? uid,
    required String? email,
  }) {
    return _activityService.notificationsForNgo(uid: uid, email: email);
  }
}
