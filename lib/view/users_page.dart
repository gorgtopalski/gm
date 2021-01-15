import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gm/common/validate.dart';
import 'package:gm/data/database_objects.dart';
import 'package:gm/data/datatables.dart';
import 'package:gm/widgets/buttons.dart';
import 'package:gm/widgets/notifications.dart';
import 'package:hive/hive.dart';

class UsersPageController extends GetxController {
  //The amount of rows for each page, initial value 10
  final rowsPerPage = PaginatedDataTable.defaultRowsPerPage.obs;

  //The column on witch data is sorted
  final sortColumnIndex = 0.obs;

  //Ascending / Descending sorting
  final sortColumnAsc = true.obs;

  //Is the search bar visual
  final showSearchBar = false.obs;
}

class UsersPageSource extends HiveDataTableSource<User> {
  UsersPageSource() : super(hiveBox: Hive.box<User>('users'));

  @override
  DataRow toGetRow(int index) {
    var user = list[index];

    return DataRow.byIndex(
      index: index,
      cells: user.asDataCells(),
      onSelectChanged: (_) async {
        var result = await Get.toNamed('/users/${user.key}');

        // if the value was modified, resync db values
        if (result ?? false) {
          syncDb();
        }
      },
    );
  }
}

class UsersPage extends StatelessWidget {
  // Labels, headers and tooltip strings.
  // TODO: Move string to somewhere else
  static final String idColumnTooltip = 'Id de entrada';
  static final String syncTooltip = 'Sincronizar base de datos';
  static final String addTooltip = 'Añadir usuario';
  static final String searchTooltip = 'Buscar usuario';

  static final String nameColumnHeader = 'Nombre';
  static final String surenameColumnHeader = 'Apellidos';
  static final String teamColumnHeader = 'Equipo';

  static final String pageTitle = 'Usuarios';

  // Access the page state with getX
  final controller = Get.find<UsersPageController>();

  // Access the datasource for the data table
  final dataSource = Get.find<UsersPageSource>();

  // Sort method for the column
  void _sort<T>(
    Comparable<T> Function(User m) getField,
    int columnIndex,
    bool ascending,
  ) {
    dataSource.sort<T>(getField, ascending);
    controller.sortColumnIndex.value = columnIndex;
    controller.sortColumnAsc.value = ascending;
  }

  // Page widget
  @override
  Widget build(BuildContext context) {
    // Page actions action
    final actions = <Widget>[
      IconButton(
        icon: Icon(Icons.person_add),
        tooltip: addTooltip,
        onPressed: () async {
          var result = await Get.toNamed('/users/');
          if (result ?? false) {
            dataSource.syncDb();
          }
        },
      ),
      Obx(
        () => IconButton(
          icon: controller.showSearchBar()
              ? Icon(Icons.search_off)
              : Icon(Icons.search),
          tooltip: searchTooltip,
          onPressed: () => controller.showSearchBar.toggle(),
        ),
      ),
      IconButton(
          icon: Icon(Icons.sync),
          tooltip: syncTooltip,
          onPressed: () {
            dataSource.syncDb();
            Notify.dismissible(context, 'Base de datos sincronizada!');
          }),
    ];

    // Data table columns
    final columns = <DataColumn>[
      DataColumn(
          numeric: true,
          label: Icon(Icons.vpn_key),
          tooltip: idColumnTooltip,
          onSort: (columnIndex, ascending) =>
              _sort<dynamic>((m) => m.key, columnIndex, ascending)),
      DataColumn(
          numeric: false,
          label: Text(nameColumnHeader),
          onSort: (columnIndex, ascending) =>
              _sort<String>((m) => m.name, columnIndex, ascending)),
      DataColumn(
          numeric: false,
          label: Text(surenameColumnHeader),
          onSort: (columnIndex, ascending) =>
              _sort<String>((m) => m.surename, columnIndex, ascending)),
      DataColumn(
          numeric: true,
          label: Text(teamColumnHeader),
          onSort: (columnIndex, ascending) =>
              _sort<num>((m) => m.team, columnIndex, ascending))
    ];

    return Scaffold(
        appBar: AppBar(
          title: Text(pageTitle),
          actions: actions,
        ),
        body: Scrollbar(
          child: ListView(
            padding: const EdgeInsets.all(8),
            children: [
              // Searchbar
              Obx(
                () => Visibility(
                  visible: controller.showSearchBar(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      decoration: InputDecoration(
                          icon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                          labelText: searchTooltip),
                      autofocus: true,
                      // Sends key strokes to the datasource and filter the data displayed on the table
                      onChanged: (value) => dataSource.filter(value),
                    ),
                  ),
                ),
              ),
              // DataTable
              Obx(
                () => PaginatedDataTable(
                  columns: columns,
                  showCheckboxColumn: false,
                  source: dataSource,
                  sortColumnIndex: controller.sortColumnIndex(),
                  sortAscending: controller.sortColumnAsc(),
                  rowsPerPage: controller.rowsPerPage(),
                  onRowsPerPageChanged: (index) =>
                      controller.rowsPerPage.value = index,
                ),
              ),
            ],
          ),
        ));
  }
}

