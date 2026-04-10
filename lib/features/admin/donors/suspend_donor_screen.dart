import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/donors/services/admin_donor_management_service.dart';

class SuspendDonorScreen extends StatefulWidget {
  const SuspendDonorScreen({super.key, required this.donor});

  final AdminManagedDonor donor;

  @override
  State<SuspendDonorScreen> createState() => _SuspendDonorScreenState();
}

class _SuspendDonorScreenState extends State<SuspendDonorScreen> {
  final TextEditingController reasonCtrl = TextEditingController();
  final TextEditingController detailCtrl = TextEditingController();
  final _service = AdminDonorManagementService();

  static const primary = Color(0xFF0B4B3F);
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: primary,
        title: const Text(
          "Suspend Donor",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            "Reason for Suspension",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
            ),
            child: TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(
                hintText: "Enter suspension reason",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            "Details",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
            ),
            child: TextField(
              controller: detailCtrl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Write detailed explanation here...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(14),
              ),
            ),
          ),
          const SizedBox(height: 30),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Donor Information",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _detailRow("Name", widget.donor.name),
                const SizedBox(height: 8),
                _detailRow("Location", widget.donor.locationLabel),
                const SizedBox(height: 8),
                _detailRow(
                  "Phone",
                  widget.donor.phone.isEmpty ? "No phone" : widget.donor.phone,
                ),
                const SizedBox(height: 12),
                Text(
                  "The donor will be suspended and notified regarding this action.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 50,
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26),
                ),
              ),
              onPressed: _saving ? null : _submit,
              icon: const Icon(Icons.block, color: Colors.white),
              label: Text(
                _saving ? "Suspending..." : "Suspend & Notify Donor",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    if (reasonCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter suspension reason"),
        ),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      await _service.suspendDonor(
        donorId: widget.donor.id,
        donorName: widget.donor.name,
        reason: reasonCtrl.text,
        details: detailCtrl.text,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Donor suspended successfully"),
        ),
      );
      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Widget _detailRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    reasonCtrl.dispose();
    detailCtrl.dispose();
    super.dispose();
  }
}
