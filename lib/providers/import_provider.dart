import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/refuel_database.dart';

final importProvider = StateNotifierProvider<ImportNotifier, AsyncValue<bool>>((ref) {
  return ImportNotifier();
});

class ImportNotifier extends StateNotifier<AsyncValue<bool>> {
  ImportNotifier() : super(const AsyncValue.loading()) {
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var imported = prefs.getBool('asset_imported') ?? false;

      if (!imported) {
        final docs = await getApplicationDocumentsDirectory();
        final flagFile = File(join(docs.path, '.asset_db_loaded'));
        if (await flagFile.exists()) {
          await prefs.setBool('asset_imported', true);
          imported = true;
        }
      }

      state = AsyncValue.data(imported);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<int> importFromAssets() async {
    final count = await RefuelDatabase.instance.importFromAssets();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('asset_imported', true);
    state = const AsyncValue.data(true);
    return count;
  }
}