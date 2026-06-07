import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../models/refuel.dart';

class ExportService {
  static Future<String> exportToCsv(List<Refuel> refuels, {String locale = 'es'}) async {
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

    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${directory.path}/consumo_mazda_$timestamp.csv');
    await file.writeAsString(buffer.toString());
    return file.path;
  }
}
