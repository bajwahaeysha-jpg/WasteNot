import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wastenot/features/admin/quick_actions/requests/requests_screen.dart';
import 'package:wastenot/features/donor/presentation/donate/screens/add_donation_screen.dart';
import 'package:wastenot/features/donor/presentation/home/screens/accepted_donations_screen.dart';
import 'package:wastenot/features/donor/presentation/home/screens/expired_donations_screen.dart';
import 'package:wastenot/features/donor/presentation/home/screens/your_donations_screen.dart';
import 'package:wastenot/features/ngo/presentation/screens/home/all_donations/all_donations_screen.dart';
import 'package:wastenot/models/app_user_model.dart';
import 'package:wastenot/navigation/app_navigation_handler.dart';
import 'package:wastenot/services/session_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint(
    'FCM background message received: id=${message.messageId} data=${message.data}',
  );
}

class FcmService {
  FcmService._();

  static const String channelId = 'wastenot_fcm_channel';
  static const String channelName = 'WasteNot Notifications';
  static const String channelDescription =
      'Real-time notifications for WasteNot donations and approvals';

  static final FcmService instance = FcmService._();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _initialized = false;
  bool _isSessionSyncInProgress = false;
  String? _currentUserRoleTopic;
  String? _currentToken;
  String? _currentTokenOwnerUid;
  String? _lastSessionSyncUid;
  String? _lastSessionSyncedToken;
  Map<String, dynamic>? _pendingNavigationData;

  String? get currentToken => _currentToken;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      await _initializeLocalNotifications();
      await _requestNotificationPermissions();

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

