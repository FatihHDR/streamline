import 'package:get/get.dart';
import '../../../models/stock_item.dart';
import '../../../models/stock_transaction.dart';
import '../../../providers/i_data_provider.dart';
import '../../../providers/inventory_data_provider.dart';
import '../../../services/fcm_notification_service.dart';

class InventoryController extends GetxController {
  InventoryController({IDataProvider? dataProvider})
      : _dataProvider = dataProvider ?? InventoryDataProvider();

  final IDataProvider _dataProvider;

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
      
      // Show local notification
      try {
        Get.find<FCMNotificationService>().showNotification(
          title: 'Barang Ditambahkan',
          body: '${createdItem.name} berhasil ditambahkan ke inventaris.',
          type: 'general',
          data: {'item_id': createdItem.id},
        );
      } catch (e) {
        Get.log('Error showing notification: $e', isError: true);
      }
      
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

  /// Adjust stock quantity and record transaction
  Future<void> adjustStock({
    required String itemId,
    required int quantityChange,
    required TransactionType type,
    String? note,
  }) async {
    try {
      final item = getItemById(itemId);
      if (item == null) throw Exception('Item not found');

      // 1. Calculate new quantity
      final newQuantity = item.quantity + (type == TransactionType.incoming ? quantityChange : -quantityChange);
      
      if (newQuantity < 0) {
        throw Exception('Stok tidak mencukupi for outgoing transaction');
      }

      // 2. Update Stock Item
      final updatedItem = item.copyWith(
        quantity: newQuantity,
        lastUpdated: DateTime.now(),
      );
      await updateStockItem(itemId, updatedItem);

      // 3. Create Transaction Record
      final transaction = StockTransaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temporary ID, will be replaced by backend or UUID
        itemId: itemId,
        itemName: item.name,
        type: type,
        quantity: quantityChange,
        date: DateTime.now(),
        note: note,
        performedBy: 'User', // TODO: Get actual user name
      );

      await createTransaction(transaction);
      
      Get.log('Stock adjusted successfully for ${item.name}');
    } catch (e) {
      Get.log('Failed to adjust stock: $e', isError: true);
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
      
      // Check for low stock after transaction
      final item = getItemById(transaction.itemId);
      if (item != null) {
        _checkLowStock(item);
      }
      
      return createdTransaction;
    } catch (e) {
      Get.log('Failed to create transaction: $e', isError: true);
      rethrow;
    }
  }

  /// Check for low stock and trigger notification
  void _checkLowStock(StockItem item) {
    try {
      if (item.isOutOfStock) {
         Get.find<FCMNotificationService>().showNotification(
          title: 'Stok Habis!',
          body: 'Stok untuk ${item.name} telah habis. Segera lakukan restock.',
          type: 'out_of_stock',
          data: {'item_id': item.id},
        );
      } else if (item.isLowStock) {
        Get.find<FCMNotificationService>().showNotification(
          title: 'Stok Menipis',
          body: 'Stok ${item.name} tersisa ${item.quantity} ${item.unit}.',
          type: 'low_stock',
          data: {'item_id': item.id},
        );
      }
    } catch (e) {
      Get.log('Error triggering low stock notification: $e', isError: true);
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Listen to changes for low stock monitoring could vary, 
    // but here we trigger on specific actions.
  }
}
