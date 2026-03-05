import 'package:flutter/material.dart';
import 'expire_reason_screen.dart';

class DonationProfileScreen extends StatefulWidget {
  final Map<String, dynamic> donation;

  const DonationProfileScreen({super.key, required this.donation});

  @override
  State<DonationProfileScreen> createState() => _DonationProfileScreenState();
}

class _DonationProfileScreenState extends State<DonationProfileScreen> {
  late Map<String, dynamic> d;

  @override
  void initState() {
    super.initState();
    d = widget.donation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: const Text(
          "Donation Details",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [

          /// DONOR INFO
          _row("Donor", d['donor']),
          _row("Accepted by", d['ngo'] ?? "Not yet accepted"),
          _row("Location", d['location'] ?? "Unknown"),

          const Divider(height: 32),

          /// TIMES
          if (d['uploadedAt'] != null)
            _row("Uploaded at", d['uploadedAt']),
          if (d['acceptedAt'] != null)
            _row("Accepted at", d['acceptedAt']),
          if (d['pickedAt'] != null)
            _row("Picked up at", d['pickedAt']),

          const Divider(height: 32),

          /// DESCRIPTION
          const Text(
            "Donation Description",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          _row("Food", d['items']),
          _row("Servings", d['quantity'].toString()),

          const SizedBox(height: 24),

          /// PICTURES
          const Text(
            "Pictures",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(child: _image(d)),
              const SizedBox(width: 12),
              Expanded(child: _image(d)),
            ],
          ),

          const SizedBox(height: 20),

          /// ACTION
          if (d['status'] == "Active")
            GestureDetector(
              onTap: _openExpireReason,
              child: const Text(
                "Mark as Expired",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// ROW
  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// IMAGE
  Widget _image(Map d) {
    String img = d['images'] != null
        ? d['images'][0]
        : 'assets/images/food.jpg';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        img,
        height: 120,
        fit: BoxFit.cover,
      ),
    );
  }

  /// EXPIRE SCREEN
  Future<void> _openExpireReason() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ExpireReasonScreen(donation: d),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        d['status'] = "Expired";
        d['expireReason'] = result['reason'];
      });
    }
  }
}