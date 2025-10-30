import 'package:flutter/foundation.dart';
import '../models/stock_item.dart';
import '../models/stock_transaction.dart';
import '../services/api_service.dart';

class InventoryProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<StockItem> _items = [];
  List<StockTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<StockItem> get items => _items;
  List<StockTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStockItems() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _apiService.getStockItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTransactions() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _transactions = await _apiService.getTransactions();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<StockItem> getLowStockItems() {
    return _items.where((item) => item.isLowStock).toList();
  }

  StockItem? getItemById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (e) {
      return null;
    }
  }

  List<StockTransaction> getTransactionsForItem(String itemId) {
    return _transactions
        .where((transaction) => transaction.itemId == itemId)
        .toList();
  }
}
