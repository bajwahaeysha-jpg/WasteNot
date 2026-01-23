class ConcernModel {
  final String id;
  final String userId;
  final String message;
  final DateTime reportedAt;

  ConcernModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.reportedAt,
  });
}
