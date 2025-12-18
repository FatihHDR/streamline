import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../models/notification_item.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationItem notification;
  
  const NotificationDetailScreen({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Notifikasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getNotificationColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    _getNotificationIcon(),
                    color: _getNotificationColor(),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getNotificationTypeLabel(),
                        style: TextStyle(
                          color: _getNotificationColor(),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            
            // Title
            Text(
              'Judul',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Body
            Text(
              'Pesan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              notification.body,
              style: const TextStyle(
                fontSize: 16,
                height: 1.5,
              ),
            ),
            
            // Additional data (if any)
            if (notification.data.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              
              Text(
                'Informasi Tambahan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 12),
              
              ...notification.data.entries.map((entry) {
                // Skip internal fields
                if (entry.key == 'screen' || entry.key == 'type') {
                  return const SizedBox.shrink();
                }
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${_formatKey(entry.key)}:',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value.toString(),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            
            const SizedBox(height: 32),
            
            // Action buttons based on notification type
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    switch (notification.type) {
      case 'low_stock':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.offAllNamed('/home', arguments: {
                'initialTab': 1,
                'filter': 'low_stock',
              });
            },
            icon: const Icon(Icons.inventory_2),
            label: const Text('Lihat Stok Menipis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
        
      case 'out_of_stock':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.offAllNamed('/home', arguments: {
                'initialTab': 1,
                'filter': 'out_of_stock',
              });
            },
            icon: const Icon(Icons.error_outline),
            label: const Text('Lihat Stok Habis'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
        
      case 'new_transaction':
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Get.offAllNamed('/home', arguments: {
                'initialTab': 2,
              });
            },
            icon: const Icon(Icons.receipt_long),
            label: const Text('Lihat Transaksi'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        );
        
      case 'restock_reminder':
        return Column(
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  final itemId = notification.data['item_id'];
                  if (itemId != null) {
                    Get.offAllNamed('/home', arguments: {
                      'initialTab': 1,
                      'itemId': itemId,
                    });
                  }
                },
                icon: const Icon(Icons.shopping_cart),
                label: const Text('Restok Sekarang'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  Get.offAllNamed('/home', arguments: {
                    'initialTab': 1,
                  });
                },
                icon: const Icon(Icons.visibility),
                label: const Text('Lihat Detail Barang'),
              ),
            ),
          ],
        );
        
      default:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Get.back();
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Kembali'),
          ),
        );
    }
  }

  IconData _getNotificationIcon() {
    switch (notification.type) {
      case 'low_stock':
        return Icons.warning_amber_rounded;
      case 'out_of_stock':
        return Icons.error_outline;
      case 'new_transaction':
        return Icons.receipt_long;
      case 'restock_reminder':
        return Icons.inventory_2;
      default:
        return Icons.notifications;
    }
  }

  Color _getNotificationColor() {
    switch (notification.type) {
      case 'low_stock':
        return Colors.orange;
      case 'out_of_stock':
        return Colors.red;
      case 'new_transaction':
        return Colors.green;
      case 'restock_reminder':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getNotificationTypeLabel() {
    switch (notification.type) {
      case 'low_stock':
        return 'STOK MENIPIS';
      case 'out_of_stock':
        return 'STOK HABIS';
      case 'new_transaction':
        return 'TRANSAKSI BARU';
      case 'restock_reminder':
        return 'PENGINGAT RESTOK';
      default:
        return 'NOTIFIKASI';
    }
  }

  String _formatTimestamp() {
    final timestamp = notification.timestamp;
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Baru saja';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} menit yang lalu';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} jam yang lalu';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari yang lalu';
    } else {
      final day = timestamp.day.toString().padLeft(2, '0');
      final month = timestamp.month.toString().padLeft(2, '0');
      final year = timestamp.year;
      final hour = timestamp.hour.toString().padLeft(2, '0');
      final minute = timestamp.minute.toString().padLeft(2, '0');
      return '$day/$month/$year - $hour:$minute';
    }
  }

  String _formatKey(String key) {
    // Convert snake_case or camelCase to Title Case
    return key
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => ' ${match.group(0)}',
        )
        .replaceAll('_', ' ')
        .split(' ')
        .map((word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}')
        .join(' ')
        .trim();
  }
}
