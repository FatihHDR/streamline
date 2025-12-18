import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';
import '../../../models/notification_item.dart';
import '../../../services/fcm_notification_service.dart';

class NotificationController extends GetxController {
  final logger = Logger();
  
  // Observable list of notifications
  final notifications = <NotificationItem>[].obs;
  
  // Loading state
  final isLoading = false.obs;
  
  // Unread count
  final unreadCount = 0.obs;
  
  // Filter
  final selectedFilter = 'all'.obs; // 'all', 'unread', 'read'
  
  // Hive box for notifications
  Box<NotificationItem>? _notificationsBox;
  
  // FCM Service
  final FCMNotificationService _fcmService = Get.find<FCMNotificationService>();

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  /// Initialize notifications from local storage
  Future<void> _initializeNotifications() async {
    try {
      isLoading.value = true;
      
      // Open Hive box
      _notificationsBox = await Hive.openBox<NotificationItem>('notifications');
      
      // Load notifications
      await loadNotifications();
      
      // Listen to FCM service for new notifications
      _setupFCMListener();
      
      logger.i('✅ Notification controller initialized');
    } catch (e) {
      logger.e('❌ Error initializing notifications', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Setup listener for new FCM notifications
  void _setupFCMListener() {
    // Listen to lastNotificationTime changes to reload notifications
    ever(_fcmService.lastNotificationTime, (_) {
      loadNotifications();
    });
  }

  /// Load all notifications from storage
  Future<void> loadNotifications() async {
    try {
      if (_notificationsBox == null) {
        await _initializeNotifications();
        return;
      }
      
      isLoading.value = true;
      
      // Get all notifications
      final allNotifications = _notificationsBox!.values.toList();
      
      // Sort by timestamp (newest first)
      allNotifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      // Apply filter
      List<NotificationItem> filtered = [];
      switch (selectedFilter.value) {
        case 'unread':
          filtered = allNotifications.where((n) => !n.isRead).toList();
          break;
        case 'read':
          filtered = allNotifications.where((n) => n.isRead).toList();
          break;
        default:
          filtered = allNotifications;
      }
      
      notifications.value = filtered;
      
      // Update unread count
      unreadCount.value = allNotifications.where((n) => !n.isRead).length;
      
      logger.i('📱 Loaded ${notifications.length} notifications (${unreadCount.value} unread)');
    } catch (e) {
      logger.e('❌ Error loading notifications', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Add a new notification
  Future<void> addNotification(NotificationItem notification) async {
    try {
      await _notificationsBox?.add(notification);
      await loadNotifications();
      logger.i('✅ Notification added: ${notification.title}');
    } catch (e) {
      logger.e('❌ Error adding notification', error: e);
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(NotificationItem notification) async {
    try {
      final index = _notificationsBox?.values
          .toList()
          .indexWhere((n) => n.id == notification.id);
      
      if (index != null && index != -1) {
        notification.isRead = true;
        await _notificationsBox?.putAt(index, notification);
        await loadNotifications();
        logger.i('✅ Notification marked as read');
      }
    } catch (e) {
      logger.e('❌ Error marking notification as read', error: e);
    }
  }

  /// Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      final allNotifications = _notificationsBox?.values.toList() ?? [];
      
      for (var i = 0; i < allNotifications.length; i++) {
        if (!allNotifications[i].isRead) {
          allNotifications[i].isRead = true;
          await _notificationsBox?.putAt(i, allNotifications[i]);
        }
      }
      
      await loadNotifications();
      logger.i('✅ All notifications marked as read');
      
      Get.snackbar(
        'Berhasil',
        'Semua notifikasi telah ditandai sebagai dibaca',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      logger.e('❌ Error marking all as read', error: e);
    }
  }

  /// Delete a notification
  Future<void> deleteNotification(NotificationItem notification) async {
    try {
      final index = _notificationsBox?.values
          .toList()
          .indexWhere((n) => n.id == notification.id);
      
      if (index != null && index != -1) {
        await _notificationsBox?.deleteAt(index);
        await loadNotifications();
        logger.i('✅ Notification deleted');
        
        Get.snackbar(
          'Berhasil',
          'Notifikasi telah dihapus',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      }
    } catch (e) {
      logger.e('❌ Error deleting notification', error: e);
    }
  }

  /// Clear all notifications
  Future<void> clearAll() async {
    try {
      await _notificationsBox?.clear();
      await loadNotifications();
      logger.i('✅ All notifications cleared');
      
      Get.snackbar(
        'Berhasil',
        'Semua notifikasi telah dihapus',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      logger.e('❌ Error clearing notifications', error: e);
    }
  }

  /// Change filter
  void changeFilter(String filter) {
    selectedFilter.value = filter;
    loadNotifications();
  }

  /// Create a test notification (for development)
  Future<void> createTestNotification() async {
    final testNotification = NotificationItem.withData(
      id: 'test_${DateTime.now().millisecondsSinceEpoch}',
      title: '🧪 Test Notification',
      body: 'This is a test notification created at ${DateTime.now().toString()}',
      timestamp: DateTime.now(),
      type: 'test',
      isRead: false,
      data: {
        'screen': 'notifications',
        'test': true,
      },
    );
    
    await addNotification(testNotification);
    
    Get.snackbar(
      'Test Notification',
      'Test notification created successfully',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  /// Subscribe to warehouse-related topics
  Future<void> subscribeToWarehouseTopics() async {
    await _fcmService.subscribeToTopic('warehouse_low_stock');
    await _fcmService.subscribeToTopic('warehouse_out_of_stock');
    await _fcmService.subscribeToTopic('warehouse_new_transaction');
    
    logger.i('✅ Subscribed to warehouse topics');
  }

  @override
  void onClose() {
    _notificationsBox?.close();
    super.onClose();
  }
}
