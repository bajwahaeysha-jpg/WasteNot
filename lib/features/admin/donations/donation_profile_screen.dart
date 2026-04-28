import 'package:flutter/material.dart';
import 'package:wastenot/shared/widgets/location_map_preview.dart';
import 'package:wastenot/services/donation_services.dart';

const Color mainGreen = Color(0xFF0B4B3F);

class DonationProfileScreen extends StatefulWidget {
  const DonationProfileScreen({super.key, required this.donation});

  final DonationModel donation;

  @override
  State<DonationProfileScreen> createState() =>
      _DonationProfileScreenState();
}

class _DonationProfileScreenState extends State<DonationProfileScreen> {
  final DonationService _donationService = DonationService();
  late Future<DonationModel> _donationFuture;

  @override
  void initState() {
    super.initState();
    _donationFuture =
        _donationService.getDonationById(widget.donation.donationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text("Donation Details",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<DonationModel>(
        future: _donationFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final d = snapshot.data!;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [

              /// ðŸ”¥ PICTURES + STATUS SAME LINE
              if (d.imageUrls.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _heading("Pictures"),
                    _statusChip(d.status),
                  ],
                ),

              const SizedBox(height: 10),

              /// ðŸ”¥ IMAGES (SMALLER)
              if (d.imageUrls.isNotEmpty) ...[
                _images(d.imageUrls),
                const SizedBox(height: 20),
              ],

              /// ðŸ”¥ LOCATION
              _heading("Location"),
              const SizedBox(height: 10),

              LocationMapPreview(location: d.location, height: 160),

              const SizedBox(height: 10),

              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      d.locationAddress ?? "Unknown location",
                    ),
                  ),
                ],
              ),

              const Divider(height: 30),

              /// ðŸ”¥ DONOR / NGO
              _info("Donated by", d.donorName),

/// ✅ ACCEPTED INFO (only if accepted OR completed)
if (d.status == 'accepted' || d.status == 'completed') ...[
  if (d.acceptedByNgoName != null)
    _info("Accepted by", d.acceptedByNgoName!),

  if (d.acceptedAt != null)
    _info("Accepted at", _formatDateTime(d.acceptedAt!)),
],

const SizedBox(height: 10),

_info("Donated at", _formatDateTime(d.createdAt)),

/// ✅ EXPIRED ONLY WHEN STATUS = expired
if (d.status == 'expired' && d.expiryAt != null)
  _info("Expired at", _formatDateTime(d.expiryAt!)),

              const SizedBox(height: 20),

              /// ðŸ”¥ FOOD INLINE
              if (d.foodItems.isNotEmpty)
                Row(
                  children: [
                    const SizedBox(
                      width: 120,
                      child: Text(
                        "Food",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(d.foodItems.join(", ")),
                    ),
                  ],
                ),

              const SizedBox(height: 12),

              /// ðŸ”¥ SERVINGS NEXT LINE
              Row(
                children: [
                  const SizedBox(
                    width: 120,
                    child: Text(
                      "Servings",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(d.quantity),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// ðŸ”¥ DESCRIPTION
              if ((d.description ?? '').isNotEmpty) ...[
                _heading("Description"),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(d.description!),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  /// ðŸ”¥ HELPERS

  Widget _heading(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 16,
      ),
    );
  }

  Widget _info(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _images(List<String> urls) {
    return SizedBox(
      height: 90, // ðŸ”¥ reduced size
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            urls[i],
            width: 90, // ðŸ”¥ reduced
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor(status),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'accepted':
        return mainGreen;
      case 'expired':
        return Colors.red;
      case 'completed':
        return Colors.blueGrey;
      default:
        return Colors.orange;
    }
  }
}

String _formatDateTime(DateTime value) {
  final hour =
      value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day}/${value.month}/${value.year} $hour:$minute $suffix';
}