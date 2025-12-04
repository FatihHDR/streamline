import 'package:get/get.dart';
import '../controllers/location_controller.dart';
import '../services/location_service.dart';

class LocationBinding extends Bindings {
  @override
  void dependencies() {
    // Service - permanent karena dibutuhkan di banyak tempat
    Get.put<LocationService>(LocationService(), permanent: true);
    
    // Controller
    Get.lazyPut<LocationController>(() => LocationController());
  }
}
