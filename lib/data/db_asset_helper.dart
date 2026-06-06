import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Copies an optional prebuilt database from assets to the application's
/// documents directory on first run. Call this before opening the database.
Future<void> copyDbFromAssets({
  String assetPath = 'assets/repostajes.db',
  String dbFileName = 'repostajes.db',
  bool overwrite = false,
}) async {
  final docs = await getApplicationDocumentsDirectory();
  final dbPath = p.join(docs.path, dbFileName);
  final file = File(dbPath);

  if (await file.exists()) {
    if (!overwrite) {
      return;
    }
    await file.delete();
  }

  try {
    final data = await rootBundle.load(assetPath);
    final bytes = data.buffer.asUint8List();
    await file.create(recursive: true);
    await file.writeAsBytes(bytes, flush: true);
    // ignore: avoid_print
    print('Copied asset DB to $dbPath');
  } catch (e) {
    // ignore: avoid_print
    print('No bundled DB found at $assetPath or failed to copy: $e');
  }
}
