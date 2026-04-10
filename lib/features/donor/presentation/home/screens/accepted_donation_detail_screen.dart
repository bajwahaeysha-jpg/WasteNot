import 'package:flutter/material.dart';
import 'package:wastenot/services/donation_services.dart';

const Color mainGreen = Color(0xFF0B4B3F);

class AcceptedDonationDetailScreen extends StatefulWidget {
  const AcceptedDonationDetailScreen({super.key, required this.donation});

  final DonationModel donation;

  @override
  State<AcceptedDonationDetailScreen> createState() =>
      _AcceptedDonationDetailScreenState();
}

class _AcceptedDonationDetailScreenState extends State<AcceptedDonationDetailScreen> {
  final DonationService _donationService = DonationService();
  late DonationModel _donation;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _donation = widget.donation;
  }

  Future<void> _markCompleted() async {
    if (_isCompleting) {
      return;
    }

    setState(() => _isCompleting = true);

    try {
      final updatedDonation = await _donationService.markDonationAsComplete(
        _donation.donationId,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _donation = updatedDonation;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Donation marked as completed.')),
      );
      Navigator.pop(context, true);
    } on DonationException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() => _isCompleting = false);
      }
    }
  }

  @override
Widget build(BuildContext context) {
  final donation = _donation;
  final canComplete =
      donation.status == DonationStatus.accepted.value;

  return Scaffold(
    backgroundColor: const Color(0xFFF5F7F6),
    appBar: AppBar(
      backgroundColor: mainGreen,
      title: const Text(
        'Donation Details',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      iconTheme: const IconThemeData(color: Colors.white),
    ),
    body: Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ðŸ”¥ IMAGE + STATUS
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Images",
                      style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold),
                    ),
                    _statusChip(donation.status),
                  ],
                ),
                const SizedBox(height: 10),

                donation.imageUrls.isEmpty
                    ? Container(
                        height: 110,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('No images uploaded'),
                      )
                    : SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: donation.imageUrls.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 10),
                          itemBuilder: (context, index) =>
                              ClipRRect(
                            borderRadius:
                                BorderRadius.circular(12),
                            child: SizedBox(
                              width: 120,
                              child: Image.network(
                                donation.imageUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder:
                                    (_, __, ___) =>
                                        const Icon(
                                            Icons.broken_image),
                              ),
                            ),
                          ),
                        ),
                      ),

                const SizedBox(height: 20),

                // ðŸ”¥ MERGED CARD
                _sectionCard(
                  child: Column(
                    children: [
                      _row("Donor", donation.donorName),
                      _row(
                        "Accepted by",
                        donation.acceptedByNgoName ??
                            'Not available',
                      ),
                      _row(
                        "Uploaded at",
                        _formatDateTime(donation.createdAt),
                      ),
                      _row(
                        "Accepted at",
                        donation.acceptedAt == null
                            ? 'Not available'
                            : _formatDateTime(
                                donation.acceptedAt!),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ðŸ”¥ DETAILS
                const Text(
                  "Details",
                  style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                _sectionCard(
                  child: Column(
                    children: [
                      _row(
                        "Food",
                        donation.foodItems.isEmpty
                            ? 'Not provided'
                            : donation.foodItems.join(', '),
                      ),
                      _row("Servings", donation.quantity),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ðŸ”¥ BUTTON SAME POSITION
        if (canComplete)
          Padding(
            padding: const EdgeInsets.all(14),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: mainGreen,
                minimumSize:
                    const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed:
                  _isCompleting ? null : _markCompleted,
              child: _isCompleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(
                                Colors.white),
                      ),
                    )
                  : const Text(
                      'Mark as Complete',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
      ],
    ),
  );
}


// ðŸ”¥ CARD
Widget _sectionCard({required Widget child}) {
  return Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: child,
  );
}


// ðŸ”¥ ROW
Widget _row(String title, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15),
          ),
        ),
      ],
    ),
  );
}


// ðŸ”¥ STATUS CHIP
Widget _statusChip(String status) {
  return Container(
    padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
    decoration: BoxDecoration(
      color: mainGreen,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      status.toUpperCase(),
      style: const TextStyle(color: Colors.white),
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
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

String _formatDateTime(DateTime value) {
  final hour = value.hour == 0 ? 12 : (value.hour > 12 ? value.hour - 12 : value.hour);
  final suffix = value.hour >= 12 ? 'PM' : 'AM';
  final minute = value.minute.toString().padLeft(2, '0');
  return '${value.day}/${value.month}/${value.year} $hour:$minute $suffix';
}
