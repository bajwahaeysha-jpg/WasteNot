class Donation {
  final String restaurantName;
  final String foodName;
  final String description;
  final String imageUrl;
  final String uploadTime;
  final String status;
  final int servings;
  final String location;

  Donation({
    required this.restaurantName,
    required this.foodName,
    required this.description,
    required this.imageUrl,
    required this.uploadTime,
    required this.status,
    required this.servings,
    required this.location,
  });
}
