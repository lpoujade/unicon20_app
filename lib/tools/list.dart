import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unicon/data/abstract.dart';
import '../services/database.dart';

abstract class ItemList<T extends AData> {
  DBInstance db;
  String db_table;
  final items = ValueNotifier<List<T>>([]);

  ItemList({required this.db, required this.db_table});

  /// Populate items list from db and from network source
  Future<void> fill();

  /// Fetch new items from network source
  Future<List<T>> refresh();

  /// Save an item to local database & to current list
  save_item(T item) async {
    try {
      await (await db.db).insert(db_table, item.toSqlMap(),
          conflictAlgorithm: ConflictAlgorithm.fail);
      items.value += [item];
    } catch (e) {
      log("failed to save article '$item': '$e'");
    }
  }

  /// Save a list of item to local database & to current list
  save_list(List<T> item_list) async {
    items.value += item_list;
    var batch = (await db.db).batch();
    for (var a in item_list) batch.insert(db_table, a.toSqlMap());
    try {
      batch.commit(noResult: true);
    } catch (e) {
      print("failed to insert into '$db_table' from '$item_list': '$e'");
    }
  }

  /// Update an item in local database
  update_item(T item) async {
    (await db.db).update(db_table, item.toSqlMap(),
        where: '${item.db_id_field} = ?', whereArgs: [item.id]);
  }

  /// Read items from local database
  Future<List<Map<String, Object?>>> get_from_db() async {
    return (await db.db).query(db_table);
  }
}
