import 'package:flutter/material.dart';
import 'assign_staff_screen.dart';
class ConcernDetailScreen extends StatefulWidget {
  final Map concern;
  const ConcernDetailScreen({super.key, required this.concern});

  @override
  State<ConcernDetailScreen> createState() => _ConcernDetailScreenState();
}

class _ConcernDetailScreenState extends State<ConcernDetailScreen> {
  bool resolved = false;
  String? assignedStaff;

  static const Color mainGreen = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {
    final c = widget.concern;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        title: const Text(
          "Concern Details",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _card(_info(c)),
          const SizedBox(height: 16),
          _card(_actions()),
        ],
      ),
    );
  }

  // ───────────── INFO ─────────────

  Widget _info(Map c) {
    final statusText = resolved ? "Resolved" : c['status'];
    final statusColor =
        statusText == "Resolved" ? Colors.green : Colors.orange;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          c['title'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            Text(
              c['location'],
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),

        if (assignedStaff != null) ...[
          const SizedBox(height: 12),
          Text(
            "Assigned Staff: $assignedStaff",
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  // ───────────── ACTIONS ─────────────

  Widget _actions() {
    return Column(
      children: [

        /// 👤 ASSIGN STAFF
        _actionButton(
          icon: Icons.assignment_ind,
          label: "Assign Staff",
          onTap: _openAssignStaff,
        ),

        const SizedBox(height: 12),

        /// ✅ MARK RESOLVED
        _actionButton(
          icon: Icons.check_circle,
          label: "Mark Resolved",
          onTap: _markResolved,
        ),
      ],
    );
  }

  // ───────────── BUTTON ─────────────

  Widget _actionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Center(
      child: SizedBox(
        width: 220,
        height: 44,
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: mainGreen,
            foregroundColor: Colors.white,
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
          onPressed: onTap,
          icon: Icon(icon, size: 18),
          label: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ───────────── ACTION LOGIC ─────────────

 void _openAssignStaff() async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const AssignStaffScreen(),
    ),
  );

  if (!mounted) return; // ✅ IMPORTANT

  if (result != null) {
    setState(() => assignedStaff = result);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Staff '$result' assigned successfully"),
        backgroundColor: mainGreen,
      ),
    );
  }
}


  void _markResolved() {
    setState(() => resolved = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Concern marked as resolved"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // ───────────── CARD ─────────────

  Widget _card(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}
