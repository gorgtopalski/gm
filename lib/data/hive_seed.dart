import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:logging/logging.dart';

import 'database_objects.dart';

class HiveSeeder {
  final log = Logger("HiveSeeder");
  void info(msg) => log.log(Level.INFO, msg);
  void warn(msg) => log.log(Level.WARNING, msg);

  void seedUsers() async {
    var file = File('seed/users.csv');
    if (file.existsSync()) {
      info('seed/users.csv found');
      info('Seeding users');

      var box = await Hive.openBox<User>('users');

      Stream<List> inputStream = file.openRead();
      inputStream
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((String line) async {
        var row = line.split(',');
        await box.add(User(
            name: row[0], surename: row[1], team: int.tryParse(row[2]) ?? 0));
      });
      await box.compact();
      info('${box.values.length} users added');
    } else {
      warn('seed/users.csv not found');
    }
  }

  void seedModels() async {
    var file = File('seed/models.csv');
    if (file.existsSync()) {
      info('seed/models.csv found');
      info('Seeding models');

      var box = await Hive.openBox<Model>('models');

      Stream<List> inputStream = file.openRead();
      inputStream
          .transform(utf8.decoder)
          .transform(LineSplitter())
          .listen((String line) async {
        var row = line.split(',');
        await box.add(Model(name: row[0], blueprint: row[1]));
      });
      await box.compact();
      info('${box.values.length} models added');
    } else {
      warn('db/seed/models.csv not found');
    }
  }
}
