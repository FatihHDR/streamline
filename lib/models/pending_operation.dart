import 'package:hive/hive.dart';

part 'pending_operation.g.dart';

/// Type of operation to sync with remote server
enum OperationType {
  create,
  update,
  delete,
}

/// Represents a pending operation that needs to be synced to Supabase
@HiveType(typeId: 3)
class PendingOperation extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final OperationType type;

  @HiveField(2)
  final String entityType; // 'stock_item' or 'transaction'

  @HiveField(3)
  final String entityId;

  @HiveField(4)
  final Map<String, dynamic>? data;

  @HiveField(5)
  final DateTime createdAt;

  @HiveField(6)
  int retryCount;

  @HiveField(7)
  String? errorMessage;

  PendingOperation({
    required this.id,
    required this.type,
    required this.entityType,
    required this.entityId,
    this.data,
    required this.createdAt,
    this.retryCount = 0,
    this.errorMessage,
  });

  /// Create a JSON representation for logging
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'entityType': entityType,
        'entityId': entityId,
        'data': data,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
        'errorMessage': errorMessage,
      };

  @override
  String toString() => 'PendingOperation(${type.name} $entityType:$entityId)';
}
