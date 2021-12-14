import 'dart:developer';

import 'package:sqflite/sqflite.dart';

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

class DBInstance {
	static const appid = 1;
	static const db_name = 'unicon_db.db';
	static const db_version = 2;

	static bool exist = false;

  Database? _db;

	DBInstance() {
		if (exist) {
			print("ERROR database already instanciated");
			// throw(Exception("database initialized twice"));
		}
		exist = true;
	}

	get db async {
		await _dbi();
		return _db;
	}

	_dbi() async {
		if (_db == null)
			await _init_database();
	}

	/// Read date of the most recent article in local database,
	/// if any
	Future<DateTime?> get_last_sync_date() async {
		await _dbi();
		var sql = 'select date from article order by date desc limit 1';
		final result = await _db!.rawQuery(sql);
		if (result.isEmpty) return null;
		var first = result.first;
		dynamic date = first.isEmpty ? null : first['date'];
		return (date != null)
			? DateTime.fromMillisecondsSinceEpoch(date)
			: null;
	}

	/// Read the saved locale
	Future<String?> get_locale() async {
		await _dbi();
		List<Map<String, Object?>> res = await _db!.rawQuery('select locale from app_config');
		log("saved locale: '$res'");
		return res.isEmpty ? '' : res.first['locale'].toString();
	}

	/// Save the locale to database
	save_locale(String locale) async {
		log("saving locale '$locale'");
    await _dbi();
		_db!.insert('app_config', {'locale': locale, 'appid': appid},
				conflictAlgorithm: ConflictAlgorithm.replace);
	}

  /// Called on database file creation
  _onCreate(Database db, int version) async {
    log('create db v$version');
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

  /// Called when updating database
  _onUpgrade(Database db, int cur_version, int new_version) async {
    log('upgrade db from v$cur_version to v$new_version');
    var batch = db.batch();
    log('will execute: ');
    while (++cur_version <= new_version) {
      if (!migrations.containsKey(cur_version)) {
        log("BAD MIGRATION VERSION NUMBER: $cur_version");
        break;
      }
      log('${migrations[cur_version]}');
      migrations[cur_version]!.forEach(batch.execute);
    }
    await batch.commit();
  }

	/// Open connection to database and register
	/// callbacks for db creation/migration/configuration
	_init_database() async {
		_db = await openDatabase(db_name, version: db_version,
				onCreate: _onCreate,
				onUpgrade: _onUpgrade,
				onConfigure: (Database db) async {
					await db.execute("pragma foreign_keys = ON");
				},
				onDowngrade: (Database db, int cur_version, int new_version) {
          log('dowgrade db from v$cur_version to v$new_version');
				}
			);
    return _db;
	}
}
