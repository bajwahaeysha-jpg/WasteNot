import 'package:flutter/material.dart';
import 'accepted_dummy_data.dart';
import 'accepted_donation_detail_screen.dart';

class AcceptedDonationsScreen extends StatefulWidget {
  const AcceptedDonationsScreen({super.key});

  @override
  State<AcceptedDonationsScreen> createState() => _AcceptedDonationsScreenState();
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
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white70),

        titleSpacing: 0, // 👈 removes space after back arrow
        title: isSearching
            ? TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(color: Colors.white70),
                onChanged: _search,
                decoration: InputDecoration(
                  hintText: "Search restaurant / hotel",
                  hintStyle: const TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: _clear,
                  ),
                ),
              )
            : const Text(
                "Accepted Donations",
                style: TextStyle(color: Colors.white70),
              ),

        actions: [
          if (!isSearching)
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white70),
              onPressed: () => setState(() => isSearching = true),
            ),
        ],
      ),

      body: ListView(
        children: grouped.entries.map((group) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ======= GROUP HEADER =======
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: const Color(0xFFF1F1F1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Divider(height: 1, thickness: 0.8),
                  ],
                ),
              ),

              // ======= DONATION ROWS =======
              ...group.value.map((d) => InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              AcceptedDonationDetailScreen(donation: d),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: Colors.black12),
                        ),
                      ),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundImage:
                                AssetImage("assets/images/food.jpg"),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  d.food,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  d.place,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            d.pickupTime,
                            style: const TextStyle(
                              color: Colors.green,
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
