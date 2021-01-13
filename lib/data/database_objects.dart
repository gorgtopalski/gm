import 'package:flutter/material.dart';
import 'package:gm/common/format.dart';
import 'package:hive/hive.dart';
import 'package:get/get.dart';

part 'database_objects.g.dart';

abstract class Filtrable {
  bool filter(String value);
}

abstract class AsDataCells {
  List<DataCell> asDataCells();
}

@HiveType(typeId: 0)
class Model extends HiveObject implements Filtrable, AsDataCells {
  @HiveField(0)
  String name;

  @HiveField(1)
  String blueprint;

  @HiveField(2)
  DateTime lastModifed = DateTime.fromMillisecondsSinceEpoch(0);

  Model({this.name, this.blueprint});

  @override
  Future<void> save() {
    lastModifed = DateTime.now();
    return super.save();
  }

  @override
  String toString() {
    return '[$blueprint] $name';
  }

  @override
  bool filter(String value) {
    return (name.isCaseInsensitiveContainsAny(value) ||
        blueprint.isCaseInsensitiveContainsAny(value));
  }

  @override
  List<DataCell> asDataCells() {
    return <DataCell>[
      DataCell(Text('$key')),
      DataCell(Text('$name')),
      DataCell(Text('$blueprint')),
      DataCell(Text('${DateFormatters.dateToDMY(lastModifed)}')),
    ];
  }
}

@HiveType(typeId: 1)
class User extends HiveObject implements Filtrable, AsDataCells {
  @HiveField(0)
  String name;

  @HiveField(1)
  String surename;

  @HiveField(2)
  int team;

  User({this.name, this.surename, this.team}) : assert(team > 0 && team <= 5);

  @override
  String toString() {
    return '$surename, $name';
  }

  @override
  bool filter(String value) {
    return (name.isCaseInsensitiveContainsAny(value) ||
        surename.isCaseInsensitiveContainsAny(value) ||
        team.toString().isCaseInsensitiveContainsAny(value));
  }

  @override
  List<DataCell> asDataCells() {
    return <DataCell>[
      DataCell(Text('$key')),
      DataCell(Text('$name')),
      DataCell(Text('$surename')),
      DataCell(Text('$team')),
    ];
  }
}
