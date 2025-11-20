import 'package:get/get.dart';
import '../../../providers/inventory_data_provider.dart';
import '../../../services/api_service.dart';
import '../controllers/inventory_controller.dart';

class InventoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<InventoryDataProvider>(
      () => InventoryDataProvider(apiService: Get.find<ApiService>()),
    );
    Get.put<InventoryController>(
      InventoryController(dataProvider: Get.find<InventoryDataProvider>()),
      permanent: true,
    );
  }
}
