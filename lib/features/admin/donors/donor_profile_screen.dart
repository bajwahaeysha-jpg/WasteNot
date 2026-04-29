import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wastenot/features/admin/donors/services/admin_donor_management_service.dart';
import 'package:wastenot/services/user_account_lifecycle_service.dart';

import 'send_notification_screen.dart';
import 'suspend_donor_screen.dart';

class DonorProfileScreen extends StatelessWidget {
  const DonorProfileScreen({
    super.key,
    required this.donorId,
  });

  final String donorId;

  static const Color primary = Color(0xFF0B4B3F);

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
                                Text(
                                  donor.email,
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
                            donor.isSuspended ? "Suspended" : "Active",
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
                        color: donor.isSuspended ? const Color(0xFF0B4B3F) : Colors.red,
                      ),
                      title: Text(
                        donor.isSuspended
                            ? "Unsuspend Donor"
                            : "Suspend Donor",
                        style: TextStyle(
                          color:
                              donor.isSuspended ? const Color(0xFF0B4B3F) : Colors.red,
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
                    ListTile(
                      leading: const Icon(
                        Icons.delete_forever,
                        color: Colors.red,
                      ),
                      title: const Text(
                        "Delete Account",
                        style: TextStyle(color: Colors.red),
                      ),
                      onTap: () => _confirmDeleteDonor(
                        context,
                        service,
                        donor,
                      ),
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

  Future<void> _confirmDeleteDonor(
    BuildContext context,
    AdminDonorManagementService service,
    AdminManagedDonor donor,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete donor account'),
            content: const Text(
              'This permanently deletes the donor account. Historical records stay preserved for admin review, but all live links to the donor are detached.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed || !context.mounted) {
      return;
    }

    final messenger = ScaffoldMessenger.of(context);
    _showBlockingLoader(context);
    try {
      await service.deleteDonorAccount(
        donorId: donor.id,
        donorName: donor.name,
      );

      if (!context.mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Donor account deleted successfully')),
      );
    } on UserAccountLifecycleFailure catch (error) {
      if (!context.mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pop();
      messenger.showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } catch (_) {
      if (!context.mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('Failed to delete donor account')),
      );
    }
  }

  void _showBlockingLoader(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
  }
}
