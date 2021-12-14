import 'package:sqflite/sqflite.dart';

const appid = 1;

const db_name = 'unicon_db.db';
const db_version = 2;

/// Initial database schema
const init_sql = [
  'create table article ( id integer unique, title text, content text, important integer default 0, date integer not null, read integer default 0, img text)',
  'create table events ( uid text unique not null, title text not null, start integer not null, end integer not null, location text not null, type text not null, description text, summary text)',
  'create table app_config ( appid integer primary key, locale text)'
];

// migrations
// key is the target version
const migrations = {
  2: [
    'create table categories (id integer primary key, title text)',
    'create table articles_categories (category references categories(id), article references article(id))'
  ]
};

/// Open connection to database
/// Also register callback for db creation/migration/configuration
init_database() async {
  return openDatabase(db_name, version: db_version,
      onCreate: (Database db, int version) async {
        print('create db v$version');
        var batch = db.batch();
        init_sql.forEach(batch.execute);
        await batch.commit();
      }, onConfigure: (Database db) async {
        await db.execute("pragma foreign_keys = ON");
      }, onUpgrade: (Database db, int cur_version, int new_version) async {
        print('upgrade db from v$cur_version to v$new_version');
        var batch = db.batch();
        print('will execute: ');
        while (++cur_version <= new_version) {
          if (!migrations.containsKey(cur_version)) {
            print("BAD MIGRATION VERSION NUMBER: $cur_version");
            break;
          }
          print(migrations[cur_version]);
          migrations[cur_version]!.forEach(batch.execute);
        }
        await batch.commit();
      }, onDowngrade: (Database db, int cur_version, int new_version) {
        print('dowgrade db from v$cur_version to v$new_version');
      }
      );
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

Future<String?> get_locale(db) async {
  List<Map<String, Object?>> res = await db.rawQuery('select locale from app_config');
  // print("saved locale: '$res'");
  if (res.isNotEmpty) {
    return res.first['locale'].toString();
  }
  return '';
}

save_locale(db, String locale) async {
  // print("saving locale '$locale'");
  await db.insert('app_config', {'locale': locale, 'appid': appid},
      conflictAlgorithm: ConflictAlgorithm.replace);
}
