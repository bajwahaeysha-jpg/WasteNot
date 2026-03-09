import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/activity_log/activity_log_data.dart';
import 'send_notification_screen.dart';

class ActivityLogScreen extends StatefulWidget {
  const ActivityLogScreen({super.key});

  @override
  State<ActivityLogScreen> createState() => _ActivityLogScreenState();
}

class _ActivityLogScreenState extends State<ActivityLogScreen> {

  /// DEFAULT SELECTED (All)
  int selectedIndex = 0;

  final List<String> groups = [
    "Donors & NGOs",
    "Donors",
    "NGOs"
  ];

  void openSend(String group) async {

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SendNotificationScreen(group: group),
      ),
    );

    if (result != null) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),

      appBar: AppBar(
        backgroundColor: const Color(0xFF0F4C45),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Activity Log",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: Column(
        children: [

          const SizedBox(height: 16),

          /// FILTER BAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: List.generate(groups.length, (index) {

                final isSelected = selectedIndex == index;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),

                    child: GestureDetector(
                      onTap: () {

                        setState(() {
                          selectedIndex = index;
                        });

                        openSend(groups[index]);
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),

                        padding: const EdgeInsets.symmetric(vertical: 12),

                        decoration: BoxDecoration(

                          color: isSelected
                              ? const Color(0xFF0F4C45)
                              : Colors.white,

                          borderRadius: BorderRadius.circular(30),

                          border: Border.all(
                            color: const Color(0xFF0F4C45),
                            width: 1.5,
                          ),

                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha:.15),
                                    blurRadius: 6,
                                  )
                                ]
                              : [],
                        ),

                        child: Center(
                          child: Text(
                            groups[index],

                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF0F4C45),

                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),

          const SizedBox(height: 20),

          /// RECENT TITLE
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Recent Notifications",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// NOTIFICATION LIST
          Expanded(
            child: activityLogs.isEmpty
                ? const Center(
                    child: Text(
                      "No notifications sent yet",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )

                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: activityLogs.length,

                    itemBuilder: (context, index) {

                      final log = activityLogs[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha:.05),
                              blurRadius: 6,
                            )
                          ],
                        ),

                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            /// ICON
                            Container(
                              padding: const EdgeInsets.all(10),

                              decoration: BoxDecoration(
                                color: const Color(0xFF0F4C45).withValues(alpha:.1),
                                shape: BoxShape.circle,
                              ),

                              child: const Icon(
                                Icons.notifications,
                                color: Color(0xFF0F4C45),
                              ),
                            ),

                            const SizedBox(width: 12),

                            /// TEXT
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [

                                  Text(
                                    log['title'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    log['message'],
                                    style: const TextStyle(height: 1.4),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "Sent to: ${log['receiver']}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            /// TIME
                            Text(
                              log['time'] ?? "",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}