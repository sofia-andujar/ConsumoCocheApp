import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/refuel.dart';
import 'db_asset_helper.dart';

// This class manages the SQLite database

class RefuelDatabase {
  static const String _databaseName = 'repostajes.db';
  static const int _databaseVersion = 2;
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
    final dbFile = File(path);
    final flagFile = File(join(documentsDirectory.path, '.asset_db_loaded'));

    // One-time: replace old DB with pre-built asset that has comments
    if (await dbFile.exists() && !await flagFile.exists()) {
      await dbFile.delete();
    }

    if (!await dbFile.exists()) {
      await copyDbFromAssets();
      await flagFile.create(recursive: true);
    }

    _database = await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return _database!;
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
      // ONE-TIME MIGRATION: Add comment column to existing records
      // After this runs successfully once, you can remove this onUpgrade method
      final columnCheck = await db.rawQuery('PRAGMA table_info($_tableRefuels)');
      final columnNames = columnCheck.map((row) => row['name'] as String).toSet();
      
      if (!columnNames.contains('comment')) {
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
}
