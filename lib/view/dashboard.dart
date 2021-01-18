import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gm/common/format.dart';
import 'package:gm/data/database_objects.dart';
import 'package:gm/widgets/user_setup.dart';

class DashboardController extends GetxController {
  final value = 0.obs;
  final locked = true.obs;

  final currentUser = User().obs;
  final team = 0.obs;
  final shift = 0.obs;
  final currentDate = DateTime.now().obs;

  final navRailIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();

    ever(currentDate,
        (_) => shift.value = DateFormatters.dateToShift(currentDate.value));
    ever(currentUser, (_) => team.value = currentUser.value.team);

    currentDate.value = DateTime.now();
  }
}

class DashboardPage extends StatelessWidget {
  final controller = Get.put(DashboardController());
  static const String title = "Grease Monkey";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [CurrentUserSelection()],
      ),
      drawer: Drawer(
        child: ListView(children: [
          UserAccountsDrawerHeader(
            accountName: Obx(() => Text(controller.currentUser().toString())),
            accountEmail:
                Obx(() => Text('Equipo: ${controller.team().toString()}')),
          ),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Principal'),
            onTap: () => Get.offAllNamed('/'),
          ),
          ListTile(
            leading: Icon(Icons.topic),
            title: Text('Modelos'),
            onTap: () {
              Get.toNamed('/models');
            },
          ),
          ListTile(
            leading: Icon(Icons.ac_unit),
            title: Text('Fabricaciones'),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('Usuarios'),
            onTap: () {
              Get.toNamed('/users');
            },
          ),
        ]),
      ),
      body: Row(
        children: [
          Obx(
            () => NavigationRail(
              selectedIndex: controller.navRailIndex(),
              labelType: NavigationRailLabelType.all,
              onDestinationSelected: (index) =>
                  controller.navRailIndex.value = index,
              destinations: [
                NavigationRailDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: Text('Inicio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.check_circle_outline),
                  selectedIcon: Icon(Icons.check_circle),
                  label: Text('Actuaciones'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.thermostat_outlined),
                  selectedIcon: Icon(Icons.device_thermostat),
                  label: Text('Temperaturas'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.av_timer_outlined),
                  selectedIcon: Icon(Icons.av_timer),
                  label: Text('Presiones'),
                ),
              ],
            ),
          ),
          VerticalDivider(thickness: 1, width: 1),
          // This is the main content.
          Expanded(
            child: Scaffold(
              body: Obx(() => Text('${controller.locked()}')),
            ),
          )
        ],
      ),
    );
  }
}
