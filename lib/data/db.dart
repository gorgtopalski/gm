import 'package:gm/data/database_objects.dart';
import 'package:hive/hive.dart';

class Db {
  static Box<User> get users => Hive.box<User>('users');
  static Box<Model> get models => Hive.box<Model>('models');
}
