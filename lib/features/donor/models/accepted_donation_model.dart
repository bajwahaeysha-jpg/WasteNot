class AcceptedDonation {
  String food;
  String place;
  String time;
  String image;

  String donor;
  String acceptedBy;
  String location;

  String uploadedAt;
  String acceptedAt;
  String? pickedAt;

  int servings;

  // 🔴 THIS IS IMPORTANT
  String status;

  AcceptedDonation({
    required this.food,
    required this.place,
    required this.time,
    required this.image,
    required this.donor,
    required this.acceptedBy,
    required this.location,
    required this.uploadedAt,
    required this.acceptedAt,
    this.pickedAt,
    required this.servings,
    this.status = "ACTIVE", // 🔴 DEFAULT ACTIVE
  });
} 