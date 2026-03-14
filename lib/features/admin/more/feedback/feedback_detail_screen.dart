import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:wastenot/core/constants/app_colors.dart';

import 'feedback_model.dart';

class FeedbackDetailScreen extends StatelessWidget {
  const FeedbackDetailScreen({
    super.key,
    required this.feedback,
  });

  final FeedbackModel feedback;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Feedback Detail',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section(
            child: Row(
              children: [
                _ProfileAvatar(
                  name: feedback.complainantName,
                  imageUrl: feedback.complainantProfileImage,
                  radius: 30,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        feedback.complainantName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Complainant ${feedback.complainantRoleLabel}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        DateFormat('MMMM d, yyyy - h:mm a')
                            .format(feedback.timestamp),
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complaint About ${feedback.targetRoleLabel}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _ProfileAvatar(
                      name: feedback.complaintTargetName,
                      imageUrl: feedback.complaintTargetProfileImage,
                      radius: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        feedback.complaintTargetName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Rating',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (index) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          index < feedback.rating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber.shade700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${feedback.rating}/5',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _section(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Feedback Message',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  feedback.feedbackText,
                  style: const TextStyle(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _section({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({
    required this.name,
    required this.radius,
    this.imageUrl,
  });

  final String name;
  final String? imageUrl;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      backgroundImage:
          imageUrl != null && imageUrl!.isNotEmpty ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null || imageUrl!.isEmpty
          ? Text(
              initials.isEmpty ? 'WN' : initials,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: radius * 0.6,
              ),
            )
          : null,
    );
  }
}
