import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/refuel_database.dart';
import '../models/refuel.dart';
import '../utils/app_logger.dart';

final refuelDatabaseProvider = Provider<RefuelDatabase>((ref) {
  return RefuelDatabase.instance;
});

final refuelListProvider = StateNotifierProvider<RefuelListNotifier, AsyncValue<List<Refuel>>>(
  (ref) => RefuelListNotifier(ref.watch(refuelDatabaseProvider)),
);

class RefuelListNotifier extends StateNotifier<AsyncValue<List<Refuel>>> {
  final RefuelDatabase _database;
  int _loadCallId = 0;

  RefuelListNotifier(this._database) : super(const AsyncValue.loading()) {
    _loadRefuels();
  }

  Future<void> refresh() async {
    await _loadRefuels();
  }

  Future<void> _loadRefuels() async {
    final callId = ++_loadCallId;
    try {
      final items = await _database.fetchRefuels();
      if (callId != _loadCallId) return;
      state = AsyncValue.data(items);
    } catch (error, stack) {
      if (callId != _loadCallId) return;
      logError(error, stack, tag: 'refuel_provider');
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addRefuel(Refuel refuel) async {
    try {
      await _database.insertRefuel(refuel);
      await _loadRefuels();
    } catch (error, stack) {
      logError(error, stack, tag: 'refuel_provider');
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateRefuel(Refuel refuel) async {
    try {
      await _database.updateRefuel(refuel);
      await _loadRefuels();
    } catch (error, stack) {
      logError(error, stack, tag: 'refuel_provider');
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteRefuel(int id) async {
    try {
      await _database.deleteRefuel(id);
      await _loadRefuels();
    } catch (error, stack) {
      logError(error, stack, tag: 'refuel_provider');
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteAllRefuels() async {
    try {
      await _database.deleteAllRefuels();
      await _loadRefuels();
    } catch (error, stack) {
      logError(error, stack, tag: 'refuel_provider');
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> restoreAllRefuels(List<Refuel> refuels) async {
    try {
      for (final refuel in refuels) {
        await _database.insertRefuel(refuel);
      }
      await _loadRefuels();
    } catch (error, stack) {
      logError(error, stack, tag: 'refuel_provider');
      state = AsyncValue.error(error, stack);
    }
  }
}