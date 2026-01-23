import 'package:flutter/material.dart';
import '../messages/chat_screen.dart';
import '../shared/assign_driver_screen.dart';

class DonorProfileScreen extends StatefulWidget {
  final Map donor;
  const DonorProfileScreen({super.key, required this.donor});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  bool isActive = true;
  Map? assignedDriver;

  @override
  void initState() {
    super.initState();
    isActive = widget.donor['status'] == "Active";
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.donor;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F5F54),
        elevation: 0,
        title: Text(
          d['name'],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(_infoCard(d)),
          const SizedBox(height: 16),
          _card(_impactSection()),
          const SizedBox(height: 16),

          if (assignedDriver != null) _card(_assignedDriverCard()),

          const SizedBox(height: 16),
          _card(_actions(d)),
        ],
      ),
    );
  }

  // ───────────── INFO ─────────────

  Widget _infoCard(Map d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          d['type'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          d['location'],
          style: const TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 12),
        _infoRow("Meals Donated", "${d['meals']}"),
        _infoRow("Rating", "${d['rating']} ⭐"),
      ],
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ───────────── IMPACT ─────────────

  Widget _impactSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Impact Summary",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 10),
        _ImpactRow("NGOs Helped", "5"),
        _ImpactRow("Food Waste Prevented", "230 kg"),
      ],
    );
  }

  // ───────────── ASSIGNED DRIVER ─────────────

  Widget _assignedDriverCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Delivery Status",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        _statusRow("Driver", assignedDriver!['name']),
        _statusRow("Vehicle", assignedDriver!['vehicle']),
        _statusRow(
          "Pickup Date",
          "${assignedDriver!['date'].day}/${assignedDriver!['date'].month}/${assignedDriver!['date'].year}",
        ),
        _statusRow(
          "Pickup Time",
          assignedDriver!['time'].format(context),
        ),
        _statusRow("Status", assignedDriver!['status']),
      ],
    );
  }

  Widget _statusRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ───────────── ACTIONS ─────────────

  Widget _actions(Map donor) {
    return Column(
      children: [
        SwitchListTile(
          value: isActive,
          inactiveThumbColor: const Color(0xFF0F5F54),
          onChanged: (v) => setState(() => isActive = v),
          title: Text(
            isActive ? "Active" : "Suspended",
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 16),

        _centerButton(
          icon: Icons.message,
          label: "Message Donor",
          enabled: isActive, // ✅ disabled when suspended
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatScreen(name: donor['name']),
              ),
            );
          },
        ),

        const SizedBox(height: 12),

        _centerButton(
          icon: Icons.delivery_dining,
          label: "Assign Pickup Driver",
          enabled: isActive, // ✅ disabled when suspended
          onTap: _assignDriver,
        ),
      ],
    );
  }

  Widget _centerButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
  }) {
    return SizedBox(
      width: 220,
      height: 44,
      child: ElevatedButton.icon(
        onPressed: enabled ? onTap : null,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              enabled ? const Color(0xFF0F5F54) : Colors.grey.shade400,
          foregroundColor: Colors.white,
          elevation: enabled ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // ───────────── ASSIGN DRIVER ─────────────

  void _assignDriver() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AssignDriverScreen()),
    );

    if (result != null) {
      setState(() => assignedDriver = result);
    }
  }

  // ───────────── CARD ─────────────

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

/// 🔹 IMPACT ROW
class _ImpactRow extends StatelessWidget {
  final String label;
  final String value;
  const _ImpactRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.black54),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
