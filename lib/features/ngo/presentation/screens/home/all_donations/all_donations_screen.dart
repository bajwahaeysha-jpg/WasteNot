import 'package:flutter/material.dart';
import 'donation_details_screen.dart';
import 'donation_success_screen.dart';
import 'dummy_all_donations.dart';

class AllDonationsScreen extends StatefulWidget {
  const AllDonationsScreen({super.key});

  @override
  State<AllDonationsScreen> createState() => _AllDonationsScreenState();
}

class _AllDonationsScreenState extends State<AllDonationsScreen> {
  String query = "";
  bool showSearch = false;

  @override
  Widget build(BuildContext context) {
    final filteredDonations = allDonations.where((d) {
      return d.items.toLowerCase().contains(query.toLowerCase()) ||
          d.hotel.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        title: const Text(
          "Available Donations",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(showSearch ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                showSearch = !showSearch;
                query = "";
              });
            },
          )
        ],
        bottom: showSearch
            ? PreferredSize(
                preferredSize: const Size.fromHeight(52),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
                  child: Container(
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: TextField(
                      onChanged: (v) => setState(() => query = v),
                      decoration: const InputDecoration(
                        hintText: "Search donations...",
                        prefixIcon: Icon(Icons.search),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
              )
            : null,
      ),

      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.black),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Padding(
              padding: EdgeInsets.fromLTRB(16, 12, 0, 6),
              child: Text(
                "Today",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),

            Expanded(
              child: ListView.builder(
                itemCount: filteredDonations.length,
                itemBuilder: (context, index) {
                  final donation = filteredDonations[index];

                  return GestureDetector(
                    onTap: () async {
                      final accepted = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DonationDetailsScreen(donation: donation),
                        ),
                      );

                      if (accepted == true) {
                        setState(() {
                          allDonations.remove(donation);
                        });
                      }
                    },

                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      padding: const EdgeInsets.all(12),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),

                      child: Row(
                        children: [

                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset(
                              donation.image,
                              width: 85,
                              height: 85,
                              fit: BoxFit.cover,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    donation.time,
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),

                                Text(
                                  donation.items,
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),

                                const SizedBox(height: 4),

                                Row(children: [
                                  const Icon(Icons.store,
                                      size: 14, color: Colors.redAccent),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      donation.hotel,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ]),

                                const SizedBox(height: 4),

                                Row(children: [
                                  const Icon(Icons.ac_unit,
                                      size: 14, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text(donation.precaution),
                                ]),

                                const SizedBox(height: 10),

                                Row(
                                  children: [

                                    const Text(
                                      "View details",
                                      style: TextStyle(
                                          color: Colors.teal, fontSize: 13),
                                    ),

                                    const SizedBox(width: 6),

                                    const Icon(Icons.info_outline,
                                        size: 14, color: Colors.teal),

                                    const Spacer(),

                                    SizedBox(
                                      width: 110,
                                      height: 34,
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.amber,
                                          padding: EdgeInsets.zero,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),

                                        onPressed: () async {
                                          final result = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  const DonationSuccessScreen(),
                                            ),
                                          );

                                          if (!context.mounted) return;

                                          if (result == true) {
                                            setState(() {
                                              allDonations.remove(donation);
                                            });
                                          }
                                        },

                                        child: const Text(
                                          "Accept",
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}