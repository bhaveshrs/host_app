
import 'package:get/get.dart';
import 'package:host_app/connection_controller.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // Get.put<ConnectionController>(ConnectionController());
      Get.lazyPut<ConnectionController>(() => ConnectionController());

   
  }
}
