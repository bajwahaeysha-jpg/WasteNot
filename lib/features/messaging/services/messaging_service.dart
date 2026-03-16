import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:wastenot/features/messaging/models/chat_models.dart';
import 'package:wastenot/models/app_user_model.dart';

class MessagingService {
  MessagingService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _conversations =>
      _firestore.collection('conversations');

  CollectionReference<Map<String, dynamic>> _messages(String conversationId) =>
      _conversations.doc(conversationId).collection('messages');

  String conversationIdFor(String firstUserId, String secondUserId) {
    final ids = [firstUserId, secondUserId]..sort();
    return ids.join('_');
  }

  Stream<List<AppUserModel>> usersForRole(String role) {
    return _users.where('role', isEqualTo: role).snapshots().map((snapshot) {
      final users = snapshot.docs.map(AppUserModel.fromFirestore).toList()
        ..sort((a, b) => a.displayName.toLowerCase().compareTo(
              b.displayName.toLowerCase(),
            ));
      return users;
    });
  }

  Stream<List<ConversationSummary>> conversationsForUser(String userId) {
    return _conversations
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      final conversations = snapshot.docs
          .map(ConversationSummary.fromFirestore)
          .toList()
        ..sort((a, b) {
          final aTime = a.updatedAt ?? a.lastMessageTime ?? a.createdAt;
          final bTime = b.updatedAt ?? b.lastMessageTime ?? b.createdAt;
          if (aTime == null && bTime == null) {
            return 0;
          }
          if (aTime == null) {
            return 1;
          }
          if (bTime == null) {
            return -1;
          }
          return bTime.compareTo(aTime);
        });
      return conversations;
    });
  }

  Stream<int> unreadConversationCount(String userId) {
    return conversationsForUser(userId).map(
      (conversations) =>
          conversations.where((item) => item.unreadFor(userId) > 0).length,
    );
  }

  Stream<List<ConversationMessage>> messagesForConversation(
    String conversationId,
    String currentUserId,
  ) {
    return _messages(conversationId).orderBy('sentAt').snapshots().map((
      snapshot,
    ) {
      return snapshot.docs
          .map(ConversationMessage.fromFirestore)
          .where((message) => message.isVisibleTo(currentUserId))
          .toList();
    });
  }

  Future<AppUserModel?> findUserByDisplayNameAndRole(
    String displayName,
    String role,
  ) async {
    final normalized = displayName.trim().toLowerCase();
    if (normalized.isEmpty) {
      return null;
    }

    final snapshot = await _users.where('role', isEqualTo: role).get();
    final users = snapshot.docs.map(AppUserModel.fromFirestore);

    for (final user in users) {
      if (user.displayName.trim().toLowerCase() == normalized) {
        return user;
      }
    }

    return null;
  }

  Future<void> sendMessage({
    required AppUserModel sender,
    required AppUserModel receiver,
    required String text,
  }) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final conversationId = conversationIdFor(sender.uid, receiver.uid);
    final conversationRef = _conversations.doc(conversationId);
    final messageRef = _messages(conversationId).doc();

    await _firestore.runTransaction((transaction) async {
      final conversationSnapshot = await transaction.get(conversationRef);
      final currentUnread = <String, int>{};

      if (conversationSnapshot.exists) {
        final raw = conversationSnapshot.data()?['unreadCounts'];
        if (raw is Map) {
          for (final entry in raw.entries) {
            currentUnread[entry.key.toString()] =
                (entry.value as num?)?.toInt() ?? 0;
          }
        }
      }

      transaction.set(messageRef, {
        'type': 'text',
        'text': trimmed,
        'senderId': sender.uid,
        'senderRole': sender.role,
        'receiverId': receiver.uid,
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'readAt': null,
        'deletedFor': <String>[],
      });

      transaction.set(conversationRef, {
        'participants': [sender.uid, receiver.uid]..sort(),
        'participantRoles': {
          sender.uid: sender.role,
          receiver.uid: receiver.role,
        },
        'participantNames': {
          sender.uid: sender.displayName,
          receiver.uid: receiver.displayName,
        },
        'participantProfileImages': {
          sender.uid: sender.profileImageUrl,
          receiver.uid: receiver.profileImageUrl,
        },
        'lastMessage': trimmed,
        'lastMessageSenderId': sender.uid,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageByUser': {
          sender.uid: trimmed,
          receiver.uid: trimmed,
        },
        'lastMessageTimeByUser': {
          sender.uid: FieldValue.serverTimestamp(),
          receiver.uid: FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCounts': {
          sender.uid: 0,
          receiver.uid: (currentUnread[receiver.uid] ?? 0) + 1,
        },
        if (!conversationSnapshot.exists)
          'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> sendConcernReference({
    required AppUserModel sender,
    required AppUserModel receiver,
    required ConcernChatReference reference,
  }) async {
    final title = reference.concernTitle.trim();
    final messageText = title.isEmpty
        ? 'Donor is contacting regarding this concern.'
        : 'Donor is contacting regarding: $title';
    final preview = title.isEmpty ? 'Concern' : 'Concern: $title';

    final conversationId = conversationIdFor(sender.uid, receiver.uid);
    final conversationRef = _conversations.doc(conversationId);
    final messageRef = _messages(conversationId).doc();

    await _firestore.runTransaction((transaction) async {
      final conversationSnapshot = await transaction.get(conversationRef);
      final currentUnread = <String, int>{};

      if (conversationSnapshot.exists) {
        final raw = conversationSnapshot.data()?['unreadCounts'];
        if (raw is Map) {
          for (final entry in raw.entries) {
            currentUnread[entry.key.toString()] =
                (entry.value as num?)?.toInt() ?? 0;
          }
        }
      }

      transaction.set(messageRef, {
        'type': 'concern_reference',
        'text': messageText,
        ...reference.toMessageFields(),
        'senderId': sender.uid,
        'senderRole': sender.role,
        'receiverId': receiver.uid,
        'sentAt': FieldValue.serverTimestamp(),
        'isRead': false,
        'readAt': null,
        'deletedFor': <String>[],
      });

      transaction.set(conversationRef, {
        'participants': [sender.uid, receiver.uid]..sort(),
        'participantRoles': {
          sender.uid: sender.role,
          receiver.uid: receiver.role,
        },
        'participantNames': {
          sender.uid: sender.displayName,
          receiver.uid: receiver.displayName,
        },
        'participantProfileImages': {
          sender.uid: sender.profileImageUrl,
          receiver.uid: receiver.profileImageUrl,
        },
        'lastMessage': preview,
        'lastMessageSenderId': sender.uid,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessageByUser': {
          sender.uid: preview,
          receiver.uid: preview,
        },
        'lastMessageTimeByUser': {
          sender.uid: FieldValue.serverTimestamp(),
          receiver.uid: FieldValue.serverTimestamp(),
        },
        'updatedAt': FieldValue.serverTimestamp(),
        'unreadCounts': {
          sender.uid: 0,
          receiver.uid: (currentUnread[receiver.uid] ?? 0) + 1,
        },
        if (!conversationSnapshot.exists)
          'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> ensureConcernReferenceSent({
    required AppUserModel sender,
    required AppUserModel receiver,
    required ConcernChatReference reference,
  }) async {
    final conversationId = conversationIdFor(sender.uid, receiver.uid);
    final existing = await _messages(conversationId)
        .where('type', isEqualTo: 'concern_reference')
        .where('referenceConcernId', isEqualTo: reference.concernId)
        .where('senderId', isEqualTo: sender.uid)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) {
      return;
    }

    await sendConcernReference(
      sender: sender,
      receiver: receiver,
      reference: reference,
    );
  }

  Future<void> markConversationAsRead({
    required String conversationId,
    required String currentUserId,
  }) async {
    final unreadSnapshot = await _messages(conversationId)
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    if (unreadSnapshot.docs.isEmpty) {
      await _conversations.doc(conversationId).set({
        'unreadCounts': {currentUserId: 0},
      }, SetOptions(merge: true));
      return;
    }

    final batch = _firestore.batch();
    for (final doc in unreadSnapshot.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    batch.set(_conversations.doc(conversationId), {
      'unreadCounts': {currentUserId: 0},
    }, SetOptions(merge: true));
    await batch.commit();

    await refreshConversationMetadata(conversationId: conversationId);
  }

  Future<void> deleteForMe({
    required String conversationId,
    required String messageId,
    required String currentUserId,
  }) async {
    await _messages(conversationId).doc(messageId).set({
      'deletedFor': FieldValue.arrayUnion([currentUserId]),
    }, SetOptions(merge: true));

    await refreshConversationMetadata(
      conversationId: conversationId,
      userIdsToRefresh: [currentUserId],
    );
  }

  Future<void> unsendMessage({
    required String conversationId,
    required ConversationMessage message,
    required String currentUserId,
  }) async {
    if (message.senderId != currentUserId) {
      throw StateError('Only the sender can unsend this message.');
    }

    await _messages(conversationId).doc(message.id).delete();
    await refreshConversationMetadata(conversationId: conversationId);
  }

  Future<void> refreshConversationMetadata({
    required String conversationId,
    List<String>? userIdsToRefresh,
  }) async {
    final conversationRef = _conversations.doc(conversationId);
    final conversationSnapshot = await conversationRef.get();
    if (!conversationSnapshot.exists) {
      return;
    }

    final conversation = ConversationSummary.fromFirestore(conversationSnapshot);
    final messageSnapshot = await _messages(conversationId).orderBy(
      'sentAt',
      descending: true,
    ).get();
    final allMessages = messageSnapshot.docs.map(ConversationMessage.fromFirestore).toList();

    final participantIds = userIdsToRefresh ?? conversation.participants;
    final lastMessageByUser = Map<String, String>.from(conversation.lastMessageByUser);
    final lastMessageTimeByUser =
        Map<String, DateTime?>.from(conversation.lastMessageTimeByUser);
    final unreadCounts = <String, int>{};

    for (final participantId in conversation.participants) {
      unreadCounts[participantId] = allMessages.where((message) {
        return message.receiverId == participantId &&
            !message.isRead &&
            message.isVisibleTo(participantId);
      }).length;
    }

    for (final participantId in participantIds) {
      final latestVisible = allMessages.cast<ConversationMessage?>().firstWhere(
            (message) => message != null && message.isVisibleTo(participantId),
            orElse: () => null,
          );
      if (latestVisible == null) {
        lastMessageByUser[participantId] = '';
        lastMessageTimeByUser[participantId] = null;
      } else {
        lastMessageByUser[participantId] = latestVisible.text;
        lastMessageTimeByUser[participantId] = latestVisible.sentAt;
      }
    }

    final sharedLatest =
        allMessages.isNotEmpty ? allMessages.first : null;
    final updatedAt = sharedLatest?.sentAt ?? conversation.updatedAt ?? conversation.createdAt;

    await conversationRef.set({
      'lastMessage': sharedLatest?.text ?? '',
      'lastMessageSenderId': sharedLatest?.senderId ?? '',
      'lastMessageTime': _timestampOrNull(sharedLatest?.sentAt),
      'updatedAt': _timestampOrNull(updatedAt),
      'lastMessageByUser': lastMessageByUser,
      'lastMessageTimeByUser':
          lastMessageTimeByUser.map((key, value) => MapEntry(key, _timestampOrNull(value))),
      'unreadCounts': unreadCounts,
    }, SetOptions(merge: true));
  }

  Timestamp? _timestampOrNull(DateTime? value) {
    return value == null ? null : Timestamp.fromDate(value);
  }
}
