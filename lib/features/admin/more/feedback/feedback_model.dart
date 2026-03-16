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
  bool get submittedByNgo => submittedByRole == 'ngo';

  String get senderId => submittedByDonor ? donorId : ngoId;
  String get senderName => submittedByDonor ? donorName : ngoName;
  String? get senderProfileImage =>
      submittedByDonor ? donorProfileImage : ngoProfileImage;
  String get senderRoleLabel => submittedByDonor ? 'Donor' : 'NGO';

  String get targetId => submittedByDonor ? ngoId : donorId;
  String get targetName => submittedByDonor ? ngoName : donorName;
  String? get targetProfileImage =>
      submittedByDonor ? ngoProfileImage : donorProfileImage;
  String get targetRoleLabel => submittedByDonor ? 'NGO' : 'Donor';

  String get complainantName => senderName;
  String? get complainantProfileImage => senderProfileImage;
  String get complaintTargetName => targetName;
  String? get complaintTargetProfileImage => targetProfileImage;
  String get complainantRoleLabel => senderRoleLabel;

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
