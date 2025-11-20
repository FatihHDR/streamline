import 'package:get/get.dart';
import '../../../providers/inventory_data_provider.dart';
import '../../../services/supabase_service.dart';
import '../controllers/inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SupabaseService>(() => SupabaseService());
    Get.lazyPut<InventoryDataProvider>(
      () => InventoryDataProvider(supabaseService: Get.find<SupabaseService>()),
    );
    Get.put<InventoryController>(
      InventoryController(dataProvider: Get.find<InventoryDataProvider>()),
      permanent: true,
    );
  }
}
