class AlertModel {
  final String title;
  final String description;
  final DateTime createdAt;
  final bool isResolved;

  AlertModel({
    required this.title,
    required this.description,
    required this.createdAt,
    required this.isResolved,
  });
}
