import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/pending_operation.dart';

/// Service for managing pending sync operations (offline queue)
class SyncQueueService {
  static const String _boxName = 'pending_operations';
  static const int _maxRetries = 3;
  
  late Box<PendingOperation> _box;
  final _uuid = const Uuid();

  /// Initialize the service
  Future<void> init() async {
    _box = await Hive.openBox<PendingOperation>(_boxName);
    Get.log('SyncQueueService initialized with ${_box.length} pending operations');
  }

  /// Add a create operation to the queue
  Future<void> queueCreate({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    final operation = PendingOperation(
      id: _uuid.v4(),
      type: OperationType.create,
      entityType: entityType,
      entityId: entityId,
      data: data,
      createdAt: DateTime.now(),
    );

    await _box.put(operation.id, operation);
    Get.log('Queued CREATE operation: $operation');
  }

  /// Add an update operation to the queue
  Future<void> queueUpdate({
    required String entityType,
    required String entityId,
    required Map<String, dynamic> data,
  }) async {
    final operation = PendingOperation(
      id: _uuid.v4(),
      type: OperationType.update,
      entityType: entityType,
      entityId: entityId,
      data: data,
      createdAt: DateTime.now(),
    );

    await _box.put(operation.id, operation);
    Get.log('Queued UPDATE operation: $operation');
  }

  /// Add a delete operation to the queue
  Future<void> queueDelete({
    required String entityType,
    required String entityId,
  }) async {
    final operation = PendingOperation(
      id: _uuid.v4(),
      type: OperationType.delete,
      entityType: entityType,
      entityId: entityId,
      createdAt: DateTime.now(),
    );

    await _box.put(operation.id, operation);
    Get.log('Queued DELETE operation: $operation');
  }

  /// Get all pending operations sorted by creation time
  List<PendingOperation> getPendingOperations() {
    final operations = _box.values.toList();
    operations.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return operations;
  }

  /// Get count of pending operations
  int getPendingCount() => _box.length;

  /// Mark operation as completed and remove from queue
  Future<void> markCompleted(String operationId) async {
    await _box.delete(operationId);
    Get.log('Operation $operationId completed and removed from queue');
  }

  /// Mark operation as failed and increment retry count
  Future<void> markFailed(String operationId, String errorMessage) async {
    final operation = _box.get(operationId);
    if (operation != null) {
      operation.retryCount++;
      operation.errorMessage = errorMessage;

      if (operation.retryCount >= _maxRetries) {
        Get.log('Operation $operationId exceeded max retries, removing', isError: true);
        await _box.delete(operationId);
      } else {
        await operation.save();
        Get.log('Operation $operationId failed (retry ${operation.retryCount}/$_maxRetries)');
      }
    }
  }

  /// Check if there are pending operations for a specific entity
  bool hasPendingOperations(String entityType, String entityId) {
    return _box.values.any(
      (op) => op.entityType == entityType && op.entityId == entityId,
    );
  }

  /// Remove all pending operations for a specific entity
  Future<void> removePendingForEntity(String entityType, String entityId) async {
    final toRemove = _box.values
        .where((op) => op.entityType == entityType && op.entityId == entityId)
        .map((op) => op.id)
        .toList();

    for (final id in toRemove) {
      await _box.delete(id);
    }
    Get.log('Removed ${toRemove.length} pending operations for $entityType:$entityId');
  }

  /// Clear all pending operations (use with caution)
  Future<void> clearAll() async {
    await _box.clear();
    Get.log('Cleared all pending operations');
  }

  /// Get statistics about pending operations
  Map<String, dynamic> getStats() {
    final operations = _box.values.toList();
    return {
      'total': operations.length,
      'creates': operations.where((op) => op.type == OperationType.create).length,
      'updates': operations.where((op) => op.type == OperationType.update).length,
      'deletes': operations.where((op) => op.type == OperationType.delete).length,
      'failed': operations.where((op) => op.retryCount > 0).length,
    };
  }
}
