import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wastenot/features/admin/ngos/services/admin_ngo_management_service.dart';
import 'package:wastenot/services/user_account_lifecycle_service.dart';

import 'suspend_ngo_screen.dart';

class NGOProfileScreen extends StatelessWidget {
  const NGOProfileScreen({
    super.key,
    required this.ngoId,
  });

  final String ngoId;

  static const primary = Color(0xFF0B4B3F);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenWidth * 0.45;
    final service = AdminNgoManagementService();

    return StreamBuilder<AdminManagedNgo?>(
      stream: service.streamNgoById(ngoId),
      builder: (context, snapshot) {
        final ngo = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting && ngo == null) {
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
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              ngo?.name ?? "NGO",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: ngo == null
              ? const Center(child: Text("NGO not found"))
              : ListView(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        height: imageHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: ngo.imageUrl.isNotEmpty
                              ? Image.network(
                                  ngo.imageUrl,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, _, _) =>
                                      _imageFallback(imageHeight),
                                )
                              : _imageFallback(imageHeight),
                        ),
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
                                  ngo.name,
                                  style: TextStyle(
                                    fontSize: screenWidth * 0.05,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ngo.phone.isEmpty
                                      ? "Phone not available"
                                      : ngo.phone,
                                  style: const TextStyle(
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  ngo.email,
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
                                        ngo.locationLabel,
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
                            onPressed: () => _callNgo(context, ngo.phone),
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
                            ngo.totalMealsReceived.toString(),
                            "Meals",
                          ),
                          const SizedBox(width: 10),
                          _statBox(
                            "${ngo.successRate}%",
                            "Success",
                          ),
                          const SizedBox(width: 10),
                          _statusBox(
                            isDeleted: ngo.isDeleted,
                            isSuspended: ngo.isSuspended,
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
                        ngo.aboutLabel,
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
                      onTap: () => _showNotificationDialog(context, service, ngo),
                    ),
                    Opacity(
                      opacity: ngo.isDeleted ? 0.45 : 1,
                      child: ListTile(
                        leading: Icon(
                          ngo.isSuspended ? Icons.check_circle : Icons.block,
                          color: ngo.isDeleted
                              ? Colors.grey
                              : (ngo.isSuspended ? primary : Colors.red),
                        ),
                        title: Text(
                          ngo.isSuspended ? "Unsuspend NGO" : "Suspend NGO",
                          style: TextStyle(
                            color: ngo.isDeleted
                                ? Colors.grey
                                : (ngo.isSuspended ? primary : Colors.red),
                          ),
                        ),
                        onTap: ngo.isDeleted
                            ? null
                            : () async {
                                if (ngo.isSuspended) {
                                  await service.unsuspendNgo(
                                    ngoId: ngo.id,
                                    ngoName: ngo.name,
                                  );

                                  if (!context.mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("NGO re-enabled successfully"),
                                    ),
                                  );
                                  return;
                                }

                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => SuspendNGOScreen(ngo: ngo),
                                  ),
                                );
                              },
                      ),
                    ),
                    Opacity(
                      opacity: ngo.isDeleted ? 0.45 : 1,
                      child: ListTile(
                        leading: Icon(
                          Icons.delete_forever,
                          color: ngo.isDeleted ? Colors.grey : Colors.red,
                        ),
                        title: Text(
                          "Delete Account",
                          style: TextStyle(
                            color: ngo.isDeleted ? Colors.grey : Colors.red,
                          ),
                        ),
                        onTap: ngo.isDeleted
                            ? null
                            : () => _confirmDeleteNgo(context, service, ngo),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
        );
      },
    );
  }

  static Widget _statBox(String value, String label) {
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
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _statusBox({
    required bool isDeleted,
    required bool isSuspended,
  }) {
    final backgroundColor = isDeleted
        ? const Color(0xFFFDECEC)
        : const Color(0xFFEDEDED);
    final textColor = isDeleted
        ? Colors.red
        : (isSuspended ? Colors.red.shade700 : primary);
    final IconData icon = isDeleted
        ? Icons.flag
        : (isSuspended ? Icons.block : Icons.check_circle);
    final String status = isDeleted
        ? 'Deleted'
        : (isSuspended ? 'Suspended' : 'Active');
    final String subtitle = isDeleted ? "Account Deleted" : "Status";

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: isDeleted
              ? Border.all(color: const Color(0xFFF5B5B5))
              : null,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: textColor),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                color: isDeleted ? const Color(0xFFC62828) : Colors.black54,
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
        Icons.apartment,
        size: 60,
        color: Colors.grey,
      ),
    );
  }

  void _showNotificationDialog(
    BuildContext context,
    AdminNgoManagementService service,
    AdminManagedNgo ngo,
  ) {
    final titleCtrl = TextEditingController();
    final msgCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Send Notification"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "To: ${ngo.name}",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titleCtrl,
                decoration: const InputDecoration(
                  labelText: "Title",
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: msgCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Message",
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
              ),
              onPressed: () async {
                if (titleCtrl.text.trim().isEmpty ||
                    msgCtrl.text.trim().isEmpty) {
                  return;
                }

                await service.sendNotificationToNgo(
                  ngoId: ngo.id,
                  ngoName: ngo.name,
                  title: titleCtrl.text.trim(),
                  message: msgCtrl.text.trim(),
                );

                if (!context.mounted) return;
                Navigator.pop(dialogContext);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Notification sent to NGO"),
                  ),
                );
              },
              child: const Text("Send"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _callNgo(BuildContext context, String phone) async {
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

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unable to open dialer"),
      ),
    );
  }

  Future<void> _confirmDeleteNgo(
    BuildContext context,
    AdminNgoManagementService service,
    AdminManagedNgo ngo,
  ) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Delete NGO account'),
            content: const Text(
              'This permanently deletes the NGO account. Historical records stay preserved for admin review, but all live links to the NGO are detached.',
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
      await service.deleteNgoAccount(
        ngoId: ngo.id,
        ngoName: ngo.name,
      );

      if (!context.mounted) {
        return;
      }

      Navigator.of(context, rootNavigator: true).pop();
      Navigator.of(context).pop();
      messenger.showSnackBar(
        const SnackBar(content: Text('NGO account deleted successfully')),
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
        const SnackBar(content: Text('Failed to delete NGO account')),
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
