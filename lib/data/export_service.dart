import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/refuel.dart';

class ExportService {
  static String generateCsvContent(List<Refuel> refuels, {String locale = 'es'}) {
    final buffer = StringBuffer();
    buffer.writeln('date,kilometers,liters,consumption,comment');

    final sorted = [...refuels]..sort((a, b) => a.date.compareTo(b.date));
    final dateFormat = DateFormat('yyyy-MM-dd', locale);

    for (final refuel in sorted) {
      final date = dateFormat.format(refuel.date);
      final km = refuel.kilometers.toStringAsFixed(1);
      final l = refuel.liters.toStringAsFixed(2);
      final consumption = refuel.consumptionLPer100Km.toStringAsFixed(2);
      final comment = refuel.comment.contains(',')
          ? '"${refuel.comment.replaceAll('"', '""')}"'
          : refuel.comment;
      buffer.writeln('$date,$km,$l,$consumption,$comment');
    }

    return buffer.toString();
  }

  static Future<String> exportToCsv(List<Refuel> refuels, {String locale = 'es'}) async {
    final content = generateCsvContent(refuels, locale: locale);

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/consumo_mazda_$timestamp.csv');
    await file.writeAsString(content);
    return file.path;
  }

  static Future<void> exportToCsvPath(List<Refuel> refuels, String path, {String locale = 'es'}) async {
    final content = generateCsvContent(refuels, locale: locale);
    await File(path).writeAsString(content);
  }
}
