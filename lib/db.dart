import 'package:sqflite/sqflite.dart';
import 'dart:developer';

const db_name = 'unicon_db.db';
const db_version = 1;

const init_sql = [
  'create table article ( id integer unique, title text, content text, important integer default 0, date integer not null, read integer default 0, img text)',
  'create table events ( uid text unique not null, title text not null, start integer not null, end integer not null, location text not null, type text not null, description text, summary text)'
];

/// Open connection to database
/// Also register callback for db creation/migration/configuration
init_database() async {
  // TODO remove
  await deleteDatabase(db_name);
  return openDatabase(db_name, version: db_version,
      onCreate: (Database db, int version) async {
    var batch = db.batch();
    init_sql.forEach(batch.execute);
    await batch.commit();
  }, onConfigure: (Database db) async {
    await db.execute("pragma foreign_keys = ON");
  });
}

/// Read date of the most recent article in local database,
/// if any
Future<DateTime?> get_last_sync_date(db) async {
  var sql = 'select date from article order by date desc limit 1';
  final result = await db.rawQuery(sql);
  return (result.length == 1)
      ? DateTime.fromMillisecondsSinceEpoch((result.first)['date'])
      : null;
}
