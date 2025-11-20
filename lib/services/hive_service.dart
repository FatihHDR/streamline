import 'package:hive_flutter/hive_flutter.dart';
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';

class HiveService {
  static const String _itemsBoxName = 'stock_items';
  static const String _transactionsBoxName = 'stock_transactions';

  Box<StockItem>? _itemsBox;
  Box<StockTransaction>? _transactionsBox;

  // ==================== INITIALIZATION ====================

  /// Open Hive boxes for items and transactions
  Future<void> init() async {
    _itemsBox = await Hive.openBox<StockItem>(_itemsBoxName);
    _transactionsBox = await Hive.openBox<StockTransaction>(_transactionsBoxName);
  }

  /// Ensure boxes are opened
  Future<void> _ensureInitialized() async {
    if (_itemsBox == null || !_itemsBox!.isOpen) {
      _itemsBox = await Hive.openBox<StockItem>(_itemsBoxName);
    }
    if (_transactionsBox == null || !_transactionsBox!.isOpen) {
      _transactionsBox = await Hive.openBox<StockTransaction>(_transactionsBoxName);
    }
  }

  // ==================== STOCK ITEMS ====================

  /// Get all cached stock items
  Future<List<StockItem>> getStockItems() async {
    await _ensureInitialized();
    return _itemsBox!.values.toList();
  }

  /// Cache stock items from remote source
  Future<void> cacheStockItems(List<StockItem> items) async {
    await _ensureInitialized();
    await _itemsBox!.clear();
    
    for (final item in items) {
      await _itemsBox!.put(item.id, item);
    }
  }

  /// Add or update a single stock item in cache
  Future<void> putStockItem(StockItem item) async {
    await _ensureInitialized();
    await _itemsBox!.put(item.id, item);
  }

  /// Get a single stock item by ID
  Future<StockItem?> getStockItem(String id) async {
    await _ensureInitialized();
    return _itemsBox!.get(id);
  }

  /// Delete a stock item from cache
  Future<void> deleteStockItem(String id) async {
    await _ensureInitialized();
    await _itemsBox!.delete(id);
  }

  /// Clear all cached stock items
  Future<void> clearStockItems() async {
    await _ensureInitialized();
    await _itemsBox!.clear();
  }

  // ==================== STOCK TRANSACTIONS ====================

  /// Get all cached transactions
  Future<List<StockTransaction>> getTransactions() async {
    await _ensureInitialized();
    return _transactionsBox!.values.toList();
  }

  /// Cache transactions from remote source
  Future<void> cacheTransactions(List<StockTransaction> transactions) async {
    await _ensureInitialized();
    await _transactionsBox!.clear();
    
    for (final transaction in transactions) {
      await _transactionsBox!.put(transaction.id, transaction);
    }
  }

  /// Add a single transaction to cache
  Future<void> putTransaction(StockTransaction transaction) async {
    await _ensureInitialized();
    await _transactionsBox!.put(transaction.id, transaction);
  }

  /// Get transactions for a specific item
  Future<List<StockTransaction>> getTransactionsForItem(String itemId) async {
    await _ensureInitialized();
    return _transactionsBox!.values
        .where((txn) => txn.itemId == itemId)
        .toList();
  }

  /// Clear all cached transactions
  Future<void> clearTransactions() async {
    await _ensureInitialized();
    await _transactionsBox!.clear();
  }

  // ==================== UTILITY ====================

  /// Clear all cached data
  Future<void> clearAll() async {
    await clearStockItems();
    await clearTransactions();
  }

  /// Get cache statistics
  Future<Map<String, int>> getCacheStats() async {
    await _ensureInitialized();
    return {
      'items': _itemsBox!.length,
      'transactions': _transactionsBox!.length,
    };
  }

  /// Close all boxes (call when app is closing)
  Future<void> close() async {
    await _itemsBox?.close();
    await _transactionsBox?.close();
  }
}
