import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gm/common/validate.dart';
import 'package:gm/data/database_objects.dart';
import 'package:gm/data/datatables.dart';
import 'package:gm/data/db.dart';
import 'package:gm/widgets/buttons.dart';
import 'package:gm/widgets/notifications.dart';
//import 'package:hive/hive.dart';

//State for the page that displays the model data table
class ModelsPageController extends GetxController {
  //The amount of rows for each page, initial value 10
  final rowsPerPage = PaginatedDataTable.defaultRowsPerPage.obs;

  //The column on witch data is sorted
  final sortColumnIndex = 0.obs;

  //Ascending / Descending sorting
  final sortColumnAsc = true.obs;

  //Is the search bar visual
  final showSearchBar = false.obs;
}

// The page that displays the models data table
class ModelsPage extends StatelessWidget {
  // Labels, headers and tooltip strings.
  // TODO: Move string to somewhere else
  static final String idColumnTooltip = 'Id de entrada';
  static final String nameColumnTooltip = 'Nombre del modelo';
  static final String blueprintColumnTooltip = 'Plano maqueta del modelo';
  static final String lastDateColumnTooltip = 'Fecha de la ultima fabricación';
  static final String syncTooltip = 'Sincronizar base de datos';
  static final String addTooltip = 'Añadir modelo';
  static final String searchTooltip = 'Buscar modelo';

  static final String nameColumnHeader = 'Nombre';
  static final String blueprintColumnHeader = 'Plano Maqueta';
  static final String lastDateColumnHeader = 'Ultima Fabricación';

  static final String pageTitle = 'Modelos';

  // Access the page state with getX
  final controller = Get.find<ModelsPageController>();

  // Access the datasource for the data table
  final dataSource = Get.find<ModelsPageSource>();

  // Sort method for the column
  void _sort<T>(
    Comparable<T> Function(Model m) getField,
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
          Get.toNamed('/models/');
          //Get.to(ModelsFormPage(), arguments: new Model());
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
          tooltip: nameColumnTooltip,
          onSort: (columnIndex, ascending) =>
              _sort<String>((m) => m.name, columnIndex, ascending)),
      DataColumn(
          numeric: false,
          label: Text(blueprintColumnHeader),
          tooltip: blueprintColumnTooltip,
          onSort: (columnIndex, ascending) =>
              _sort<String>((m) => m.blueprint, columnIndex, ascending)),
      DataColumn(
          numeric: true,
          label: Text(lastDateColumnHeader),
          tooltip: lastDateColumnTooltip,
          onSort: (columnIndex, ascending) =>
              _sort<DateTime>((m) => m.lastModifed, columnIndex, ascending))
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

// Data table source for the models page
class ModelsPageSource extends HiveDataTableSource<Model> {
  ModelsPageSource() : super(hiveBox: Db.models);

  @override
  DataRow toGetRow(int index) {
    var model = list[index];

    return DataRow.byIndex(
      index: index,
      cells: model.asDataCells(),
      onSelectChanged: (_) async {
        var result = await Get.toNamed('/models/${model.key}');

        // if the value was modified, resync db values
        if (result ?? false) {
          syncDb();
        }
      },
    );
  }
}

class ModelsFormController extends GetxController {
  final model = Model().obs;
  final isNew = true.obs;

  ModelsFormController() : super() {
    var id = Get.parameters['id'];
    if (id.isNotEmpty) {
      var key = num.tryParse(id);
      var box = Db.models;
      if (box.containsKey(key)) {
        model.value = box.get(key);
        isNew.toggle();
      }
    }
  }
}

class ModelsFormPage extends StatelessWidget {
  final formKey = GlobalKey<FormState>();
  final controller = Get.find<ModelsFormController>();

  static final String pageTitleCreate = "Crear modelo";
  static final String pageTitleEdit = "Editar modelo";
  static final String saveTooltipText = "Guardar";
  static final String cancelTootltipText = "Cancelar";

  void onFormSubmit() async {
    if (formKey.currentState.validate()) {
      if (!controller.model.value.isInBox) {
        await Db.models.add(controller.model.value);
      } else {
        await controller.model.value.save();
      }
      Get.back(result: true);
    }
  }

  void _delete() async {
    Get.defaultDialog(
      radius: 10,
      title: "Borrar registro",
      middleText: "Desea borrar ${controller.model} ?",
      textConfirm: "Si",
      textCancel: "No",
      onConfirm: () async {
        await controller.model().delete();
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
                        labelText: "Modelo",
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.view_headline)),
                    initialValue: controller.model.value.name,
                    validator: (value) => FormValidator.emptyField(value),
                    onChanged: (value) => controller.model.value.name = value,
                  ),
                  SizedBox(
                    height: 24,
                  ),
                  TextFormField(
                    decoration: InputDecoration(
                        labelText: "Plano Maqueta",
                        border: OutlineInputBorder(),
                        icon: Icon(Icons.topic)),
                    initialValue: controller.model.value.blueprint,
                    validator: (value) => FormValidator.emptyField(value),
                    onChanged: (value) =>
                        controller.model.value.blueprint = value,
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
