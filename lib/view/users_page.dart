import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gm/data/database_objects.dart';
import 'package:gm/data/datatables.dart';
import 'package:gm/widgets/notifications.dart';
import 'package:hive/hive.dart';

class UsersController extends GetxController {
  //The amount of rows for each page, initial value 10
  final rowsPerPage = PaginatedDataTable.defaultRowsPerPage.obs;

  //The column on witch data is sorted
  final sortColumnIndex = 0.obs;

  //Ascending / Descending sorting
  final sortColumnAsc = true.obs;

  //Is the search bar visual
  final showSearchBar = false.obs;
}

class UsersDataTableSource extends HiveDataTableSource<User> {
  UsersDataTableSource() : super(hiveBox: Hive.box<User>('users'));

  @override
  DataRow toGetRow(int index) {
    var user = list[index];

    return DataRow.byIndex(
      index: index,
      onSelectChanged: (_) async {},
      cells: user.asDataCells(),
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
  final controller = Get.put(UsersController());

  // Access the datasource for the data table
  final dataSource = UsersDataTableSource();

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
        icon: Icon(Icons.add),
        tooltip: addTooltip,
        onPressed: () {
          Get.toNamed('/users/form', arguments: new User());
          dataSource.syncDb();
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
