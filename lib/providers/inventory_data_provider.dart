import '../models/stock_item.dart';
import '../models/stock_transaction.dart';
import '../services/supabase_service.dart';

/// Provides data access for inventory-related resources, sitting between
/// low-level services and presentation controllers.
class InventoryDataProvider {
  InventoryDataProvider({SupabaseService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseService();

  final SupabaseService _supabaseService;

  Future<List<StockItem>> fetchStockItems() {
    return _supabaseService.getStockItems();
  }

  Future<List<StockTransaction>> fetchTransactions() {
    return _supabaseService.getTransactions();
  }

  Future<StockItem> createStockItem(StockItem item) {
    return _supabaseService.createStockItem(item);
  }

  Future<StockItem> updateStockItem(String id, StockItem item) {
    return _supabaseService.updateStockItem(id, item);
  }

  Future<void> deleteStockItem(String id) {
    return _supabaseService.deleteStockItem(id);
  }

  Future<StockTransaction> createTransaction(StockTransaction transaction) {
    return _supabaseService.createTransaction(transaction);
  }

  Future<List<StockTransaction>> fetchTransactionsForItem(String itemId) {
    return _supabaseService.getTransactionsForItem(itemId);
  }
}
