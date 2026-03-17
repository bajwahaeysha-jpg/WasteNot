import 'package:wastenot/features/admin/activity_log/services/activity_log_notification_service.dart';

class DonorNotificationService {
  DonorNotificationService({ActivityLogNotificationService? activityService})
      : _activityService = activityService ?? ActivityLogNotificationService();

  final ActivityLogNotificationService _activityService;

  Stream<List<Map<String, dynamic>>> notificationsForDonor({
    required String? uid,
    required String? email,
  }) {
    return _activityService.notificationsForDonor(uid: uid, email: email);
  }
}
