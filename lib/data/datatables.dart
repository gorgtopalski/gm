import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'database_objects.dart';

abstract class HiveDataTableSource<T> extends DataTableSource {
  // The HiveDb box where data is stored
  final Box<T> hiveBox;

  // The cached list of the data
  List<T> list = <T>[];

  HiveDataTableSource({this.hiveBox}) {
    assert(hiveBox.isOpen);

    // Seed list with data from the HiveDb box
    list = hiveBox.values.toList();
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => list.length;

  @override
  int get selectedRowCount => 0;

  // Sort function used to compare and sort the columns of the data table
  void sort<E>(Comparable<E> Function(T t) getField, bool ascending) {
    list.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);
      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  // Force resync with the HiveDB box
  void syncDb() async {
    list = hiveBox.values.toList();
    notifyListeners();
  }

  // Filter data that contains the provided string
  // Values must implement the Filtrable interface
  void filter(String value) {
    if (value == null || value.isEmpty) {
      this.syncDb();
    } else {
      list = hiveBox.values
          .toList()
          .where((element) => (element as Filtrable).filter(value))
          .toList();
      notifyListeners();
    }
  }

  @override
  DataRow getRow(int index) {
    // Common index check before calling the function
    assert(index >= 0);
    if (index >= list.length) return null;

    return toGetRow(index);
  }

  // Retrieves each row of data. Implemented by each data type.
  DataRow toGetRow(int index);
}
