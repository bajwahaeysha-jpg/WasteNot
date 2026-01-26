import 'package:flutter/material.dart';
import 'package:wastenot/features/admin/more/action_center/donation_issues/donation_issues_list_screen.dart';
import 'package:wastenot/features/admin/more/action_center/expired_donations/expired_donations_list_screen.dart';
import 'ngo_approvals/ngo_approval_list_screen.dart';

class ActionCenterScreen extends StatelessWidget {
  const ActionCenterScreen({super.key});

  static const Color mainGreen = Color(0xFF0F5F54);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true, // ✅ MUST be true
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        /// 🔙 ALWAYS BACK TO ADMIN HOME
        Navigator.popUntil(context, (route) => route.isFirst);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9F8),

        /// 🟢 APP BAR
        appBar: AppBar(
          backgroundColor: mainGreen,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
          title: const Text(
            "Action Center",
            style: TextStyle(color: Colors.white),
          ),
        ),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              _tile(
                context,
                Icons.verified_user_outlined,
                "NGO Approval Requests",
                "3 pending approvals",
                const NgoApprovalListScreen(),
              ),

              _tile(
                context,
                Icons.timer_off_outlined,
                "Expired Donations",
                "5 require review",
                const ExpiredDonationsListScreen(),
              ),

              _tile(
                context,
                Icons.report_problem_outlined,
                "Donation Issues",
                "2 flagged cases",
                const DonationIssuesListScreen(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tile(
    BuildContext context,
    IconData icon,
    String title,
    String subtitle,
    Widget screen,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: mainGreen.withValues(alpha: 0.12),
          child: Icon(icon, color: mainGreen),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => screen),
          );
        },
      ),
    );
  }
}
