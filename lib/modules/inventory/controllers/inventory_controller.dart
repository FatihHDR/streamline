import 'package:get/get.dart';
import '../../../models/stock_item.dart';
import '../../../models/stock_transaction.dart';
import '../../../providers/inventory_data_provider.dart';

class InventoryController extends GetxController {
  InventoryController({InventoryDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? InventoryDataProvider();

  final InventoryDataProvider _dataProvider;

  final RxList<StockItem> items = <StockItem>[].obs;
  final RxList<StockTransaction> transactions = <StockTransaction>[].obs;

  final RxBool isItemsLoading = false.obs;
  final RxBool isTransactionsLoading = false.obs;

  final RxnString itemsError = RxnString();
  final RxnString transactionsError = RxnString();

  bool _hasLoadedItems = false;
  bool _hasLoadedTransactions = false;

  /// Loads both inventory items and their transactions when the app launches.
  Future<void> initializeData() async {
    await Future.wait([
      loadStockItems(),
      loadTransactions(),
    ]);
  }

  Future<void> loadStockItems({bool force = false}) async {
    if (_hasLoadedItems && !force) return;

    isItemsLoading.value = true;
    itemsError.value = null;

    try {
      final data = await _dataProvider.fetchStockItems();
      items.assignAll(data);
      _hasLoadedItems = true;
    } catch (e) {
      itemsError.value = e.toString();
    } finally {
      isItemsLoading.value = false;
    }
  }

  Future<void> loadTransactions({bool force = false}) async {
    if (_hasLoadedTransactions && !force) return;

    isTransactionsLoading.value = true;
    transactionsError.value = null;

    try {
      final data = await _dataProvider.fetchTransactions();
      transactions.assignAll(data);
      _hasLoadedTransactions = true;
    } catch (e) {
      transactionsError.value = e.toString();
    } finally {
      isTransactionsLoading.value = false;
    }
  }

  Future<void> refreshAll() async {
    await Future.wait([
      loadStockItems(force: true),
      loadTransactions(force: true),
    ]);
    Get.log('Inventory data refreshed');
  }

  List<StockItem> get lowStockItems {
    return items.where((item) => item.isLowStock).toList();
  }

  int get totalQuantity {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  int get outOfStockCount {
    return items.where((item) => item.isOutOfStock).length;
  }

  StockItem? getItemById(String id) {
    try {
      return items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  List<StockTransaction> getTransactionsForItem(String itemId) {
    return transactions.where((txn) => txn.itemId == itemId).toList();
  }

  void addItem(StockItem item) {
    items.insert(0, item);
  }

  /// Create a new stock item and persist to Supabase
  Future<StockItem> createStockItem(StockItem item) async {
    try {
      final createdItem = await _dataProvider.createStockItem(item);
      items.insert(0, createdItem);
      Get.log('Stock item created: ${createdItem.name}');
      return createdItem;
    } catch (e) {
      Get.log('Failed to create stock item: $e', isError: true);
      rethrow;
    }
  }

  /// Update an existing stock item
  Future<StockItem> updateStockItem(String id, StockItem item) async {
    try {
      final updatedItem = await _dataProvider.updateStockItem(id, item);
      final index = items.indexWhere((i) => i.id == id);
      if (index != -1) {
        items[index] = updatedItem;
      }
      Get.log('Stock item updated: ${updatedItem.name}');
      return updatedItem;
    } catch (e) {
      Get.log('Failed to update stock item: $e', isError: true);
      rethrow;
    }
  }

  /// Delete a stock item
  Future<void> deleteStockItem(String id) async {
    try {
      await _dataProvider.deleteStockItem(id);
      items.removeWhere((item) => item.id == id);
      Get.log('Stock item deleted: $id');
    } catch (e) {
      Get.log('Failed to delete stock item: $e', isError: true);
      rethrow;
    }
  }

  /// Create a new transaction
  Future<StockTransaction> createTransaction(StockTransaction transaction) async {
    try {
      final createdTransaction = await _dataProvider.createTransaction(transaction);
      transactions.insert(0, createdTransaction);
      Get.log('Transaction created for item: ${transaction.itemName}');
      return createdTransaction;
    } catch (e) {
      Get.log('Failed to create transaction: $e', isError: true);
      rethrow;
    }
  }
}
