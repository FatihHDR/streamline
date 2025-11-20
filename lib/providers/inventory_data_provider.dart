import 'package:get/get.dart';
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';
import '../services/supabase_service.dart';
import '../services/hive_service.dart';

/// Provides data access for inventory-related resources with caching strategy.
/// Priority: Supabase (remote) → Hive (local cache) → Error
class InventoryDataProvider {
  InventoryDataProvider({
    SupabaseService? supabaseService,
    HiveService? hiveService,
  })  : _supabaseService = supabaseService ?? SupabaseService(),
        _hiveService = hiveService ?? HiveService();

  final SupabaseService _supabaseService;
  final HiveService _hiveService;

  /// Fetch stock items: Try Supabase first, fallback to Hive cache on error
  Future<List<StockItem>> fetchStockItems() async {
    try {
      // Try to fetch from Supabase
      final items = await _supabaseService.getStockItems();
      
      // Cache the result in Hive
      await _hiveService.cacheStockItems(items);
      Get.log('Stock items fetched from Supabase and cached locally');
      
      return items;
    } catch (e) {
      Get.log('Failed to fetch from Supabase, loading from cache: $e');
      
      // Fallback to cached data
      try {
        final cachedItems = await _hiveService.getStockItems();
        if (cachedItems.isNotEmpty) {
          Get.log('Loaded ${cachedItems.length} items from Hive cache');
          return cachedItems;
        }
      } catch (cacheError) {
        Get.log('Cache read error: $cacheError', isError: true);
      }
      
      rethrow;
    }
  }

  /// Fetch transactions: Try Supabase first, fallback to Hive cache on error
  Future<List<StockTransaction>> fetchTransactions() async {
    try {
      // Try to fetch from Supabase
      final transactions = await _supabaseService.getTransactions();
      
      // Cache the result in Hive
      await _hiveService.cacheTransactions(transactions);
      Get.log('Transactions fetched from Supabase and cached locally');
      
      return transactions;
    } catch (e) {
      Get.log('Failed to fetch from Supabase, loading from cache: $e');
      
      // Fallback to cached data
      try {
        final cachedTransactions = await _hiveService.getTransactions();
        if (cachedTransactions.isNotEmpty) {
          Get.log('Loaded ${cachedTransactions.length} transactions from Hive cache');
          return cachedTransactions;
        }
      } catch (cacheError) {
        Get.log('Cache read error: $cacheError', isError: true);
      }
      
      rethrow;
    }
  }

  /// Create stock item: Save to Supabase and update cache
  Future<StockItem> createStockItem(StockItem item) async {
    try {
      final createdItem = await _supabaseService.createStockItem(item);
      
      // Update cache
      await _hiveService.putStockItem(createdItem);
      Get.log('Item created and cached: ${createdItem.name}');
      
      return createdItem;
    } catch (e) {
      Get.log('Failed to create item remotely: $e', isError: true);
      rethrow;
    }
  }

  /// Update stock item: Update in Supabase and cache
  Future<StockItem> updateStockItem(String id, StockItem item) async {
    try {
      final updatedItem = await _supabaseService.updateStockItem(id, item);
      
      // Update cache
      await _hiveService.putStockItem(updatedItem);
      Get.log('Item updated and cached: ${updatedItem.name}');
      
      return updatedItem;
    } catch (e) {
      Get.log('Failed to update item remotely: $e', isError: true);
      rethrow;
    }
  }

  /// Delete stock item: Delete from Supabase and cache
  Future<void> deleteStockItem(String id) async {
    try {
      await _supabaseService.deleteStockItem(id);
      
      // Remove from cache
      await _hiveService.deleteStockItem(id);
      Get.log('Item deleted from remote and cache: $id');
    } catch (e) {
      Get.log('Failed to delete item remotely: $e', isError: true);
      rethrow;
    }
  }

  /// Create transaction: Save to Supabase and cache
  Future<StockTransaction> createTransaction(StockTransaction transaction) async {
    try {
      final createdTransaction = await _supabaseService.createTransaction(transaction);
      
      // Update cache
      await _hiveService.putTransaction(createdTransaction);
      Get.log('Transaction created and cached: ${createdTransaction.itemName}');
      
      return createdTransaction;
    } catch (e) {
      Get.log('Failed to create transaction remotely: $e', isError: true);
      rethrow;
    }
  }

  /// Fetch transactions for specific item
  Future<List<StockTransaction>> fetchTransactionsForItem(String itemId) async {
    try {
      final transactions = await _supabaseService.getTransactionsForItem(itemId);
      Get.log('Fetched ${transactions.length} transactions for item $itemId');
      return transactions;
    } catch (e) {
      Get.log('Failed to fetch transactions, checking cache: $e');
      
      // Fallback to cache
      try {
        return await _hiveService.getTransactionsForItem(itemId);
      } catch (cacheError) {
        Get.log('Cache read error: $cacheError', isError: true);
        rethrow;
      }
    }
  }

  /// Clear all local cache (useful for testing or logout)
  Future<void> clearCache() async {
    await _hiveService.clearAll();
    Get.log('Local cache cleared');
  }

  /// Get cache statistics
  Future<Map<String, int>> getCacheStats() async {
    return await _hiveService.getCacheStats();
  }
}
