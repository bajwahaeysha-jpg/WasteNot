import 'package:flutter/material.dart';
import 'suspend_ngo_screen.dart';

class NGOProfileScreen extends StatelessWidget {
  final Map ngo;
  const NGOProfileScreen({super.key, required this.ngo});

  static const green = Color.fromARGB(255, 10, 62, 55);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: green,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          ngo['name'],
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _headerImage(),
          const SizedBox(height: 14),
          _nameRow(), // ✅ FIXED
          const SizedBox(height: 6),
          _locationRow(),
          const SizedBox(height: 20),
          _statsRow(),
          const SizedBox(height: 28),
          _aboutSection(),
          const SizedBox(height: 32),
          _actions(context),
        ],
      ),
    );
  }

  // ───────── IMAGE ─────────

  Widget _headerImage() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Image.asset(
        ngo['logo'],
        height: 220,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }

  // ───────── NAME + CALL / MESSAGE ─────────

  Widget _nameRow() {
    return Row(
      children: [
        Expanded(
          child: Text(
            ngo['name'],
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        const Icon(Icons.call, color: green, size: 24),
        const SizedBox(width: 20),
        const Icon(Icons.message, color: green, size: 24),
      ],
    );
  }

  // ───────── LOCATION ─────────

  Widget _locationRow() {
    return Row(
      children: [
        const Icon(Icons.location_on, size: 16, color: Colors.red),
        const SizedBox(width: 4),
        Text(
          ngo['location'],
          style: const TextStyle(color: Colors.black54),
        ),
      ],
    );
  }

  // ───────── STATS ─────────

  Widget _statsRow() {
    return Row(
      children: [
        _statBox("Meals", ngo['mealsReceived'].toString()),
        const SizedBox(width: 10),
        _statBox("Success", "${ngo['successRate']}%"),
        const SizedBox(width: 10),
        _statBox("Status", ngo['status']),
      ],
    );
  }

  Widget _statBox(String label, String value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────── ABOUT ─────────

  Widget _aboutSection() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About",
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "This NGO is dedicated to supporting underprivileged communities by "
          "ensuring fair and timely distribution of donated food. They work "
          "closely with donors and volunteers to maintain transparency and trust.\n\n"
          "Their mission focuses on reducing hunger, minimizing food waste, and "
          "creating long-term social impact through consistent community support.",
          style: TextStyle(
            fontSize: 14.5,
            height: 1.6,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  // ───────── ACTIONS ─────────

  Widget _actions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _actionRow(
          icon: Icons.notifications,
          text: "Send Notification",
          onTap: () => _showNotificationDialog(context),
        ),
        const SizedBox(height: 20),
        _actionRow(
          icon: Icons.block,
          text: "Suspend NGO",
          color: Colors.red,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SuspendNGOScreen(ngo: ngo),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _actionRow({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color color = green,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }


  // ───────── NOTIFICATION POPUP ─────────

  void _showNotificationDialog(BuildContext context) {
    DateTime? fromDate;
    DateTime? tillDate;

    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            Future<void> pickDateTime(bool isFrom) async {
              final date = await showDatePicker(
                context: dialogContext,
                initialDate: DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: green,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date == null) return;

              final time = await showTimePicker(
                context: dialogContext,
                initialTime: TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: const ColorScheme.light(
                        primary: green,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time == null) return;

              final dt = DateTime(
                date.year,
                date.month,
                date.day,
                time.hour,
                time.minute,
              );

              setState(() {
                if (isFrom) {
                  fromDate = dt;
                } else {
                  tillDate = dt;
                }
              });
            }

            String format(DateTime? d) {
              if (d == null) return "Select date & time";
              return "${d.day}/${d.month}/${d.year} "
                  "${d.hour}:${d.minute.toString().padLeft(2, '0')}";
            }

            return AlertDialog(
              backgroundColor: const Color(0xFFF7F9F8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              title: Row(
                children: const [
                  Icon(Icons.notifications, color: green),
                  SizedBox(width: 8),
                  Text("Send Notification"),
                ],
              ),
              content: SingleChildScrollView(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(dialogContext).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Title",
                        style:
                            TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(
                        isDense: true,
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text("Message",
                        style:
                            TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: msgCtrl,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 16),

                    _dateRow(
                      label: "Active From",
                      value: format(fromDate),
                      onTap: () => pickDateTime(true),
                    ),
                    const SizedBox(height: 10),
                    _dateRow(
                      label: "Active Till",
                      value: format(tillDate),
                      onTap: () => pickDateTime(false),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: green,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text("Send"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _dateRow({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Row(
          children: [
            Expanded(
              child: Text(
                value,
                style: const TextStyle(color: Colors.black),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.calendar_today, size: 18),
              color: green,
              onPressed: onTap,
            ),
            IconButton(
              icon: const Icon(Icons.access_time, size: 18),
              color: green,
              onPressed: onTap,
            ),
          ],
        ),
      ],
    );
  }
}
