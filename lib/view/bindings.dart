import 'package:get/get.dart';
import 'package:gm/view/dashboard.dart';
import 'package:gm/view/models_page.dart';
import 'package:gm/view/users_page.dart';

class GreaseMonkeyRouting {
  static List<GetPage> routes() {
    return <GetPage>[
      GetPage(
        name: '/',
        page: () => DashboardPage(),
        binding: DashboardBinding(),
      ),
      GetPage(
          name: '/models',
          page: () => ModelsPage(),
          binding: ModelsPageBinding()),
      GetPage(
          name: '/models/:id',
          page: () => ModelsFormPage(),
          binding: ModelsFormBinding()),
      GetPage(
        name: '/users',
        page: () => UsersPage(),
        binding: UserPageBinding(),
      ),
      GetPage(
        name: '/users/:id',
        page: () => UsersFormPage(),
        binding: UsersFormBinding(),
      ),
    ];
  }
}

class DashboardBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(() => DashboardController());
  }
}

class ModelsPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModelsPageController>(() => ModelsPageController());
    Get.lazyPut<ModelsPageSource>(() => ModelsPageSource());
  }
}

class ModelsFormBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ModelsFormController>(() => ModelsFormController());
  }
}

class UserPageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UsersPageController>(() => UsersPageController());
    Get.lazyPut<UsersPageSource>(() => UsersPageSource());
  }
}

class UsersFormBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserFormController>(() => UserFormController());
  }
}
