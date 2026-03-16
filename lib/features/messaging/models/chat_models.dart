import 'package:cloud_firestore/cloud_firestore.dart';

class ConcernChatReference {
  const ConcernChatReference({
    required this.concernId,
    required this.concernTitle,
    required this.concernImageUrl,
    required this.ngoId,
  });

  final String concernId;
  final String concernTitle;
  final String concernImageUrl;
  final String ngoId;

  Map<String, dynamic> toMessageFields() {
    return {
      'referenceConcernId': concernId,
      'referenceConcernTitle': concernTitle,
      'referenceConcernImageUrl': concernImageUrl,
      'referenceNgoId': ngoId,
    };
  }

  factory ConcernChatReference.fromMessage(Map<String, dynamic> data) {
    return ConcernChatReference(
      concernId: (data['referenceConcernId'] as String?) ?? '',
      concernTitle: (data['referenceConcernTitle'] as String?) ?? '',
      concernImageUrl: (data['referenceConcernImageUrl'] as String?) ?? '',
      ngoId: (data['referenceNgoId'] as String?) ?? '',
    );
  }
}

class ConversationSummary {
  const ConversationSummary({
    required this.id,
    required this.participants,
    required this.participantRoles,
    required this.participantNames,
    required this.participantProfileImages,
    required this.lastMessage,
    required this.lastMessageSenderId,
    required this.lastMessageTime,
    required this.lastMessageByUser,
    required this.lastMessageTimeByUser,
    required this.updatedAt,
    required this.createdAt,
    required this.unreadCounts,
  });

  final String id;
  final List<String> participants;
  final Map<String, String> participantRoles;
  final Map<String, String> participantNames;
  final Map<String, String?> participantProfileImages;
  final String lastMessage;
  final String lastMessageSenderId;
  final DateTime? lastMessageTime;
  final Map<String, String> lastMessageByUser;
  final Map<String, DateTime?> lastMessageTimeByUser;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final Map<String, int> unreadCounts;

  String otherParticipantId(String currentUserId) {
    for (final participant in participants) {
      if (participant != currentUserId) {
        return participant;
      }
    }
    return '';
  }

  String titleFor(String currentUserId) {
    final peerId = otherParticipantId(currentUserId);
    return participantNames[peerId] ?? 'User';
  }

  String? profileImageFor(String currentUserId) {
    final peerId = otherParticipantId(currentUserId);
    return participantProfileImages[peerId];
  }

  String previewFor(String currentUserId) {
    final preview = lastMessageByUser[currentUserId];
    if (preview != null && preview.trim().isNotEmpty) {
      return preview;
    }
    return lastMessage;
  }

  DateTime? previewTimeFor(String currentUserId) {
    return lastMessageTimeByUser[currentUserId] ?? lastMessageTime ?? updatedAt;
  }

  int unreadFor(String currentUserId) {
    return unreadCounts[currentUserId] ?? 0;
  }

  factory ConversationSummary.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? <String, dynamic>{};

    return ConversationSummary(
      id: doc.id,
      participants: (data['participants'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      participantRoles: _stringMap(data['participantRoles']),
      participantNames: _stringMap(data['participantNames']),
      participantProfileImages: _nullableStringMap(
        data['participantProfileImages'],
      ),
      lastMessage: (data['lastMessage'] as String?) ?? '',
      lastMessageSenderId: (data['lastMessageSenderId'] as String?) ?? '',
      lastMessageTime: _dateTime(data['lastMessageTime']),
      lastMessageByUser: _stringMap(data['lastMessageByUser']),
      lastMessageTimeByUser: _nullableDateMap(data['lastMessageTimeByUser']),
      updatedAt: _dateTime(data['updatedAt']),
      createdAt: _dateTime(data['createdAt']),
      unreadCounts: _intMap(data['unreadCounts']),
    );
  }

  static Map<String, String> _stringMap(dynamic raw) {
    if (raw is! Map) {
      return const <String, String>{};
    }
    return raw.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );
  }

  static Map<String, String?> _nullableStringMap(dynamic raw) {
    if (raw is! Map) {
      return const <String, String?>{};
    }
    return raw.map(
      (key, value) => MapEntry(key.toString(), value?.toString()),
    );
  }

  static Map<String, int> _intMap(dynamic raw) {
    if (raw is! Map) {
      return const <String, int>{};
    }
    return raw.map(
      (key, value) => MapEntry(key.toString(), (value as num?)?.toInt() ?? 0),
    );
  }

  static Map<String, DateTime?> _nullableDateMap(dynamic raw) {
    if (raw is! Map) {
      return const <String, DateTime?>{};
    }
    return raw.map(
      (key, value) => MapEntry(key.toString(), _dateTime(value)),
    );
  }

  static DateTime? _dateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}

class ConversationMessage {
  const ConversationMessage({
    required this.id,
    required this.text,
    required this.type,
    required this.senderId,
    required this.senderRole,
    required this.receiverId,
    required this.sentAt,
    required this.isRead,
    required this.readAt,
    required this.deletedFor,
    required this.hasPendingWrites,
    this.concernReference,
  });

  final String id;
  final String text;
  final String type; // 'text' | 'concern_reference'
  final String senderId;
  final String senderRole;
  final String receiverId;
  final DateTime? sentAt;
  final bool isRead;
  final DateTime? readAt;
  final List<String> deletedFor;
  final bool hasPendingWrites;
  final ConcernChatReference? concernReference;

  bool isVisibleTo(String userId) => !deletedFor.contains(userId);

  bool isFrom(String userId) => senderId == userId;

  factory ConversationMessage.fromFirestore(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final type = (data['type'] as String?) ?? 'text';
    final reference = type == 'concern_reference'
        ? ConcernChatReference.fromMessage(data)
        : null;

    return ConversationMessage(
      id: doc.id,
      text: (data['text'] as String?) ?? '',
      type: type,
      senderId: (data['senderId'] as String?) ?? '',
      senderRole: (data['senderRole'] as String?) ?? '',
      receiverId: (data['receiverId'] as String?) ?? '',
      sentAt: _dateTime(data['sentAt']),
      isRead: (data['isRead'] as bool?) ?? false,
      readAt: _dateTime(data['readAt']),
      deletedFor: (data['deletedFor'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(),
      hasPendingWrites: doc.metadata.hasPendingWrites,
      concernReference: reference?.concernId.trim().isEmpty == true ? null : reference,
    );
  }

  static DateTime? _dateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    return null;
  }
}
