import 'package:get/get.dart';
import 'package:gm/view/models_page.dart';

class ModelsFormBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModelsFormState>(() => ModelsFormState());
  }
}
