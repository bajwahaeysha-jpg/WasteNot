import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wastenot/features/admin/donors/services/admin_donor_management_service.dart';

import 'send_notification_screen.dart';
import 'suspend_donor_screen.dart';

class DonorProfileScreen extends StatelessWidget {
  const DonorProfileScreen({
    super.key,
    required this.donorId,
  });

  final String donorId;

  static const Color primary = Color(0xFF0F4C45);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 0.45;
    final service = AdminDonorManagementService();

    return StreamBuilder<AdminManagedDonor?>(
      stream: service.streamDonorById(donorId),
      builder: (context, snapshot) {
        final donor = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting &&
            donor == null) {
          return const Scaffold(
            backgroundColor: Color(0xFFF5F7F6),
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F6),
          appBar: AppBar(
            backgroundColor: primary,
            elevation: 0,
            title: Text(
              donor?.name ?? "Donor",
              style: const TextStyle(color: Colors.white),
            ),
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: donor == null
              ? const Center(child: Text("Donor not found"))
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: donor.imageUrl.isNotEmpty
                            ? Image.network(
                                donor.imageUrl,
                                height: imageHeight,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, _, _) =>
                                    _imageFallback(imageHeight),
                              )
                            : _imageFallback(imageHeight),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  donor.name,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  donor.phone.isEmpty
                                      ? "Phone not available"
                                      : donor.phone,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 16,
                                      color: Colors.red,
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        donor.locationLabel,
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.call, color: primary),
                            onPressed: () => _callDonor(context, donor.phone),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          _statBox(
                            donor.totalMealsDonated.toString(),
                            "Meals",
                          ),
                          const SizedBox(width: 10),
                          _statBox(
                            "${donor.successRate}%",
                            "Success",
                          ),
                          const SizedBox(width: 10),
                          _statBox(
                            donor.statusLabel,
                            "Status",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        "About",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        donor.aboutLabel,
                        style: const TextStyle(
                          color: Colors.black87,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ListTile(
                      leading: const Icon(
                        Icons.notifications,
                        color: primary,
                      ),
                      title: const Text("Send Notification"),
                      onTap: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const SendNotificationScreen(),
                          ),
                        );

                        if (result == null) {
                          return;
                        }

                        final title =
                            (result['title'] as String? ?? '').trim();
                        final message =
                            (result['message'] as String? ?? '').trim();

                        if (title.isEmpty || message.isEmpty) {
                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Title and message are required"),
                            ),
                          );
                          return;
                        }

                        await service.sendNotificationToDonor(
                          donorId: donor.id,
                          donorName: donor.name,
                          title: title,
                          message: message,
                        );

                        if (!context.mounted) {
                          return;
                        }

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Notification Sent")),
                        );
                      },
                    ),
                    ListTile(
                      leading: Icon(
                        donor.isSuspended ? Icons.check_circle : Icons.block,
                        color: donor.isSuspended ? Colors.green : Colors.red,
                      ),
                      title: Text(
                        donor.isSuspended
                            ? "Unsuspend Donor"
                            : "Suspend Donor",
                        style: TextStyle(
                          color:
                              donor.isSuspended ? Colors.green : Colors.red,
                        ),
                      ),
                      onTap: () async {
                        if (donor.isSuspended) {
                          await service.unsuspendDonor(
                            donorId: donor.id,
                            donorName: donor.name,
                          );

                          if (!context.mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Donor re-enabled successfully"),
                            ),
                          );
                          return;
                        }

                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SuspendDonorScreen(donor: donor),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
        );
      },
    );
  }

  Widget _statBox(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEDED),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback(double imageHeight) {
    return Container(
      height: imageHeight,
      width: double.infinity,
      color: Colors.grey.shade300,
      alignment: Alignment.center,
      child: const Icon(
        Icons.person,
        size: 60,
        color: Colors.grey,
      ),
    );
  }

  Future<void> _callDonor(BuildContext context, String phone) async {
    final trimmedPhone = phone.trim();

    if (trimmedPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Phone number not available"),
        ),
      );
      return;
    }

    final telUrl = Uri.parse('tel:$trimmedPhone');
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
      return;
    }

    if (!context.mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unable to open dialer"),
      ),
    );
  }
}
