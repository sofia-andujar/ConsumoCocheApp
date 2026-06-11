import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../models/refuel.dart';
import '../utils/app_logger.dart';

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
    final result = <Refuel>[];
    for (final row in rows) {
      try {
        result.add(Refuel.fromMap(row));
      } catch (e, st) {
        logError(
          e,
          st,
          tag: 'db',
          context: {'row_id': row['id'], 'row_date': row['date']},
        );
      }
    }
    return result;
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

    var content = csvContent;
    if (content.isNotEmpty && content.codeUnitAt(0) == 0xFEFF) {
      content = content.substring(1);
    }

    final rawLines = content.split(RegExp(r'\r?\n|\r'));
    logInfo('[CSV IMPORT] Total raw lines: ${rawLines.length}', tag: 'csv_import');

    final lines = rawLines
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    logInfo('[CSV IMPORT] Non-empty lines: ${lines.length}', tag: 'csv_import');
    if (lines.isNotEmpty) {
      logInfo('[CSV IMPORT] First raw line: "${rawLines.isNotEmpty ? rawLines[0] : '(empty)'}"', tag: 'csv_import');
      for (var i = 0; i < (lines.length < 5 ? lines.length : 3); i++) {
        logInfo('[CSV IMPORT]   Line $i: "${lines[i]}"', tag: 'csv_import');
      }
    }

    if (lines.isEmpty) return 0;

    final delimiter = _detectDelimiter(lines);
    logInfo('[CSV IMPORT] Detected delimiter: "$delimiter"', tag: 'csv_import');

    var startIndex = 0;
    final firstCols = _parseCsvLine(lines[0], delimiter);
    logInfo('[CSV IMPORT] First line parsed: $firstCols', tag: 'csv_import');
    if (firstCols.isNotEmpty && !_isNumeric(firstCols[0])) {
      startIndex = 1;
      logInfo('[CSV IMPORT] First line is header, skipping to index 1', tag: 'csv_import');
    }

    var count = 0;
    final batch = db.batch();
    var skippedCols = 0;
    var skippedDate = 0;
    var skippedKm = 0;
    var skippedLiters = 0;

    for (var i = startIndex; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      final columns = _parseCsvLine(line, delimiter);
      if (columns.length < 4) {
        skippedCols++;
        continue;
      }

      var dateStr = columns[0].trim();
      final kmRaw = columns[1].trim();
      final litersRaw = columns[2].trim();
      final comment = columns.length > 4 ? columns[4].trim() : '';

      final date = DateTime.tryParse(dateStr) ?? _tryParseAltDate(dateStr);
      final km = _parseNumber(kmRaw);
      final liters = _parseNumber(litersRaw);

      if (date == null) { skippedDate++; continue; }
      if (km == null) { skippedKm++; continue; }
      if (liters == null) { skippedLiters++; continue; }
      if (km <= 0 || liters <= 0) continue;

      batch.insert(_tableRefuels, {
        'date': date.toIso8601String(),
        'kilometers': km,
        'liters': liters,
        'comment': comment,
      });
      count++;
    }

    logInfo('[CSV IMPORT] Rows imported: $count', tag: 'csv_import');
    logInfo('[CSV IMPORT] Skipped (columns<4): $skippedCols, (date): $skippedDate, (km): $skippedKm, (liters): $skippedLiters', tag: 'csv_import');

    await batch.commit(noResult: true);

    if (count == 0 && lines.length > startIndex) {
      final sample = lines[startIndex];
      final cols = _parseCsvLine(sample, delimiter);
      logError(
        FormatException(
          'No se importaron filas. '
          'Líneas: ${lines.length}, '
          'delim: "$delimiter", '
          '1ª línea: "$sample" -> $cols',
        ),
        StackTrace.current,
        tag: 'csv_import',
      );
      throw FormatException(
        'No se importaron filas. '
        'Líneas: ${lines.length}, '
        'delim: "$delimiter", '
        '1ª línea: "$sample" -> $cols',
      );
    }

    return count;
  }

  String _detectDelimiter(List<String> lines) {
    for (final line in lines) {
      var semicolons = 0;
      var commas = 0;
      for (var i = 0; i < line.length; i++) {
        final c = line[i];
        if (c == ';') semicolons++;
        if (c == ',') commas++;
      }
      if (semicolons > commas && semicolons > 0) return ';';
      if (commas >= semicolons && commas > 0) return ',';
    }
    return ',';
  }

  DateTime? _tryParseAltDate(String s) {
    final match = RegExp(r'^(\d{1,2})[./](\d{1,2})[./](\d{4})$').firstMatch(s.trim());
    if (match == null) return null;
    final year = int.parse(match.group(3)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(1)!);
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    if (year < 1990 || year > DateTime.now().year + 1) return null;
    return DateTime(year, month, day);
  }

  double? _parseNumber(String raw) {
    var s = raw.trim().replaceAll(' ', '');
    final hasDot = s.contains('.');
    final hasComma = s.contains(',');
    if (hasComma && hasDot) {
      s = s.replaceFirst(',', '');
    } else if (hasComma) {
      s = s.replaceAll(',', '.');
    }
    return double.tryParse(s);
  }

  bool _isNumeric(String s) {
    return double.tryParse(s.replaceAll(',', '.')) != null;
  }

  List<String> _parseCsvLine(String line, String delimiter) {
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
      } else if (char == delimiter && !inQuotes) {
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