import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/warehouse_model.dart';

class WarehouseService extends GetxService {
  late Box<Warehouse> _warehouseBox;
  final RxList<Warehouse> warehouses = <Warehouse>[].obs;
  final Rxn<Warehouse> selectedWarehouse = Rxn<Warehouse>();

  @override
  void onInit() async {
    super.onInit();
    await _initHive();
    await _loadWarehouses();
    await _initializeSampleData();
  }

  Future<void> _initHive() async {
    _warehouseBox = await Hive.openBox<Warehouse>('warehouses');
    Get.log('Warehouse Hive box initialized');
  }

  Future<void> _loadWarehouses() async {
    warehouses.assignAll(_warehouseBox.values.toList());
    Get.log('Loaded ${warehouses.length} warehouses');
  }

  // Inisialisasi data sample jika belum ada
  Future<void> _initializeSampleData() async {
    if (_warehouseBox.isEmpty) {
      // Koordinat Malang: 7°54'48.6"S 112°37'32.6"E
      final malangWarehouse = Warehouse(
        id: 'wh_malang_001',
        name: 'Warehouse Malang',
        location: 'Jl. Raya Malang, Malang',
        latitude: -7.913500, // 7°54'48.6"S
        longitude: 112.626278, // 112°37'32.6"E
        sizeInSquareMeter: 5000.0,
        totalSlots: 500,
        occupiedSlots: 350,
        description: 'Gudang utama di Malang dengan kapasitas 5000 m²',
        city: 'Malang',
        province: 'Jawa Timur',
      );

      // Sample data gudang lain untuk demo
      final surabayaWarehouse = Warehouse(
        id: 'wh_surabaya_001',
        name: 'Warehouse Surabaya',
        location: 'Jl. Ahmad Yani, Surabaya',
        latitude: -7.2575, // Approximate Surabaya
        longitude: 112.7521,
        sizeInSquareMeter: 3000.0,
        totalSlots: 300,
        occupiedSlots: 150,
        description: 'Gudang di Surabaya dengan kapasitas 3000 m²',
        city: 'Surabaya',
        province: 'Jawa Timur',
      );

      final jakartaWarehouse = Warehouse(
        id: 'wh_jakarta_001',
        name: 'Warehouse Jakarta',
        location: 'Jl. Gatot Subroto, Jakarta',
        latitude: -6.2088, // Approximate Jakarta
        longitude: 106.8456,
        sizeInSquareMeter: 8000.0,
        totalSlots: 800,
        occupiedSlots: 720,
        description: 'Gudang besar di Jakarta dengan kapasitas 8000 m²',
        city: 'Jakarta',
        province: 'DKI Jakarta',
      );

      await addWarehouse(malangWarehouse);
      await addWarehouse(surabayaWarehouse);
      await addWarehouse(jakartaWarehouse);

      Get.log('Sample warehouse data initialized');
    }
  }

  // Add warehouse
  Future<void> addWarehouse(Warehouse warehouse) async {
    await _warehouseBox.put(warehouse.id, warehouse);
    warehouses.add(warehouse);
    Get.log('Warehouse added: ${warehouse.name}');
  }

  // Update warehouse
  Future<void> updateWarehouse(Warehouse warehouse) async {
    await _warehouseBox.put(warehouse.id, warehouse);
    final index = warehouses.indexWhere((w) => w.id == warehouse.id);
    if (index >= 0) {
      warehouses[index] = warehouse;
    }
    Get.log('Warehouse updated: ${warehouse.name}');
  }

  // Delete warehouse
  Future<void> deleteWarehouse(String warehouseId) async {
    await _warehouseBox.delete(warehouseId);
    warehouses.removeWhere((w) => w.id == warehouseId);
    Get.log('Warehouse deleted: $warehouseId');
  }

  // Get warehouse by ID
  Warehouse? getWarehouseById(String id) {
    try {
      return _warehouseBox.get(id);
    } catch (e) {
      Get.log('Error getting warehouse: $e');
      return null;
    }
  }

  // Get all warehouses
  List<Warehouse> getAllWarehouses() {
    return warehouses.toList();
  }

  // Select warehouse
  void selectWarehouse(Warehouse warehouse) {
    selectedWarehouse.value = warehouse;
  }

  // Get warehouse statistics
  Map<String, dynamic> getWarehouseStats() {
    int totalWarehouses = warehouses.length;
    int totalCapacity = 0;
    int totalOccupied = 0;
    double totalArea = 0;

    for (var warehouse in warehouses) {
      totalCapacity += warehouse.totalSlots;
      totalOccupied += warehouse.occupiedSlots;
      totalArea += warehouse.sizeInSquareMeter;
    }

    return {
      'totalWarehouses': totalWarehouses,
      'totalCapacity': totalCapacity,
      'totalOccupied': totalOccupied,
      'availableSlots': totalCapacity - totalOccupied,
      'occupancyPercentage': totalCapacity > 0 ? (totalOccupied / totalCapacity) * 100 : 0,
      'totalArea': totalArea,
      'averageArea': totalWarehouses > 0 ? totalArea / totalWarehouses : 0,
    };
  }

  // Get warehouses near capacity
  List<Warehouse> getWarehousesNearCapacity({double threshold = 80}) {
    return warehouses.where((w) => w.occupancyPercentage >= threshold).toList();
  }

  // Search warehouses
  List<Warehouse> searchWarehouses(String query) {
    return warehouses
        .where((w) =>
            w.name.toLowerCase().contains(query.toLowerCase()) ||
            w.city.toLowerCase().contains(query.toLowerCase()) ||
            w.location.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}
