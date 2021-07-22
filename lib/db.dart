import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

const db_version = 1;
const db_name = 'unicon_db.db';
const initial_db_creation = [
  'create table article (title text, content text)'
];


database () async {
  return openDatabase(join(await getDatabasesPath(), db_name), version: db_version,
      onCreate: (Database db, int version) async {
        initial_db_creation.forEach((script) async => await db.execute(script));  
      }
  );
}
