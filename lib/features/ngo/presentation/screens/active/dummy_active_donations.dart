import 'donation_model.dart';

final List<Donation> activeDonations = [
  Donation(
    restaurantName: "Allah Malik Restaurant",
    foodName: "Chicken Biryani",
    description: "Freshly cooked biryani with raita and salad.",
imageUrl: "assets/images/food.jpg",
    uploadTime: "10:30 AM",
    status: "Waiting for pickup",
    servings: 15,
    location: "Sector 11, Wedding Hall",
  ),
  Donation(
    restaurantName: "Cafe Aroma",
    foodName: "Qorma",
    description: "Healthy Qorma with naan bread.",
imageUrl: "assets/images/qorma.png",
    uploadTime: "11:15 AM",
    status: "Waiting for pickup",
    servings: 8,
    location: "Block C, City Center",
  ),
];
