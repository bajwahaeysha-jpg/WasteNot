class DonationModel {
  final String hotel;
  final String items;
  final String time;
  final int servings;
  final String precaution;
  final String description;
  final String image;   // 👈 NEW

  DonationModel({
    required this.hotel,
    required this.items,
    required this.time,
    required this.servings,
    required this.precaution,
    required this.description,
    required this.image,   // 👈 NEW
  });
}
