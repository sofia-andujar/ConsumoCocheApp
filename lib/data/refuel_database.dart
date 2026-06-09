import 'package:flutter/foundation.dart';
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

  Future<int> importFromCsv(String csvContent, {bool clearExisting = false}) async {
    final db = await database;

    if (clearExisting) {
      await db.delete(_tableRefuels);
    }

    final lines = csvContent.split('\n');
    if (lines.length < 2) return 0;

    var count = 0;
    final batch = db.batch();

    for (var i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final columns = _parseCsvLine(line);
      if (columns.length < 4) continue;

      final date = DateTime.tryParse(columns[0].trim());
      final km = double.tryParse(columns[1].trim());
      final liters = double.tryParse(columns[2].trim());
      final comment = columns.length > 4 ? columns[4].trim() : '';

      if (date == null || km == null || liters == null) continue;
      if (km <= 0 || liters <= 0) continue;

      batch.insert(_tableRefuels, {
        'date': date.toIso8601String(),
        'kilometers': km,
        'liters': liters,
        'comment': comment,
      });
      count++;
    }

    await batch.commit(noResult: true);
    return count;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    var current = StringBuffer();
    var inQuotes = false;

    for (var i = 0; i < line.length; i++) {
      final char = line[i];
      if (char == '"') {
        if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
          current.write('"');
          i++;
        } else {
          inQuotes = !inQuotes;
        }
      } else if (char == ',' && !inQuotes) {
        result.add(current.toString());
        current = StringBuffer();
      } else {
        current.write(char);
      }
    }
    result.add(current.toString());
    return result;
  }
}