      final launchDetails =
          await _localNotifications.getNotificationAppLaunchDetails();
      final launchPayload =
          launchDetails?.notificationResponse?.payload?.trim() ?? '';
      if (launchPayload.isNotEmpty) {
        final decoded = jsonDecode(launchPayload);
        if (decoded is Map<String, dynamic>) {
          _pendingNavigationData = decoded;
        } else if (decoded is Map) {
          _pendingNavigationData = decoded.map(
            (key, value) => MapEntry(key.toString(), value),
          );
        }
      }

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
        AndroidInitializationSettings('@drawable/ic_stat_notification');
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

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        channelId,
        channelName,
        description: channelDescription,
        importance: Importance.max,
      );
      await androidPlugin.createNotificationChannel(channel);
    }
  }

  Future<void> _requestNotificationPermissions() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      criticalAlert: false,
      provisional: false,
      carPlay: false,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    final title = message.notification?.title ?? message.data['title'] ?? '';
    final body = message.notification?.body ?? message.data['body'] ?? '';

    if (title.isEmpty && body.isEmpty) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      icon: '@drawable/ic_stat_notification',
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
    final normalizedToken = token.trim();
    final previousToken = _currentToken?.trim();
    _currentToken = normalizedToken;

    if (normalizedToken.isEmpty) {
      debugPrint('FCM token refresh ignored because the token is empty.');
      return;
    }

    if (previousToken == normalizedToken) {
      debugPrint('FCM token refresh skipped because the token did not change.');
    } else {
      debugPrint(
        'FCM token changed: ${previousToken ?? '<null>'} -> $normalizedToken',
      );
    }

    final user = SessionService.user;
    if (user == null) {
      debugPrint('FCM token refresh skipped because no user is signed in.');
      return;
    }

    await _saveTokenForUser(user, normalizedToken, source: 'token_refresh');
  }

  Future<void> _handleSessionChanged() async {
    await _syncSessionState();
    await drainPendingNavigationIfPossible();
  }

  Future<void> _syncSessionState() async {
    if (_isSessionSyncInProgress) {
      debugPrint('FCM session sync skipped because another sync is in progress.');
      return;
    }

    _isSessionSyncInProgress = true;
    final user = SessionService.user;
    try {
      await _syncRoleTopic(user);

      if (user == null) {
        _currentTokenOwnerUid = null;
        _lastSessionSyncUid = null;
        _lastSessionSyncedToken = null;
        return;
      }

      final token = await getDeviceToken(forceRefresh: false);
      final normalizedToken = token?.trim() ?? '';
      if (normalizedToken.isEmpty) {
        debugPrint('FCM session sync skipped for ${user.uid}: token is empty.');
        return;
      }

      _currentToken = normalizedToken;
      if (_lastSessionSyncUid == user.uid &&
          _lastSessionSyncedToken == normalizedToken &&
          _currentTokenOwnerUid == user.uid) {
        debugPrint(
          'FCM session sync skipped for ${user.uid}: token unchanged.',
        );
        return;
      }

      try {
        await _saveTokenForUser(
          user,
          normalizedToken,
          source: 'session_listener',
        );
        _lastSessionSyncUid = user.uid;
        _lastSessionSyncedToken = normalizedToken;
      } catch (error) {
        debugPrint('FCM token sync failed for ${user.uid}: $error');
      }
    } finally {
      _isSessionSyncInProgress = false;
    }
  }

  Future<void> syncTokenForSignedInUser({bool forceRefresh = false}) async {
    final user = SessionService.user;
    if (user == null) {
      debugPrint('FCM sync skipped because there is no signed-in user.');
      return;
    }

    final token = await getDeviceToken(forceRefresh: forceRefresh);
    final normalizedToken = token?.trim() ?? '';
    if (normalizedToken.isEmpty) {
      debugPrint('FCM sync skipped for ${user.uid}: token is empty.');
      return;
    }

    _currentToken = normalizedToken;
    await _saveTokenForUser(
      user,
      normalizedToken,
      source: forceRefresh ? 'manual_forced_sync' : 'manual_sync',
    );
    _lastSessionSyncUid = user.uid;
    _lastSessionSyncedToken = normalizedToken;
    debugPrint('FCM token sync completed for ${user.uid}: $normalizedToken');
  }

  Future<String?> getDeviceToken({bool forceRefresh = false}) async {
    if (!forceRefresh && _currentToken != null && _currentToken!.trim().isNotEmpty) {
      return _currentToken;
    }

    final token = await _messaging.getToken();
    _currentToken = token?.trim();
    debugPrint('FCM getToken result: ${_currentToken ?? '<null>'}');
    return _currentToken;
  }

  Future<void> _syncRoleTopic(AppUserModel? user) async {
    final nextTopic = _roleTopicForUser(user);
    if (_currentUserRoleTopic == nextTopic) {
      return;
    }

    if (_currentUserRoleTopic != null) {
      debugPrint('FCM unsubscribing from topic $_currentUserRoleTopic');
      await _messaging.unsubscribeFromTopic(_currentUserRoleTopic!);
    }

    _currentUserRoleTopic = nextTopic;

    if (nextTopic != null) {
      debugPrint('FCM subscribing to topic $nextTopic');
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

  Future<void> _saveTokenForUser(
    AppUserModel user,
    String token, {
    required String source,
  }) async {
    final normalizedToken = token.trim();
    if (normalizedToken.isEmpty) {
      debugPrint('FCM token save skipped for ${user.uid}: token is empty.');
      return;
    }

    if (_currentTokenOwnerUid != null && _currentTokenOwnerUid != user.uid) {
      await _deleteTokenForUser(_currentTokenOwnerUid!);
    }

    final userDoc = _firestore.collection('users').doc(user.uid);
    final tokenDoc = userDoc.collection('fcm_tokens').doc(normalizedToken);
    final platform = _platformName();

    final snapshots = await Future.wait([
      tokenDoc.get(),
      userDoc.get(),
    ]);
    final tokenSnapshot = snapshots[0] as DocumentSnapshot<Map<String, dynamic>>;
    final userSnapshot = snapshots[1] as DocumentSnapshot<Map<String, dynamic>>;
    final tokenData = tokenSnapshot.data() ?? <String, dynamic>{};
    final latestUserToken =
        (userSnapshot.data()?['latestFcmToken'] as String? ?? '').trim();
    final tokenAlreadyActive =
        tokenSnapshot.exists &&
        (tokenData['token'] as String? ?? '').trim() == normalizedToken &&
        (tokenData['isActive'] as bool?) != false &&
        (tokenData['role'] as String? ?? '') == user.role &&
        (tokenData['platform'] as String? ?? '') == platform;

    if (tokenAlreadyActive && latestUserToken == normalizedToken) {
      _currentTokenOwnerUid = user.uid;
      _lastSessionSyncUid = user.uid;
      _lastSessionSyncedToken = normalizedToken;
      debugPrint(
        'FCM token save skipped for ${user.uid}: duplicate token from $source.',
      );
      return;
    }

    final tokenPayload = <String, dynamic>{
      'token': normalizedToken,
      'role': user.role,
      'platform': platform,
      'updatedAt': FieldValue.serverTimestamp(),
      'isActive': true,
    };
    if (!tokenSnapshot.exists) {
      tokenPayload['createdAt'] = FieldValue.serverTimestamp();
    }

    await tokenDoc.set(tokenPayload, SetOptions(merge: true));

    await userDoc.set(<String, dynamic>{
      'latestFcmToken': normalizedToken,
      'lastFcmTokenUpdatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _currentTokenOwnerUid = user.uid;
    _lastSessionSyncUid = user.uid;
    _lastSessionSyncedToken = normalizedToken;
    debugPrint(
      'FCM token saved for ${user.uid} from $source: $normalizedToken',
    );
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
    debugPrint('FCM token deleted for $normalizedUid: $normalizedToken');
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
      'accepted_donations' || 'DONATION_ACCEPTED' when user.isDonor =>
        MaterialPageRoute<void>(builder: (_) => const AcceptedDonationsScreen()),
      'donor_donations' || 'DONATION_EXPIRING_SOON' when user.isDonor =>
        MaterialPageRoute<void>(builder: (_) => const YourDonationsScreen()),
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
