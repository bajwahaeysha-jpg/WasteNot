import 'package:flutter/material.dart';

class AssignDriverScreen extends StatefulWidget {
  const AssignDriverScreen({super.key});

  @override
  State<AssignDriverScreen> createState() => _AssignDriverScreenState();
}

class _AssignDriverScreenState extends State<AssignDriverScreen> {
  Map? selectedDriver;
  DateTime? pickupDate;
  TimeOfDay? pickupTime;

  final drivers = [
    {"name": "Ali Khan", "vehicle": "Suzuki Pickup"},
    {"name": "Ahmed Raza", "vehicle": "Truck"},
    {"name": "Sara Malik", "vehicle": "Van"},
  ];

  static const Color mainGreen = Color(0xFF0B4B3F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9F8),
      appBar: AppBar(
        backgroundColor: mainGreen,
        elevation: 0,
        title: const Text(
          "Assign Pickup",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Select Driver",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 12),

          ...drivers.map((d) => _driverTile(d)),

          const SizedBox(height: 24),
          _dateTimePicker(),

          const SizedBox(height: 28),

          Center(
            child: SizedBox(
              width: 240,
              height: 46,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainGreen,
                  foregroundColor: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                ),
                onPressed: _confirmAssignment,
                child: const Text(
                  "Confirm Assignment",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ DRIVER TILE â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _driverTile(Map driver) {
    final isSelected = selectedDriver == driver;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3)),
        ],
        border: isSelected
            ? Border.all(color: mainGreen, width: 1.5)
            : null,
      ),
      child: ListTile(
        onTap: () => setState(() => selectedDriver = driver),
        leading: CircleAvatar(
          backgroundColor: mainGreen.withValues(alpha:0.12),
          child: const Icon(Icons.person, color: mainGreen),
        ),
        title: Text(
          driver['name'],
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text("Vehicle: ${driver['vehicle']}"),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: mainGreen)
            : null,
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ DATE & TIME PICKER â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Widget _dateTimePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Pickup Schedule",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
        const SizedBox(height: 12),

        _pickerTile(
          icon: Icons.calendar_month,
          title: pickupDate == null
              ? "Select Date"
              : "${pickupDate!.day}/${pickupDate!.month}/${pickupDate!.year}",
          onTap: _pickDate,
        ),

        _pickerTile(
          icon: Icons.access_time,
          title: pickupTime == null
              ? "Select Time"
              : pickupTime!.format(context),
          onTap: _pickTime,
        ),
      ],
    );
  }

  Widget _pickerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: mainGreen),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ PICKERS WITH THEME â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: mainGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null) setState(() => pickupDate = date);
  }

  void _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: mainGreen,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time != null) setState(() => pickupTime = time);
  }

  // â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ CONFIRM ASSIGNMENT â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void _confirmAssignment() {
    if (selectedDriver == null || pickupDate == null || pickupTime == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Driver Assigned",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: mainGreen,
          ),
        ),
        content: Text(
          "ðŸšš ${selectedDriver!['name']} has been successfully assigned for pickup.",
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: mainGreen,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              Navigator.pop(context); // close dialog
              Navigator.pop(context, {
                ...selectedDriver!,
                "date": pickupDate,
                "time": pickupTime,
                "status": "Scheduled",
              });
            },
            child: const Text(
              "Done",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
