import 'package:flutter/material.dart';
import 'donation_model.dart';
import 'donation_success_screen.dart';

class DonationDetailsScreen extends StatelessWidget {
  final DonationModel donation;

  const DonationDetailsScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: false,
        title: const Text(
          "Donation Details",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 0,
      ),

      body: DefaultTextStyle(
        style: const TextStyle(color: Colors.black),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const Text("Pictures",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        _imageBox(),
                        const SizedBox(width: 10),
                        _imageBox(),
                        const SizedBox(width: 10),
                        _imageBox(),
                      ],
                    ),

                    const SizedBox(height: 26),

                    const Text("Location",
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        "assets/images/map_dummy.png",
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),

                    const SizedBox(height: 14),

                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Row(children: const [
                            Icon(Icons.location_on, size: 16, color: Color.fromARGB(255, 206, 1, 1)),
                            SizedBox(width: 6),
                            Text(
                              "Allama Iqbal Chowk, Sialkot",
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                            ),
                          ]),

                          const SizedBox(height: 10),

                          Row(
                            children: const [
                              Text("Estimated Time",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                              Spacer(),
                              Text("25 mins",
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            ],
                          ),

                          const SizedBox(height: 8),
                          const Divider(thickness: 1, color: Colors.black26),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Column(
                        children: [
                          _detailRow("Donor", donation.hotel),
                          const SizedBox(height: 12),
                          _detailRow("Servings", "${donation.servings} Persons"),
                          const SizedBox(height: 12),
                          _detailRow("Precaution", donation.precaution),
                          const SizedBox(height: 16),
                          _descriptionSection(donation.description),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Return",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C45),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                     onPressed: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const DonationSuccessScreen(),
    ),
  );

  if (!context.mounted) return;

  if (result == true) {
    Navigator.pop(context, true);
  }
},

                      child: const Text("Accept",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageBox() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Image.asset(
        "assets/images/food.jpg",
        width: 90,
        height: 90,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 95,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 14.5, fontWeight: FontWeight.w600)),
        ),
        Expanded(
          child: Text(value,
              style: const TextStyle(fontSize: 14.5, height: 1.4)),
        ),
      ],
    );
  }

  Widget _descriptionSection(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Description",
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black26),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, height: 1.5),
          ),
        ),
      ],
    );
  }
}
