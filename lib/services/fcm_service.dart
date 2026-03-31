import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wastenot/features/admin/quick_actions/requests/requests_screen.dart';
import 'package:wastenot/features/donor/presentation/donate/screens/add_donation_screen.dart';
import 'package:wastenot/features/donor/presentation/home/screens/expired_donations_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/all_donations/all_donations_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';
import 'package:wastenot/services/session_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class FcmService {
  FcmService._();

  static final FcmService instance = FcmService._();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;
  String? _currentUserRoleTopic;
  String? _currentToken;
  String? _currentTokenOwnerUid;
  Map<String, dynamic>? _pendingNavigationData;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _initializeLocalNotifications();

      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        announcement: false,
        criticalAlert: false,
        provisional: false,
        carPlay: false,
      );

      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(
        (message) => _handleMessageTap(message.data),
      );
      _messaging.onTokenRefresh.listen(_handleTokenRefresh);

      SessionService.currentUser.addListener(_handleSessionChanged);
      await _syncSessionState();

      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageTap(initialMessage.data);
      }
    } catch (error, stackTrace) {
      debugPrint('FCM initialization skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> unregisterCurrentDevice() async {
    final user = SessionService.user;
    if (user != null) {
      await _deleteTokenForUser(user.uid);
    }

    if (_currentUserRoleTopic != null) {
      await _messaging.unsubscribeFromTopic(_currentUserRoleTopic!);
      _currentUserRoleTopic = null;
    }

    _currentTokenOwnerUid = null;
  }

  Future<void> drainPendingNavigationIfPossible() async {
    final data = _pendingNavigationData;
    if (data == null) {
      return;
    }

    if (!_canNavigateNow()) {
      return;
    }

    _pendingNavigationData = null;
    await _navigateFromData(data);
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) async {
        final rawPayload = response.payload;
        if (rawPayload == null || rawPayload.isEmpty) {
          return;
        }

        final decoded = jsonDecode(rawPayload);
        if (decoded is Map<String, dynamic>) {
          await _handleMessageTap(decoded);
        } else if (decoded is Map) {
          await _handleMessageTap(
            decoded.map(
              (key, value) => MapEntry(key.toString(), value),
            ),
          );
        }
      },
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'wastenot_fcm_channel',
      'WasteNot Notifications',
      channelDescription: 'Foreground notifications for WasteNot',
      importance: Importance.max,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();

    await _localNotifications.show(
      title.hashCode ^ body.hashCode,
      title,
      body,
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _handleTokenRefresh(String token) async {
    _currentToken = token;
    final user = SessionService.user;
    if (user == null) {
      return;
    }

    await _saveTokenForUser(user, token);
  }

  Future<void> _handleSessionChanged() async {
    await _syncSessionState();
    await drainPendingNavigationIfPossible();
  }

  Future<void> _syncSessionState() async {
    final user = SessionService.user;
    await _syncRoleTopic(user);

    if (user == null) {
      _currentTokenOwnerUid = null;
      return;
    }

    final token = _currentToken ?? await _messaging.getToken();
    if (token == null || token.trim().isEmpty) {
      return;
    }

    _currentToken = token;
    try {
      await _saveTokenForUser(user, token);
    } catch (error) {
      debugPrint('FCM token sync failed for ${user.uid}: $error');
    }
  }

  Future<void> _syncRoleTopic(AppUserModel? user) async {
    final nextTopic = _roleTopicForUser(user);
    if (_currentUserRoleTopic == nextTopic) {
      return;
    }

    if (_currentUserRoleTopic != null) {
      await _messaging.unsubscribeFromTopic(_currentUserRoleTopic!);
    }

    _currentUserRoleTopic = nextTopic;

    if (nextTopic != null) {
      await _messaging.subscribeToTopic(nextTopic);
    }
  }

  String? _roleTopicForUser(AppUserModel? user) {
    if (user == null) {
      return null;
    }

    if (user.isAdmin) {
      return 'role_admin';
    }
    if (user.isNgo) {
      return 'role_ngo';
    }
    if (user.isDonor) {
      return 'role_donor';
    }
    return null;
  }

  Future<void> _saveTokenForUser(AppUserModel user, String token) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      return;
    }

    if (_currentTokenOwnerUid != null && _currentTokenOwnerUid != user.uid) {
      await _deleteTokenForUser(_currentTokenOwnerUid!);
    }

    final tokenDoc = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('fcm_tokens')
        .doc(normalizedToken);

    await tokenDoc.set(<String, dynamic>{
      'token': normalizedToken,
      'role': user.role,
      'platform': _platformName(),
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'isActive': true,
    }, SetOptions(merge: true));

    await _firestore.collection('users').doc(user.uid).set(<String, dynamic>{
      'latestFcmToken': normalizedToken,
      'lastFcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _currentTokenOwnerUid = user.uid;
  }

  Future<void> _deleteTokenForUser(String uid) async {
    final normalizedUid = uid.trim();
    final normalizedToken = _currentToken?.trim();
    if (normalizedUid.isEmpty || normalizedToken == null || normalizedToken.isEmpty) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(normalizedUid)
        .collection('fcm_tokens')
        .doc(normalizedToken)
        .delete()
        .catchError((_) {});
  }

  String _platformName() {
    if (kIsWeb) {
      return 'web';
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return 'android';
      case TargetPlatform.iOS:
        return 'ios';
      case TargetPlatform.macOS:
        return 'macos';
      case TargetPlatform.windows:
        return 'windows';
      case TargetPlatform.linux:
        return 'linux';
      case TargetPlatform.fuchsia:
        return 'fuchsia';
    }
  }

  Future<void> _handleMessageTap(Map<String, dynamic> data) async {
    if (!_canNavigateNow()) {
      _pendingNavigationData = Map<String, dynamic>.from(data);
      return;
    }

    await _navigateFromData(data);
  }

  bool _canNavigateNow() {
    return navigatorKey.currentState != null && SessionService.user != null;
  }

  Future<void> _navigateFromData(Map<String, dynamic> data) async {
    final navigator = navigatorKey.currentState;
    final user = SessionService.user;
    if (navigator == null || user == null) {
      _pendingNavigationData = Map<String, dynamic>.from(data);
      return;
    }

    final navigation =
        (data['navigation'] ?? data['screen'] ?? '').toString().trim();
    final type = (data['type'] ?? '').toString().trim();
    final key = navigation.isNotEmpty ? navigation : type;

    final route = switch (key) {
      'admin_ngo_requests' || 'NEW_NGO_REGISTRATION' when user.isAdmin =>
        MaterialPageRoute<void>(builder: (_) => const RequestsScreen()),
      'ngo_dashboard' || 'NGO_APPROVED' when user.isNgo =>
        AppNavigationHandler.homeRoute(user),
      'available_donations' ||
      'NEW_DONATION' ||
      'DONATION_EXPIRING_SOON' when user.isNgo =>
        MaterialPageRoute<void>(builder: (_) => const AllDonationsScreen()),
      'donation_form' || 'DONOR_REMINDER' when user.isDonor =>
        MaterialPageRoute<void>(builder: (_) => const AddDonationScreen()),
      'donor_expired_donations' || 'DONATION_EXPIRED' when user.isDonor =>
        MaterialPageRoute<void>(builder: (_) => const ExpiredDonationsScreen()),
      _ => null,
    };

    if (route == null) {
      return;
    }

    await navigator.push(route);
  }
}
