import 'package:flutter/material.dart';
import '../../../../../models/accepted_donation_model.dart';

const Color mainGreen = Color(0xFF0E5E53);

class AcceptedDonationDetailScreen extends StatelessWidget {
  final AcceptedDonation donation;

  const AcceptedDonationDetailScreen({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    final d = donation;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F9),
      appBar: AppBar(
        backgroundColor: mainGreen,
        leading: const BackButton(color: Colors.white),
        title: const Text("Donation Details", style: TextStyle(color: Colors.white)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          _info("Donor", d.donor),
          _info("Accepted by", d.acceptedBy),
          _info("Location", d.location),

          const Divider(height: 30),

          _info("Uploaded at", d.uploadedAt),
          _info("Accepted at", d.acceptedAt),

          if (d.pickedAt != null)
            _info("Picked up at", d.pickedAt!),

          const Divider(height: 30),

          const Text("Donation Description", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),

          _info("Food", d.food),
          _info("Servings", d.servings.toString()),

          const SizedBox(height: 20),

          const Text("Pictures", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),

          Row(children: [
            Expanded(child: _smallImage(d.image)),
            const SizedBox(width: 10),
            Expanded(child: _smallImage(d.image)),
          ]),
        ]),
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        SizedBox(width: 120, child: Text(title, style: const TextStyle(fontWeight: FontWeight.w500))),
        Expanded(child: Text(value)),
      ]),
    );
  }

  Widget _smallImage(String path) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.asset(path, fit: BoxFit.cover),
      ),
    );
  }
}







