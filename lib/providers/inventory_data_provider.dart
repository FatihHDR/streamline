import '../models/stock_item.dart';
import '../models/stock_transaction.dart';
import '../services/api_service.dart';

/// Provides data access for inventory-related resources, sitting between
/// low-level services and presentation controllers.
class InventoryDataProvider {
  InventoryDataProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  final ApiService _apiService;

  Future<List<StockItem>> fetchStockItems() {
    return _apiService.getStockItems();
  }

  Future<List<StockTransaction>> fetchTransactions() {
    return _apiService.getTransactions();
  }
}
