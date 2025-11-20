import '../models/stock_item.dart';
import '../models/stock_transaction.dart';

/// Abstract interface for data providers
abstract class IDataProvider {
  Future<List<StockItem>> fetchStockItems();
  Future<List<StockTransaction>> fetchTransactions();
  Future<StockItem> createStockItem(StockItem item);
  Future<StockItem> updateStockItem(String id, StockItem item);
  Future<void> deleteStockItem(String id);
  Future<StockTransaction> createTransaction(StockTransaction transaction);
  Future<List<StockTransaction>> fetchTransactionsForItem(String itemId);
}
