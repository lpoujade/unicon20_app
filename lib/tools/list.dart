import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart';
import 'package:unicon/data/abstract.dart';
import '../services/database.dart';

abstract class ItemList<T extends AData> extends ChangeNotifier {
  DBInstance db;
  String db_table;
  final _items = [];
  // final items = ValueNotifier<List<T>>([]);

  ItemList({required this.db, required this.db_table});

  /// Populate items list from db and from network source
  Future<void> fill();

  // Fetch new items from network source
  // Future<List<T>> refresh();

  get list => _items;
  set list(other) {
    _items.clear();
    _items.addAll(other);
    notifyListeners();
  }

  add(T item) {
    _items.add(item);
    notifyListeners();
  }

  /// Save an item to local database & to current list
  save_item(T item) async {
    try {
      await (await db.db).insert(db_table, item.toSqlMap(),
          conflictAlgorithm: ConflictAlgorithm.fail);
      add(item);
    } catch (e) {
      log("failed to save article '$item': '$e'");
    }
  }

  /// Save the current items list to database
  save_list() async {
    Batch batch = (await db.db).batch();
    for (var a in _items)
      batch.insert(db_table, a.toSqlMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    try {
      batch.commit(noResult: true);
    } catch (e) {
      print("failed to insert into '$db_table' from '$list': '$e'");
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
