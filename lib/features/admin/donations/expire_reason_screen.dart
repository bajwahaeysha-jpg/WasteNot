import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/donations/expire_success_screen.dart';
import 'package:wastenot/services/donation_services.dart';

class ExpireReasonScreen extends StatefulWidget {
  const ExpireReasonScreen({super.key, required this.donation});

  final DonationModel donation;

  @override
  State<ExpireReasonScreen> createState() => _ExpireReasonScreenState();
}

class _ExpireReasonScreenState extends State<ExpireReasonScreen> {
  final TextEditingController reasonController = TextEditingController();
  final DonationService _donationService = DonationService();
  bool _isSubmitting = false;

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  Future<void> _markExpired() async {
    if (reasonController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a reason first')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await _donationService.markDonationExpired(
        donationId: widget.donation.donationId,
      );

      if (!mounted) {
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ExpireSuccessScreen()),
      );

      if (!mounted) {
        return;
      }

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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B4B3F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Expire Donation',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reason for Expiring',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 6),
            const Text(
              'Please provide a clear reason. This will be sent as a notification to the donor and NGO.',
              style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: reasonController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter reason here...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 26),
            const Text(
              'Donation Summary',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            _infoRow('Donor', widget.donation.donorName),
            _infoRow(
              'Food',
              widget.donation.foodItems.isEmpty
                  ? 'Not provided'
                  : widget.donation.foodItems.join(', '),
            ),
            _infoRow('Servings', widget.donation.quantity),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _markExpired,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Mark Expired & Notify',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
