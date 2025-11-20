import 'package:get/get.dart';
import '../../../providers/offline_first_data_provider.dart';
import '../../../services/supabase_service.dart';
import '../../../services/hive_service.dart';
import '../../../services/sync_queue_service.dart';
import '../controllers/inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.lazyPut<SupabaseService>(() => SupabaseService());
    Get.lazyPut<HiveService>(() => HiveService());
    
    // SyncQueueService already initialized in main.dart, just find it
    // Data provider with offline-first strategy
    Get.lazyPut<OfflineFirstDataProvider>(
      () => OfflineFirstDataProvider(
        supabaseService: Get.find<SupabaseService>(),
        hiveService: Get.find<HiveService>(),
        syncQueueService: Get.find<SyncQueueService>(),
      ),
    );
    
    // Controller
    Get.put<InventoryController>(
      InventoryController(dataProvider: Get.find<OfflineFirstDataProvider>()),
      permanent: true,
    );
  }
}
