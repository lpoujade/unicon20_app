import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:developer';

const db_name = 'unicon_db.db';
const db_version = 1;

const init_sql = [
  'create table article ( id integer unique, title text, content text, important integer default 0, date integer not null)',
];

init_database() async {
  // await deleteDatabase(db_name);
  return openDatabase(join(await getDatabasesPath(), db_name),
      version: db_version, onCreate: (Database db, int version) async {
    var batch = db.batch();
    init_sql.forEach((script) => batch.execute(script));
    await batch.commit();
  }, onConfigure: (Database db) async {
    await db.execute("pragma foreign_keys = ON");
  });
}

Future<DateTime?> get_last_sync_date(db) async {
  var sql = 'select date from article order by date desc limit 1';
  final result = await db.rawQuery(sql);
  return (result.length == 1)
      ? DateTime.fromMillisecondsSinceEpoch((result.first)['date'])
      : null;
}
