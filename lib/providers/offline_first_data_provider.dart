import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';
import '../models/pending_operation.dart';
import '../services/supabase_service.dart';
import '../services/hive_service.dart';
import '../services/sync_queue_service.dart';
import 'i_data_provider.dart';

/// Offline-first data provider with automatic sync (like WhatsApp)
/// - Offline: All operations saved to Hive and queued for sync
/// - Online: Automatically syncs pending operations to Supabase
class OfflineFirstDataProvider implements IDataProvider {
  OfflineFirstDataProvider({
    SupabaseService? supabaseService,
    HiveService? hiveService,
    SyncQueueService? syncQueueService,
  })  : _supabaseService = supabaseService ?? SupabaseService(),
        _hiveService = hiveService ?? HiveService(),
        _syncQueueService = syncQueueService ?? SyncQueueService() {
    _initConnectivityListener();
  }

  final SupabaseService _supabaseService;
  final HiveService _hiveService;
  final SyncQueueService _syncQueueService;
  
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  final _isSyncing = false.obs;
  final _isOnline = true.obs;
  final _pendingCount = 0.obs;

  bool get isSyncing => _isSyncing.value;
  bool get isOnline => _isOnline.value;
  int get pendingCount => _pendingCount.value;
  
  /// Update pending count (call this after queue operations)
  void _updatePendingCount() {
    _pendingCount.value = _syncQueueService.getPendingCount();
  }

  /// Initialize connectivity listener
  void _initConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOffline = !_isOnline.value;
      _isOnline.value = !results.contains(ConnectivityResult.none) && results.isNotEmpty;

      Get.log('Connectivity changed: ${_isOnline.value ? "ONLINE" : "OFFLINE"}');

