import 'package:flutter/material.dart';
import 'accepted_dummy_data.dart';
import 'accepted_donation_detail_screen.dart';

class AcceptedDonationsScreen extends StatefulWidget {
  const AcceptedDonationsScreen({super.key});

  @override
  State<AcceptedDonationsScreen> createState() =>
      _AcceptedDonationsScreenState();
}

class _AcceptedDonationsScreenState extends State<AcceptedDonationsScreen> {
  List<AcceptedDonation> filtered = [];
  bool isSearching = false;
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    filtered = List.from(acceptedDonations);
  }

  void _search(String q) {
    setState(() {
      filtered = acceptedDonations
          .where((d) => d.place.toLowerCase().contains(q.toLowerCase()))
          .toList();
    });
  }

  void _clear() {
    controller.clear();
    filtered = List.from(acceptedDonations);
    setState(() => isSearching = false);
  }

  String _groupLabel(DateTime d) {
    final now = DateTime.now();

    if (d.year == now.year && d.month == now.month && d.day == now.day) {
      return "Today";
    }

    if (d.year == now.year &&
        d.month == now.month &&
        d.day == now.day - 1) {
      return "Yesterday";
    }

    return "${d.day}/${d.month}/${d.year}";
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, List<AcceptedDonation>> grouped = {};

    for (var d in filtered) {
      grouped.putIfAbsent(_groupLabel(d.date), () => []).add(d);
    }

    return Scaffold(
      backgroundColor: const Color(0xffF4F4F4),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        titleSpacing: 0,

        title: isSearching
            ? TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: "Search restaurant / hotel",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: _clear,
                  ),
                ),
              )
            : const Text(
                "Accepted Donations",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),

        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () => setState(() => isSearching = true),
            ),
        ],
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: grouped.entries.map((group) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// ===== DATE HEADER =====
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Text(
                  group.key,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.black87,
                  ),
                ),
              ),

              /// ===== DONATION CARDS =====
              ...group.value.map((d) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AcceptedDonationDetailScreen(
                                  donation: d),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),

                      child: Row(
                        children: [

                          /// FOOD IMAGE
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              "assets/images/food.jpg",
                              width: 55,
                              height: 55,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),

                          /// FOOD + PLACE
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.food,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  d.place,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          /// TIME
                          Text(
                            d.pickupTime,
                            style: const TextStyle(
                              color: Color(0xFF0F4C45),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          );
        }).toList(),
      ),
    );
  }
}