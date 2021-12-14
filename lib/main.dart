import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

import 'app.dart';
import 'tools/db.dart' as db;

late final Database database_instance;

/// Launching of the programme.
main() async {
  WidgetsFlutterBinding.ensureInitialized();
  database_instance = await db.init_database();
  runApp(UniconApp(db: database_instance));
}

