import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/refuel.dart';

class RefuelDatabase {
  static const String _databaseName = 'repostajes.db';
  static const int _databaseVersion = 3;
  static const String _tableRefuels = 'refuels';

  RefuelDatabase._privateConstructor();
  static final RefuelDatabase instance = RefuelDatabase._privateConstructor();

  Database? _database;

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, _databaseName);

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
  }

  @visibleForTesting
  Future<void> setDatabase(Database db) async {
    _database = db;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_tableRefuels(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        kilometers REAL NOT NULL,
        liters REAL NOT NULL,
        comment TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      final columnCheck = await db.rawQuery('PRAGMA table_info($_tableRefuels)');
      final columnNames = columnCheck.map((row) => row['name'] as String).toSet();

      if (!columnNames.contains('comment')) {
        await db.execute('''
          ALTER TABLE $_tableRefuels ADD COLUMN comment TEXT NOT NULL DEFAULT ''
        ''');
      }
    }

    if (oldVersion < 3) {
      final columnCheck = await db.rawQuery('PRAGMA table_info($_tableRefuels)');
      final columnNames = columnCheck.map((row) => row['name'] as String).toSet();

      if (columnNames.contains('comments') && columnNames.contains('comment')) {
        await db.execute('''
          UPDATE $_tableRefuels SET comment = comments WHERE comments IS NOT NULL
        ''');
      } else if (!columnNames.contains('comment')) {
        await db.execute('''
          ALTER TABLE $_tableRefuels ADD COLUMN comment TEXT NOT NULL DEFAULT ''
        ''');
      }
    }
  }

  Future<int> insertRefuel(Refuel refuel) async {
    final db = await database;
    return await db.insert(_tableRefuels, refuel.toMap());
  }

  Future<List<Refuel>> fetchRefuels() async {
    final db = await database;
    final rows = await db.query(
      _tableRefuels,
      orderBy: 'date DESC',
    );
    return rows.map((row) => Refuel.fromMap(row)).toList();
  }

  Future<int> deleteRefuel(int id) async {
    final db = await database;
    return await db.delete(
      _tableRefuels,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAllRefuels() async {
    final db = await database;
    return await db.delete(_tableRefuels);
  }

  Future<int> updateRefuel(Refuel refuel) async {
    final db = await database;
    return await db.update(
      _tableRefuels,
      refuel.toMap(),
      where: 'id = ?',
      whereArgs: [refuel.id],
    );
  }

  Future<int> importFromAssets() async {
    final byteData = await rootBundle.load('assets/repostajes.db');
    final bytes = byteData.buffer.asUint8List();

    final tempDir = await getTemporaryDirectory();
    final tempPath = join(tempDir.path, 'temp_import.db');
    final tempFile = File(tempPath);

    try {
      await tempFile.writeAsBytes(bytes, flush: true);

      final tempDb = await openDatabase(tempPath, readOnly: true);
      final rows = await tempDb.query(_tableRefuels, orderBy: 'date ASC');
      await tempDb.close();

      final db = await database;
      int count = 0;
      for (final row in rows) {
        final refuel = Refuel.fromMap(row);
        await db.insert(_tableRefuels, {
          'date': refuel.date.toIso8601String(),
          'kilometers': refuel.kilometers,
          'liters': refuel.liters,
          'comment': refuel.comment,
        });
        count++;
      }

      return count;
    } finally {
      if (await tempFile.exists()) {
        await tempFile.delete();
      }
    }
  }
}