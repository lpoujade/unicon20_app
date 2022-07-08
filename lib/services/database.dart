import 'dart:developer';

import 'package:sqflite/sqflite.dart';

/// Initial database schema, version 1
const init_sql = [
  'create table article ( id integer unique, title text, content text, important integer default 0, date integer not null, read integer default 0, img text)',
  'create table events ( uid text unique not null, title text not null, start integer not null, end integer not null, location text not null, type text not null, description text, summary text)',
  'create table app_config ( appid integer primary key, locale text)'
];

// migrations
// key is the target version
const migrations = {
  2: [
    'create table categories (id integer primary key, slug text, name text)',
    'create table articles_categories (article references article(id), category references categories(id), unique(category, article) on conflict ignore)',
    'alter table events add column modification_date integer not null default 1',
    'alter table article add column modification_date integer default null',
    'alter table article rename to articles',
    'create table places (address text, lat real, lon real, unique(address))'
  ],
  3: [
    'create table competitions (id integer primary key unique, name text, subtitle text, updated_at integer, competitor_list_pdf text, start_list_pdf text)',
    'create table results (id integer primary key unique, name text, published_at integer, pdf text)',
    'create table competitions_results (competition references competitions(id), result references results(id), unique(competition, result) on conflict ignore)'
  ]
};

class DBInstance {
  static const appid = 1;
  static const db_name = 'unicon_db.db';
  static const db_version = 3;

  static Database? _db;

  get db async {
    await _dbi();
    return _db;
  }

  _dbi() async {
    if (_db == null) await _init_database();
  }

  close() {
    _db?.close();
  }

  /// Read date of the most recent article in local database,
  /// if any
  Future<DateTime?> get_last_sync_date() async {
    await _dbi();
    var sql =
        'select modification_date from articles order by modification_date desc limit 1';
    final result = await _db?.rawQuery(sql);
    if (result == null || result.isEmpty) return null;
    var first = result.first;
    dynamic date = first.isEmpty ? null : first['date'];
    return (date != null) ? DateTime.fromMillisecondsSinceEpoch(date) : null;
  }

  /// Read date of the most recent event in local database
  Future<DateTime?> get_last_event_sync_date() async {
    await _dbi();
    var sql =
        'select modification_date from events order by modification_date desc limit 1';
    final result = await _db?.rawQuery(sql);
    if (result == null || result.isEmpty) return null;
    var first = result.first;
    dynamic date = first.isEmpty ? null : first['modification_date'];
    return (date != null) ? DateTime.fromMillisecondsSinceEpoch(date) : null;
  }

  Future<List<double>?> get_loc(var addr) async {
    await _dbi();
    var sql = 'select lat, lon from places where address = ?';
    final result = await _db?.rawQuery(sql, [addr]);
    if (result == null || result.isEmpty) return null;
    var res = result.first;
    return [res['lat'] as double, res['lon'] as double];
  }

  insert_loc(var addr, lat, lon) async {
    await _dbi();
    return await _db
        ?.insert('places', {'address': addr, 'lat': lat, 'lon': lon});
  }

  /// Read the saved locale
  Future<String?> get_locale() async {
    await _dbi();
    var res = await _db?.rawQuery('select locale from app_config');
    if (res == null) return '';
    List<Map<String, Object?>> lang = res;
    log("saved locale: '$lang'");
    return res.isEmpty ? '' : lang.first['locale'].toString();
  }

  /// Save the locale to database
  save_locale(String locale) async {
    log("saving locale '$locale'");
    await _dbi();
    _db?.insert('app_config', {'locale': locale, 'appid': appid},
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Called on database file creation
  _onCreate(Database db, int version) async {
    print('create db v$version');
    var batch = db.batch();
    init_sql.forEach(batch.execute);
    migrations.forEach((i, migration_sql) {
      if (i > version) {
        log("creating db on an older version ? version: $version, migration index: $i (sql: '$migration_sql')");
        return;
      }
      migration_sql.forEach(batch.execute);
    });
    await batch.commit();
  }

  _onUpgrade(Database db, int cur_version, int new_version) async {
    print('upgrade db from v$cur_version to v$new_version');
    var batch = db.batch();
    log('will execute: ');
    while (++cur_version <= new_version) {
      if (!migrations.containsKey(cur_version)) {
        log("BAD MIGRATION VERSION NUMBER: $cur_version");
        break;
      }
      log('${migrations[cur_version]}');
      migrations[cur_version]?.forEach(batch.execute);
    }
    await batch.commit();
  }

  /// Open connection to database and register
  /// callbacks for db creation/migration/configuration
  _init_database() async {
    _db = await openDatabase(db_name,
        version: db_version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade, onConfigure: (Database db) async {
      await db.execute("pragma foreign_keys = ON");
    }, onDowngrade: (Database db, int cur_version, int new_version) {
      log('dowgrade db from v$cur_version to v$new_version');
    });
    return _db;
  }
}
