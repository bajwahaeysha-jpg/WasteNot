import 'package:cloud_firestore/cloud_firestore.dart';

class FeedbackModel {
  const FeedbackModel({
    required this.id,
    required this.ngoId,
    required this.ngoName,
    required this.donorId,
    required this.donorName,
    required this.feedbackText,
    required this.rating,
    required this.timestamp,
    required this.submittedByRole,
    this.ngoProfileImage,
    this.donorProfileImage,
  });

  final String id;
  final String ngoId;
  final String ngoName;
  final String? ngoProfileImage;
  final String donorId;
  final String donorName;
  final String? donorProfileImage;
  final String feedbackText;
  final int rating;
  final DateTime timestamp;
  final String submittedByRole;

  bool get submittedByDonor => submittedByRole == 'donor';

  String get complainantName => submittedByDonor ? donorName : ngoName;
  String? get complainantProfileImage =>
      submittedByDonor ? donorProfileImage : ngoProfileImage;

  String get complaintTargetName => submittedByDonor ? ngoName : donorName;
  String? get complaintTargetProfileImage =>
      submittedByDonor ? ngoProfileImage : donorProfileImage;

  String get complainantRoleLabel => submittedByDonor ? 'Donor' : 'NGO';
  String get targetRoleLabel => submittedByDonor ? 'NGO' : 'Donor';

  factory FeedbackModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};
    final rawTimestamp = data['timestamp'];

    return FeedbackModel(
      id: doc.id,
      ngoId: (data['ngoId'] as String?) ?? '',
      ngoName: (data['ngoName'] as String?) ?? 'NGO',
      ngoProfileImage: data['ngoProfileImage'] as String?,
      donorId: (data['donorId'] as String?) ?? '',
      donorName: (data['donorName'] as String?) ?? 'Donor',
      donorProfileImage: data['donorProfileImage'] as String?,
      feedbackText: (data['feedbackText'] as String?) ?? '',
      rating: (data['rating'] as num?)?.toInt() ?? 0,
      submittedByRole: (data['submittedByRole'] as String?) ?? 'ngo',
      timestamp: rawTimestamp is Timestamp
          ? rawTimestamp.toDate()
          : DateTime.fromMillisecondsSinceEpoch(0),
    );
  }
}
