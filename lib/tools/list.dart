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

  fill();
  refresh();

  save_item(T item) async {
    try {
      Database dbi = await db.db;
      await dbi.insert(db_table, item.toSqlMap(),
          conflictAlgorithm: ConflictAlgorithm.fail);
      items.value.add(item);
    } catch (e) {
      log("failed to save article '$item': '$e'");
    }
  }

  save_list(List<T> item_list) async {
    Database dbi = await db.db;
    var batch = dbi.batch();
    for (var a in item_list) batch.insert(db_table, a.toSqlMap());
    try {
      batch.commit(noResult: true);
    } catch (e) {
      print("failed to insert into '$db_table' from '$item_list': '$e'");
    }
  }

  update_item(T item) async {
    Database dbi = await db.db;
    dbi.update(db_table, item.toSqlMap(),
        where: '${item.db_id_field} = ?', whereArgs: [item.id]);
  }

/*
   _get_from_db() async {
    Database dbi = await db.db;
    var raw_items = await dbi.query(db_table);

    items.value.addAll(raw_items.map(
      (i) => T.from_db(i)
    ));
    }
    */
}