      // Auto-sync when coming back online
      if (wasOffline && _isOnline.value) {
        Get.log('Back online! Starting auto-sync...');
        syncPendingOperations();
      }
    });

    // Check initial connectivity
    _connectivity.checkConnectivity().then((results) {
      _isOnline.value = !results.contains(ConnectivityResult.none) && results.isNotEmpty;
      Get.log('Initial connectivity: ${_isOnline.value ? "ONLINE" : "OFFLINE"}');
    });
  }

  /// Fetch stock items (always from cache, sync in background)
  Future<List<StockItem>> fetchStockItems() async {
    // Return cached data immediately
    final cachedItems = await _hiveService.getStockItems();
    
    // Sync in background if online
    if (_isOnline.value) {
      _syncFromRemote();
    }
    
    return cachedItems;
  }

  /// Background sync from remote to local cache
  Future<void> _syncFromRemote() async {
    try {
      final items = await _supabaseService.getStockItems();
      await _hiveService.cacheStockItems(items);
      Get.log('Background sync completed: ${items.length} items');
    } catch (e) {
      Get.log('Background sync failed: $e');
    }
  }

  /// Create stock item (save locally first, queue for sync)
  Future<StockItem> createStockItem(StockItem item) async {
    // Generate temporary ID if needed
    final localItem = item.id.isEmpty 
        ? item.copyWith(id: 'temp_${DateTime.now().millisecondsSinceEpoch}')
        : item;

    // Save to local cache immediately
    await _hiveService.putStockItem(localItem);
    Get.log('✓ Item saved locally: ${localItem.name}');

    // Queue for sync
    await _syncQueueService.queueCreate(
      entityType: 'stock_item',
      entityId: localItem.id,
      data: localItem.toJson(),
    );
    _updatePendingCount();
    Get.log('⏳ Queued for sync (${pendingCount} pending)');

    // Try to sync immediately if online
    if (_isOnline.value) {
      syncPendingOperations();
    } else {
      Get.log('📴 Offline - will sync when online');
    }

    return localItem;
  }

  /// Update stock item (save locally first, queue for sync)
  Future<StockItem> updateStockItem(String id, StockItem item) async {
    // Save to local cache immediately
    await _hiveService.putStockItem(item);
    Get.log('✓ Item updated locally: ${item.name}');

    // Queue for sync
    await _syncQueueService.queueUpdate(
      entityType: 'stock_item',
      entityId: id,
      data: item.toJson(),
    );
    _updatePendingCount();
    Get.log('⏳ Queued for sync (${pendingCount} pending)');

    // Try to sync immediately if online
    if (_isOnline.value) {
      syncPendingOperations();
    } else {
      Get.log('📴 Offline - will sync when online');
    }

    return item;
  }

  /// Delete stock item (remove locally, queue for sync)
  Future<void> deleteStockItem(String id) async {
    // Remove from local cache immediately
    await _hiveService.deleteStockItem(id);
    Get.log('✓ Item deleted locally: $id');

    // Queue for sync
    await _syncQueueService.queueDelete(
      entityType: 'stock_item',
      entityId: id,
    );
    _updatePendingCount();
    Get.log('⏳ Queued for sync (${pendingCount} pending)');

    // Try to sync immediately if online
    if (_isOnline.value) {
      syncPendingOperations();
    } else {
      Get.log('📴 Offline - will sync when online');
    }
  }

  /// Sync all pending operations to Supabase
  Future<void> syncPendingOperations() async {
    if (_isSyncing.value) {
      Get.log('Sync already in progress, skipping...');
      return;
    }

    if (!_isOnline.value) {
      Get.log('Cannot sync while offline');
      return;
    }

    final operations = _syncQueueService.getPendingOperations();
    if (operations.isEmpty) {
      Get.log('No pending operations to sync');
      return;
    }

    _isSyncing.value = true;
    Get.log('🔄 Starting sync: ${operations.length} operations');

    int successCount = 0;
    int failCount = 0;

    for (final operation in operations) {
      try {
        await _syncOperation(operation);
        await _syncQueueService.markCompleted(operation.id);
        successCount++;
        Get.log('✓ Synced: $operation');
      } catch (e) {
        // Only mark failed if real error, not just "not implemented match"
        // But since we want to clear queue if we can't handle it...
        // For now, assume error means RETRY later.
        // await _syncQueueService.markFailed(operation.id, e.toString());
        failCount++;
        Get.log('✗ Failed: $operation - $e', isError: true);
      }
    }

    _updatePendingCount();
    _isSyncing.value = false;
    Get.log('✅ Sync complete: $successCount success, $failCount failed');

    // Refresh from remote after sync
    if (successCount > 0) {
      await _syncFromRemote();
    }
  }

  /// Sync a single operation
  Future<void> _syncOperation(PendingOperation operation) async {
    if (operation.entityType == 'stock_item') {
      switch (operation.type) {
        case OperationType.create:
          final item = StockItem.fromJson(operation.data!);
          final created = await _supabaseService.createStockItem(item);
          // Update local cache with real ID from server
          await _hiveService.deleteStockItem(operation.entityId);
          await _hiveService.putStockItem(created);
          break;

        case OperationType.update:
          final item = StockItem.fromJson(operation.data!);
          await _supabaseService.updateStockItem(operation.entityId, item);
          break;

        case OperationType.delete:
          await _supabaseService.deleteStockItem(operation.entityId);
          break;
      }
    } else if (operation.entityType == 'transaction') {
      switch (operation.type) {
        case OperationType.create:
          final transaction = StockTransaction.fromJson(operation.data!);
          await _supabaseService.createTransaction(transaction);
          break;
        case OperationType.update:
        case OperationType.delete:
           Get.log('Transaction update/delete not supported yet');
           break;
      }
    }
  }

  /// Fetch transactions
  Future<List<StockTransaction>> fetchTransactions() async {
    final cached = await _hiveService.getTransactions();
    
    if (_isOnline.value) {
      try {
        final remote = await _supabaseService.getTransactions();
        await _hiveService.cacheTransactions(remote);
        return remote;
      } catch (e) {
        Get.log('Failed to fetch transactions, using cache: $e');
      }
    }
    
    return cached;
  }

  /// Create transaction (save locally first, queue for sync)
  @override
  Future<StockTransaction> createTransaction(StockTransaction transaction) async {
    // Save to local cache immediately
    await _hiveService.putTransaction(transaction);
    Get.log('✓ Transaction saved locally: ${transaction.itemName}');

    // Queue for sync
    await _syncQueueService.queueCreate(
      entityType: 'transaction',
      entityId: transaction.id,
      data: transaction.toJson(),
    );

    // Try to sync immediately if online
    if (_isOnline.value) {
      syncPendingOperations();
    }

    return transaction;
  }

  /// Fetch transactions for specific item
  @override
  Future<List<StockTransaction>> fetchTransactionsForItem(String itemId) async {
    if (_isOnline.value) {
      try {
        return await _supabaseService.getTransactionsForItem(itemId);
      } catch (e) {
        Get.log('Failed to fetch transactions, using cache: $e');
      }
    }
    
    return await _hiveService.getTransactionsForItem(itemId);
  }

  /// Get sync statistics
  Map<String, dynamic> getSyncStats() {
    return {
      'isOnline': _isOnline.value,
      'isSyncing': _isSyncing.value,
      'pendingOperations': _syncQueueService.getStats(),
    };
  }

  /// Refresh pending count (call externally after clearing queue)
  void refreshPendingCount() {
    _updatePendingCount();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}
