class AcceptedDonation {
  final String food;
  final String place;
  final String pickupTime;
  final DateTime date;

  AcceptedDonation({
    required this.food,
    required this.place,
    required this.pickupTime,
    required this.date,
  });
}

final List<AcceptedDonation> acceptedDonations = [
  AcceptedDonation(
    food: "Chicken Biryani (80 plates)",
    place: "Student Biryani Saddar",
    pickupTime: "12:30 PM",
    date: DateTime.now(),
  ),
  AcceptedDonation(
    food: "Roti & Daal (120 plates)",
    place: "Bundukhan BBQ",
    pickupTime: "11:15 AM",
    date: DateTime.now(),
  ),
  AcceptedDonation(
    food: "Cooked Meals (50 packs)",
    place: "PC Hotel Karachi",
    pickupTime: "9:40 AM",
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  AcceptedDonation(
    food: "Nihari & Naan (70 plates)",
    place: "Burns Road Cafe",
    pickupTime: "8:20 PM",
    date: DateTime.now().subtract(const Duration(days: 1)),
  ),
  AcceptedDonation(
    food: "Sandwich Boxes (40)",
    place: "Pearl Continental Lahore",
    pickupTime: "2:10 PM",
    date: DateTime.now().subtract(const Duration(days: 3)),
  ),
];
