import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/models/ngo_request_model.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';
import 'package:wastenot/services/auth_service.dart';
import 'package:wastenot/services/firestore_service.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final AuthService _authService = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF0B4B3F),
          foregroundColor: Colors.white,
          title: const Text('Admin Panel'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Donors'),
              Tab(text: 'NGOs'),
              Tab(text: 'Requests'),
            ],
          ),
          actions: [
            IconButton(
              onPressed: _busy ? null : _logout,
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: Stack(
          children: [
            TabBarView(
              children: [
                _buildUsersSection(role: 'donor', emptyLabel: 'No donors found.'),
                _buildUsersSection(role: 'ngo', emptyLabel: 'No NGOs found.'),
                _buildNgoRequestsSection(),
              ],
            ),
            if (_busy)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0x33000000),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersSection({
    required String role,
    required String emptyLabel,
  }) {
    return StreamBuilder<List<AppUserModel>>(
      stream: _firestoreService.usersByRole(role),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = snapshot.data!;
        if (users.isEmpty) {
          return Center(child: Text(emptyLabel));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ExpansionTile(
                title: Text(user.displayName),
                subtitle: Text(user.email),
                childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                children: [
                  _detailRow('Role', user.role),
                  _detailRow('Phone', user.phone ?? 'Not provided'),
                  _detailRow('Address', user.address ?? 'Not provided'),
                  if (user.registrationNumber != null)
                    _detailRow('Registration #', user.registrationNumber!),
                  if (user.organizationDescription != null)
                    _detailRow('Description', user.organizationDescription!),
                  _detailRow('Created', DateFormat.yMMMd().add_jm().format(user.createdAt)),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNgoRequestsSection() {
    return StreamBuilder<List<NgoRequestModel>>(
      stream: _firestoreService.pendingNgoRequests(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final requests = snapshot.data!;
        if (requests.isEmpty) {
          return const Center(child: Text('No pending NGO requests.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.organizationName,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text(request.email),
                    const SizedBox(height: 12),
                    _detailRow('Phone', request.phone),
                    _detailRow('Address', request.address),
                    _detailRow('Registration #', request.registrationNumber),
                    _detailRow('Description', request.description),
                    _detailRow(
                      'Submitted',
                      DateFormat.yMMMd().add_jm().format(request.createdAt),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _busy ? null : () => _approveRequest(request),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0B8A5A),
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Approve'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy ? null : () => _rejectRequest(request),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Reject'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }

  Future<void> _approveRequest(NgoRequestModel request) async {
    setState(() => _busy = true);
    try {
      await _firestoreService.approveNgoRequest(request);
      _showMessage('NGO approved successfully.');
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _rejectRequest(NgoRequestModel request) async {
    setState(() => _busy = true);
    try {
      await _firestoreService.rejectNgoRequest(request.id);
      _showMessage('NGO request rejected.');
    } catch (error) {
      _showMessage(error.toString(), isError: true);
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _logout() async {
    await _authService.logout();
    if (!mounted) {
      return;
    }

    AppNavigationHandler.goToLogin(context);
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message.replaceFirst('Exception: ', '')),
        backgroundColor: isError ? Colors.red : const Color(0xFF0B4B3F),
      ),
    );
  }
}
