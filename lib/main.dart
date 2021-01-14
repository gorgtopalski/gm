import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:gm/data/hive_seed.dart';
import 'package:gm/view/dashboard.dart';
import 'package:hive/hive.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import 'data/database_objects.dart';
import 'view/bindings.dart';

final log = Logger('main');
void info(msg) => log.log(Level.INFO, msg);
void err(msg) => log.log(Level.SHOUT, msg);

// Setup logging
void logging() {
  Logger.root.level = Level.ALL; // defaults to Level.INFO
  Logger.root.onRecord.listen((record) {
    print(
        '${record.time} [${record.loggerName}] ${record.level.name}: ${record.message}');
  });
}

// Force locale to spanish
// TODO: find a more 'elegant' way to do this
Future<void> locale() async {
  Intl.defaultLocale = 'es';
  await initializeDateFormatting('es', null);
}

// Generate the application theming
ThemeData generateTheme() {
  return ThemeData.from(
    colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.green,
        accentColor: Colors.greenAccent,
        brightness: Brightness.dark),
  );
}

// Setup the the database
Future<void> setupHive() async {
  final String db = 'db';
  var dir = Directory(db);

  if (!dir.existsSync()) {
    dir.createSync();
  }

  assert(dir.path != null);
  Hive
    ..init(dir.path)
    ..registerAdapter(ModelAdapter())
    ..registerAdapter(UserAdapter());

  var seeder = HiveSeeder();

  info("Open models box");
  Hive.openBox<Model>('models')
      .then((value) => value.isEmpty ? seeder.seedModels() : null);

  info("Open users box");
  Hive.openBox<User>('users')
      .then((value) => value.isEmpty ? seeder.seedUsers() : null);
}

// Flutter main method
Future<void> main() async {
  logging();
  info('Starting Grease Monkey');

  info('Force locale to spanish');
  await locale();

  info('Set up database');
  await setupHive();

  info('Start flutter application');
  runApp(GetMaterialApp(
    getPages: GreaseMonkeyRouting.routes(),
    theme: generateTheme(),
    title: "Grease Monkey",
    home: DashboardPage(),
    debugShowCheckedModeBanner: false,
  ));
}
