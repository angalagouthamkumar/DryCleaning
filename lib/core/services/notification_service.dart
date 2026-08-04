import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    await Firebase.initializeApp();
    debugPrint('Handling background message: ${message.messageId}');
  } catch (e) {
    debugPrint('Background message handler exception: $e');
  }
}

typedef NotificationNavigationCallback = void Function(String? payload, String? type);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  bool _initialized = false;
  NotificationNavigationCallback? _onNotificationTap;

  FirebaseMessaging? get _fcm {
    try {
      return FirebaseMessaging.instance;
    } catch (e) {
      debugPrint('FirebaseMessaging instance unavailable: $e');
      return null;
    }
  }

  void setNavigationCallback(NotificationNavigationCallback callback) {
    _onNotificationTap = callback;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    try {
      debugPrint('[STARTUP] NotificationService initialization started');

      // 1. Initialize Flutter Local Notifications
      const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('Notification tapped with payload: ${response.payload}');
          if (_onNotificationTap != null) {
            _onNotificationTap!(response.payload, 'order_status');
          }
        },
      );

      // Create Android Notification Channel with ~2s vibration pattern
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'drycleaning_order_updates',
        'Order Status Updates',
        description: 'Real-time order progress notifications for all 15 stages',
        importance: Importance.high,
        enableVibration: true,
        playSound: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 2. Safely initialize Firebase Push Messaging if available
      final fcm = _fcm;
      if (fcm != null) {
        try {
          NotificationSettings settings = await fcm.requestPermission(
            alert: true,
            badge: true,
            sound: true,
            provisional: false,
          );

          debugPrint('User notification permission status: ${settings.authorizationStatus}');

          FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

          fcm.onTokenRefresh.listen((newToken) {
            debugPrint('FCM Token refreshed: $newToken');
          });

          FirebaseMessaging.onMessage.listen((RemoteMessage message) {
            debugPrint('Foreground message received: ${message.notification?.title}');
            _showLocalNotification(message);
          });

          RemoteMessage? initialMessage = await fcm.getInitialMessage();
          if (initialMessage != null && _onNotificationTap != null) {
            final orderId = initialMessage.data['orderId']?.toString();
            final type = initialMessage.data['type']?.toString();
            _onNotificationTap!(orderId, type);
          }

          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
            debugPrint('App opened via FCM notification tap: ${message.data}');
            if (_onNotificationTap != null) {
              final orderId = message.data['orderId']?.toString();
              final type = message.data['type']?.toString();
              _onNotificationTap!(orderId, type);
            }
          });
        } catch (fcmErr) {
          debugPrint('FCM messaging setup skipped or error: $fcmErr');
        }
      }

      _initialized = true;
      debugPrint('[STARTUP] NotificationService initialized successfully');
    } catch (e, stack) {
      debugPrint('NotificationService initialization error (non-fatal): $e\n$stack');
    }
  }

  Future<String?> getFcmToken() async {
    try {
      final fcm = _fcm;
      if (fcm != null) {
        return await fcm.getToken();
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
    return null;
  }

  void _showLocalNotification(RemoteMessage message) {
    try {
      final notification = message.notification;
      if (notification == null) return;

      final Int64List vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'drycleaning_order_updates',
        'Order Status Updates',
        channelDescription: 'Real-time order progress notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        vibrationPattern: vibrationPattern,
        playSound: true,
      );

      final NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(presentAlert: true, presentSound: true),
      );

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: message.data['orderId']?.toString(),
      );
    } catch (e) {
      debugPrint('Local notification error: $e');
    }
  }
}