class UserFormController extends GetxController {
  final user = User().obs;
  final isNew = true.obs;

  UserFormController() : super() {
    var id = Get.parameters['id'];
    if (id.isNotEmpty) {
      var key = num.tryParse(id);
      var box = Hive.box<User>('users');
      if (box.containsKey(key)) {
        user.value = box.get(key);
        isNew.toggle();
      }
    }
  }
}

class UsersFormPage extends StatelessWidget {
  final controller = Get.find<UserFormController>();
  final formKey = GlobalKey<FormState>();

  static final String pageTitleCreate = "Añadir usuario";
  static final String pageTitleEdit = "Editar usuario";
  static final String saveTooltipText = "Guardar";
  static final String cancelTootltipText = "Cancelar";

  void onFormSubmit() async {
    if (formKey.currentState.validate()) {
      if (!controller.user().isInBox) {
        await Hive.box<User>('users').add(controller.user());
      } else {
        await controller.user().save();
      }
      Get.back(result: true);
    }
  }

  void _delete() async {
    Get.defaultDialog(
      radius: 10,
      title: "Borrar registro",
      middleText: "Desea borrar ${controller.user} ?",
      textConfirm: "Si",
      textCancel: "No",
      onConfirm: () async {
        await controller.user().delete();
        Get.offAndToNamed('/');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: controller.isNew() ? Text(pageTitleCreate) : Text(pageTitleEdit),
        actions: [
          Visibility(
            visible: !controller.isNew(),
            child: FlatButton.icon(
                onPressed: _delete,
                icon: Icon(Icons.delete),
                label: Text("Borrar")),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: Scrollbar(
          child: SingleChildScrollView(
              child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 12,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: "Nombre",
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.person)),
                    initialValue: controller.user.value.name,
                    validator: (value) => FormValidator.emptyField(value),
                    onChanged: (value) => controller.user().name = value,
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: "Apellidos",
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.person_outline)),
                    initialValue: controller.user.value.surename,
                    validator: (value) => FormValidator.emptyField(value),
                    onChanged: (value) => controller.user().surename = value,
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  DropdownButtonFormField(
                    value: controller.user().team,
                    decoration: InputDecoration(
                        labelText: 'Equipo',
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.people)),
                    items: <DropdownMenuItem<int>>[
                      DropdownMenuItem(
                        child: Text('1'),
                        value: 1,
                      ),
                      DropdownMenuItem(
                        child: Text('2'),
                        value: 2,
                      ),
                      DropdownMenuItem(
                        child: Text('3'),
                        value: 3,
                      ),
                      DropdownMenuItem(
                        child: Text('4'),
                        value: 4,
                      ),
                      DropdownMenuItem(
                        child: Text('5'),
                        value: 5,
                      ),
                    ],
                    validator: (field) => FormValidator.selectField(field),
                    onChanged: (int value) {
                      controller.user().team = value;
                    },
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  SaveCancelButtonBar(
                    onSave: onFormSubmit,
                    onCancel: () => Get.back(result: false),
                  ),
                ]),
          )),
        ),
      ),
    );
  }
}
