import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import '../models/notification_item.dart';
import '../modules/notification/controllers/notification_controller.dart';

/// Background message handler - MUST be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.i('📱 [BACKGROUND] Handling message: ${message.messageId}');
  logger.i('📱 [BACKGROUND] Title: ${message.notification?.title}');
  logger.i('📱 [BACKGROUND] Body: ${message.notification?.body}');
  logger.i('📱 [BACKGROUND] Data: ${message.data}');
  
  // Store notification for later retrieval
  await FCMNotificationService.storeNotification(message);
}

class FCMNotificationService extends GetxService {
  static final logger = Logger();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Observable for FCM token
  final fcmToken = Rx<String?>(null);
  
  // Track notification receipt time for latency analysis
  final lastNotificationTime = Rx<DateTime?>(null);
  
  // Store notification data when app is terminated
  static const String _storageKey = 'pending_notifications';

  /// Initialize the notification service
  Future<FCMNotificationService> init() async {
    logger.i('🔔 Initializing FCM Notification Service...');
    
    try {
      // Request notification permissions
      await _requestPermissions();
      
      // Initialize local notifications
      await _initializeLocalNotifications();
      
      // Get FCM token
      await _getFCMToken();
      
      // Setup message handlers for different states
      _setupMessageHandlers();
      
      logger.i('✅ FCM Notification Service initialized successfully');
      return this;
    } catch (e, stackTrace) {
      logger.e('❌ Error initializing FCM service', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Request notification permissions (especially important for iOS)
  Future<void> _requestPermissions() async {
    logger.i('📋 Requesting notification permissions...');
    
    final NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    logger.i('✅ Permission status: ${settings.authorizationStatus}');
    
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('✅ User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      logger.i('⚠️ User granted provisional permission');
    } else {
      logger.w('⚠️ User declined or has not accepted permission');
    }
  }

  /// Initialize Flutter Local Notifications
  Future<void> _initializeLocalNotifications() async {
    logger.i('🔧 Initializing local notifications...');
    
    // Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize with callback for notification tap
    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel with custom sound
    await _createNotificationChannel();
    
    logger.i('✅ Local notifications initialized');
  }

  /// Create Android notification channel
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'streamline_warehouse_channel_v2', // id
      'Warehouse Notifications V2', // name
      description: 'Notifications for warehouse inventory management',
      importance: Importance.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      // showBadge parameter is removed in newer versions or controlled via channel
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
    
    logger.i('✅ Android notification channel created');
  }

  /// Get FCM token for this device
  Future<void> _getFCMToken() async {
    try {
      final token = await _messaging.getToken();
      fcmToken.value = token;
      logger.i('🔑 FCM Token: $token');
      
      // Listen for token refresh
      _messaging.onTokenRefresh.listen((newToken) {
        fcmToken.value = newToken;
        logger.i('🔄 FCM Token refreshed: $newToken');
        
        // TODO: Send token to your backend server
        // Example: await ApiService.updateFCMToken(newToken);
      });
    } catch (e) {
      logger.e('❌ Error getting FCM token', error: e);
    }
  }

  /// Setup message handlers for different app states
  void _setupMessageHandlers() {
    logger.i('⚙️ Setting up message handlers...');
    
    // FOREGROUND: Handle messages when app is in foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    
    // BACKGROUND: Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotificationTap);
    
    // TERMINATED: Handle notification tap when app was terminated
    _handleTerminatedNotificationTap();
  }

  /// Handle messages when app is in FOREGROUND
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    lastNotificationTime.value = DateTime.now();
    
    logger.i('📱 [FOREGROUND] Message received!');
    logger.i('📱 [FOREGROUND] Message ID: ${message.messageId}');
    logger.i('📱 [FOREGROUND] Title: ${message.notification?.title}');
    logger.i('📱 [FOREGROUND] Body: ${message.notification?.body}');
    logger.i('📱 [FOREGROUND] Data: ${message.data}');
    
    // Show heads-up notification using local notifications
    await _showLocalNotification(message);
    
    // Store notification in database/local storage
    await storeNotification(message);
  }

  /// Show local notification (for foreground state)
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null) {
      // Prepare notification details with custom sound
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'streamline_warehouse_channel_v2',
        'Warehouse Notifications V2',
        channelDescription: 'Notifications for warehouse inventory management',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        sound: RawResourceAndroidNotificationSound('notification_sound'),
        enableVibration: true,
        ticker: 'ticker',
        showWhen: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          sound: 'notification_sound.wav',
        ),
      );

      // Show the notification
      await _localNotifications.show(
        notification.hashCode,
        notification.title ?? 'Streamline',
        notification.body ?? '',
        notificationDetails,
        payload: jsonEncode(message.data),
      );
      
      logger.i('✅ [FOREGROUND] Local notification displayed');
    }
  }

  /// Handle notification tap when app is in BACKGROUND
  void _handleBackgroundNotificationTap(RemoteMessage message) {
    logger.i('📱 [BACKGROUND TAP] Notification opened!');
    logger.i('📱 [BACKGROUND TAP] Data: ${message.data}');
    
    _navigateBasedOnPayload(message.data);
  }

  /// Handle notification tap when app was TERMINATED
  Future<void> _handleTerminatedNotificationTap() async {
    // Check if app was opened from a notification
    final RemoteMessage? initialMessage =
        await _messaging.getInitialMessage();

    if (initialMessage != null) {
      logger.i('📱 [TERMINATED TAP] App opened from notification!');
      logger.i('📱 [TERMINATED TAP] Data: ${initialMessage.data}');
      
      // Wait a bit for the app to fully initialize
      Future.delayed(const Duration(seconds: 1), () {
        _navigateBasedOnPayload(initialMessage.data);
      });
    }
  }

  /// Handle local notification tap
  void _onNotificationTapped(NotificationResponse response) {
    logger.i('📱 [LOCAL TAP] Notification tapped!');
    logger.i('📱 [LOCAL TAP] Payload: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final Map<String, dynamic> data = jsonDecode(response.payload!);
        _navigateBasedOnPayload(data);
      } catch (e) {
        logger.e('❌ Error parsing notification payload', error: e);
      }
    }
  }

  /// Navigate to specific screen based on notification payload
  void _navigateBasedOnPayload(Map<String, dynamic> data) {
    logger.i('🧭 Navigating based on payload: $data');
    
    final String? type = data['type'];
    final String? screen = data['screen'];
    
    // Navigate based on notification type
    switch (type) {
      case 'low_stock':
        // Navigate to inventory with low stock filter
        Get.toNamed('/home', arguments: {'initialTab': 1, 'filter': 'low_stock'});
        break;
        
      case 'out_of_stock':
        // Navigate to inventory with out of stock filter
        Get.toNamed('/home', arguments: {'initialTab': 1, 'filter': 'out_of_stock'});
        break;
        
      case 'new_transaction':
        // Navigate to transaction history
        Get.toNamed('/home', arguments: {'initialTab': 2});
        break;
        
      case 'restock_reminder':
        // Navigate to specific item detail
        final String? itemId = data['item_id'];
        if (itemId != null) {
          Get.toNamed('/home', arguments: {
            'initialTab': 1,
            'itemId': itemId,
          });
        }
        break;
        
      default:
        // Navigate to notifications list
        Get.toNamed('/notifications');
    }
  }

  /// Show a local notification manually
  Future<void> showNotification({
    required String title,
    required String body,
    String? type,
    Map<String, dynamic>? data,
  }) async {
    // Generate a unique ID for the notification
    final int id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    
    // Create combined data
    final Map<String, dynamic> notificationData = {
      'type': type ?? 'general',
      ...?data,
    };

    // Prepare notification details
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'streamline_warehouse_channel_v2',
      'Warehouse Notifications V2',
      channelDescription: 'Notifications for warehouse inventory management',
      importance: Importance.high, 
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('notification_sound'),
      enableVibration: true,
      // showBadge parameter is removed in newer versions or controlled via channel
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
        sound: 'notification_sound.wav',
      ),
    );

    // Show the notification
    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: jsonEncode(notificationData),
    );
    
    // Store in history
    try {
      if (Get.isRegistered<NotificationController>()) {
        final notificationController = Get.find<NotificationController>();
        
        final notification = NotificationItem.withData(
          id: 'local_$id',
          title: title,
          body: body,
          timestamp: DateTime.now(),
          type: type ?? 'general',
          isRead: false,
          data: data,
        );
        
        await notificationController.addNotification(notification);
      }
    } catch (e) {
      print('❌ Error storing local notification: $e');
    }
    
    logger.i('✅ [Obtained Manually] Local notification displayed and stored');
  }

  /// Store notification for history
  static Future<void> storeNotification(RemoteMessage message) async {
    try {
      if (Get.isRegistered<NotificationController>()) {
        final notificationController = Get.find<NotificationController>();
        
        // Extract data
        final title = message.notification?.title ?? 'Notification';
        final body = message.notification?.body ?? '';
        final data = message.data;
        
        // Create model
        final notification = NotificationItem.withData(
          id: message.messageId ?? 'fcm_${DateTime.now().millisecondsSinceEpoch}',
          title: title,
          body: body,
          timestamp: message.sentTime ?? DateTime.now(),
          type: data['type'] ?? 'general',
          isRead: false,
          data: data,
        );
        
        // Add to controller
        await notificationController.addNotification(notification);
      }
    } catch (e) {
      // Logger might not be available in static context easily if not initialized, 
      // but we accesses it via class property above. 
      // However to avoid circular dependency issues or complex imports in static method,
      // we'll keep it simple.
      print('❌ Error storing notification: $e');
    }
  }

  /// Subscribe to a topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      logger.i('✅ Subscribed to topic: $topic');
    } catch (e) {
      logger.e('❌ Error subscribing to topic', error: e);
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      logger.i('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      logger.e('❌ Error unsubscribing from topic', error: e);
    }
  }

  /// Send a test notification (for development)
  Future<void> sendTestNotification() async {
    final testMessage = RemoteMessage(
      notification: const RemoteNotification(
        title: '🧪 Test Notification',
        body: 'This is a test notification from Streamline',
      ),
      data: {
        'type': 'test',
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
    
    await _handleForegroundMessage(testMessage);
  }

  @override
  void onClose() {
    logger.i('👋 FCM Notification Service closing...');
    super.onClose();
  }
}
