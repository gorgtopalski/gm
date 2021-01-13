import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DashboardController extends GetxController {
  final value = 0.obs;
  final locked = true.obs;
}

class DashboardPage extends StatelessWidget {
  final controller = Get.put(DashboardController());

  final String title = "Grease Monkey";
  final drawerItems = ListView(children: [
    UserAccountsDrawerHeader(
      accountName: Text("Hello"),
      accountEmail: Text("Hello@gmail.com"),
    ),
    ListTile(
      leading: Icon(Icons.home),
      title: Text('Inicio'),
      onTap: () {},
    ),
    ListTile(
      leading: Icon(Icons.thermostat_outlined),
      title: Text('Temperaturas'),
      onTap: () {},
    ),
    ListTile(
      leading: Icon(Icons.looks),
      title: Text('Presiones'),
      onTap: () {},
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
  ]);

  @override
  Widget build(BuildContext context) {
    var q = <DropdownMenuItem>[
      DropdownMenuItem(
        value: 0,
        child: Text('Gueorgui Topalski'),
      ),
      DropdownMenuItem(
        value: 1,
        child: Text('Hello 2'),
      ),
      DropdownMenuItem(
        value: 2,
        child: Text('Hello 3'),
      )
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          Obx(
            () => DropdownButton(
              value: controller.value(),
              items: q,
              icon: Icon(Icons.person),
              onChanged: (value) => controller.value.value = value,
            ),
          ),
          IconButton(
            icon: Icon(Icons.dashboard),
            onPressed: () {},
            tooltip: "Vista global",
          ),
          IconButton(
            icon: Icon(Icons.add_box),
            onPressed: null,
            tooltip: "Actuaciones",
          ),
          IconButton(
            icon: Icon(Icons.thermostat_outlined),
            onPressed: null,
            tooltip: "Temperaturas",
          ),
          IconButton(
            icon: Icon(Icons.av_timer),
            onPressed: null,
            tooltip: "Presiones",
          ),
        ],
      ),
      drawer: Drawer(child: drawerItems),
    );
  }
}
