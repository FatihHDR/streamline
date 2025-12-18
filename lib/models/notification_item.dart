import 'dart:convert';
import 'package:hive/hive.dart';

part 'notification_item.g.dart';

@HiveType(typeId: 4)
class NotificationItem extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String body;
  
  @HiveField(3)
  final DateTime timestamp;
  
  @HiveField(4)
  final String type;
  
  @HiveField(5)
  bool isRead;
  
  @HiveField(6)
  final String? dataJson; // Store as JSON string for Hive compatibility
  
  @HiveField(7)
  final String? imageUrl;

  // Getter to parse data from JSON
  Map<String, dynamic>? get data => dataJson != null ? jsonDecode(dataJson!) : null;

  NotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.isRead = false,
    this.dataJson,
    this.imageUrl,
  });

  // Factory constructor with Map data
  factory NotificationItem.withData({
    required String id,
    required String title,
    required String body,
    required DateTime timestamp,
    required String type,
    bool isRead = false,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) {
    return NotificationItem(
      id: id,
      title: title,
      body: body,
      timestamp: timestamp,
      type: type,
      isRead: isRead,
      dataJson: data != null ? jsonEncode(data) : null,
      imageUrl: imageUrl,
    );
  }

  NotificationItem copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? timestamp,
    String? type,
    bool? isRead,
    String? dataJson,
    String? imageUrl,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      dataJson: dataJson ?? this.dataJson,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'is_read': isRead,
      'data': data,
      'image_url': imageUrl,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return NotificationItem(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: json['type'] as String,
      isRead: json['is_read'] as bool? ?? false,
      dataJson: data != null ? jsonEncode(data) : null,
      imageUrl: json['image_url'] as String?,
    );
  }

  /// Create from FCM message data
  factory NotificationItem.fromFCM({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) {
    return NotificationItem(
      id: 'fcm_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: data?['type'] as String? ?? 'general',
      isRead: false,
      dataJson: data != null ? jsonEncode(data) : null,
      imageUrl: data?['image'] as String?,
    );
  }

  /// Get notification icon based on type
  String get iconName {
    switch (type) {
      case 'low_stock':
        return 'warning';
      case 'out_of_stock':
        return 'error';
      case 'transaction':
        return 'swap_horiz';
      case 'test':
        return 'science';
      default:
        return 'notifications';
    }
  }

  /// Get time ago string
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 7) {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} hari lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} jam lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} menit lalu';
    } else {
      return 'Baru saja';
    }
  }
}
