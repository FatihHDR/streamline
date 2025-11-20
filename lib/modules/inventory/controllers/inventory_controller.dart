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
}
