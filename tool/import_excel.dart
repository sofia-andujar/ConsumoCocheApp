import 'dart:io';

import 'package:excel/excel.dart';
import 'package:sqlite3/sqlite3.dart';

const _expectedColumns = ['date', 'kilometers', 'liters','comments'];

void main(List<String> args) {
  if (args.isEmpty || args.contains('-h') || args.contains('--help')) {
    _printUsage();
    exit(0);
  }

  final inputPath = args[0];
  final outputPath = args.length > 1 && !args[1].startsWith('-') ? args[1] : 'repostajes.db';
  final force = args.contains('--force');

  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Error: Excel file not found: $inputPath');
    exit(1);
  }

  if (File(outputPath).existsSync() && !force) {
    stderr.writeln('Error: Output file already exists: $outputPath');
    stderr.writeln('Use --force to overwrite.');
    exit(1);
  }

  final bytes = inputFile.readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  if (excel.tables.isEmpty) {
    stderr.writeln('Error: No worksheet tables found in Excel file.');
    exit(1);
  }

  final sheet = excel.tables.values.first;
  if (sheet.maxRows < 2) {
    stderr.writeln('Error: The worksheet must contain a header row and at least one data row.');
    exit(1);
  }

  final headers = sheet.row(0).map((cell) => _normalize(cell?.value?.toString())).toList();
  final columnIndexes = <String, int>{};
  for (var i = 0; i < headers.length; i++) {
    if (_expectedColumns.contains(headers[i])) {
      columnIndexes[headers[i]] = i;
    }
  }

  if (!_expectedColumns.every(columnIndexes.containsKey)) {
    stderr.writeln('Error: Excel header row must contain these columns: ${_expectedColumns.join(', ')}');
    stderr.writeln('Found headers: ${headers.join(', ')}');
    exit(1);
  }

  final dbFile = File(outputPath);
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }

  final db = sqlite3.open(outputPath);
  try {
    db.execute('''
      CREATE TABLE IF NOT EXISTS refuels(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        kilometers REAL NOT NULL,
        liters REAL NOT NULL,
        comments TEXT
      )
    ''');

    final insertStmt = db.prepare('INSERT INTO refuels(date, kilometers, liters, comments) VALUES (?, ?, ?, ?)');
    var imported = 0;

    for (var rowIndex = 1; rowIndex < sheet.maxRows; rowIndex++) {
      final row = sheet.row(rowIndex);
      if (row.every((cell) => cell?.value == null || cell?.value.toString().trim().isEmpty == true)) {
        continue;
      }


      // print('Processing row ${rowIndex + 1}...');

      final dateValue = row[columnIndexes['date']!]?.value;
      final kmValue = row[columnIndexes['kilometers']!]?.value;
      final litersValue = row[columnIndexes['liters']!]?.value;
      final commentsValue = row[columnIndexes['comments']!]?.value;
      final date = _parseDate(dateValue);
      final kilometers = _parseDouble(kmValue);
      final liters = _parseDouble(litersValue);

      insertStmt.execute([date.toIso8601String(), kilometers, liters, commentsValue?.toString()]);
      imported++;
    }

    insertStmt.dispose();
    stdout.writeln('Imported $imported rows into $outputPath');
    stdout.writeln('You can now copy this database file into your app data folder for the app to use it.');
  } finally {
    db.dispose();
  }
}

String _normalize(String? text) {
  return text?.trim().toLowerCase() ?? '';
}

DateTime _parseDate(dynamic value) {
  if (value == null) {
    throw const FormatException('Date value is missing.');
  }
  if (value is DateTime) {
    return value;
  }

  final raw = value.toString().trim();
  final parsed = DateTime.tryParse(raw);
  if (parsed != null) {
    return parsed;
  }

  final slashMatch = RegExp(r'^(\d{1,2})[\/\-.](\d{1,2})[\/\-.](\d{2,4})(?:\s+(\d{1,2}):(\d{2})(?::(\d{2}))?)?$').firstMatch(raw);
  if (slashMatch != null) {
    final day = int.parse(slashMatch.group(1)!);
    final month = int.parse(slashMatch.group(2)!);
    var year = int.parse(slashMatch.group(3)!);
    if (year < 100) {
      year += year < 50 ? 2000 : 1900;
    }

    final hour = slashMatch.group(4) != null ? int.parse(slashMatch.group(4)!) : 0;
    final minute = slashMatch.group(5) != null ? int.parse(slashMatch.group(5)!) : 0;
    final second = slashMatch.group(6) != null ? int.parse(slashMatch.group(6)!) : 0;
    return DateTime(year, month, day, hour, minute, second);
  }

  throw FormatException('Unable to parse date: "$raw". Use ISO format or DD/MM/YYYY.');
}

double _parseDouble(dynamic value) {
  if (value == null) {
    throw const FormatException('Numeric value is missing.');
  }
  if (value is num) {
    return value.toDouble();
  }

  var raw = value.toString().trim();
  raw = raw.replaceAll(RegExp(r'[\s\u00A0]'), '');
  if (raw.contains(',') && raw.contains('.')) {
    raw = raw.replaceAll('.', '');
  }
  raw = raw.replaceAll(',', '.');
  return double.parse(raw);
}

void _printUsage() {
  stdout.writeln('Usage: dart run tool/import_excel.dart <input.xlsx> [output.db] [--force]');
  stdout.writeln('  <input.xlsx>   Excel file with columns: date, kilometers, liters');
  stdout.writeln('  [output.db]    Optional SQLite output file name (default: repostajes.db)');
  stdout.writeln('  --force        Overwrite the output file if it already exists');
}
