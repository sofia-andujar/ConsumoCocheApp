import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/refuel_database.dart';
import '../models/refuel.dart';

final refuelDatabaseProvider = Provider<RefuelDatabase>((ref) {
  return RefuelDatabase.instance;
});

final refuelListProvider = StateNotifierProvider<RefuelListNotifier, AsyncValue<List<Refuel>>>(
  (ref) => RefuelListNotifier(ref.watch(refuelDatabaseProvider)),
);

class RefuelListNotifier extends StateNotifier<AsyncValue<List<Refuel>>> {
  final RefuelDatabase _database;

  RefuelListNotifier(this._database) : super(const AsyncValue.loading()) {
    _loadRefuels();
  }

  Future<void> refresh() async {
    await _loadRefuels();
  }

  Future<void> _loadRefuels() async {
    try {
      final items = await _database.fetchRefuels();
      state = AsyncValue.data(items);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addRefuel(Refuel refuel) async {
    try {
      await _database.insertRefuel(refuel);
      await _loadRefuels();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateRefuel(Refuel refuel) async {
    try {
      await _database.updateRefuel(refuel);
      await _loadRefuels();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteRefuel(int id) async {
    try {
      await _database.deleteRefuel(id);
      await _loadRefuels();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteAllRefuels() async {
    try {
      await _database.deleteAllRefuels();
      await _loadRefuels();
    } catch (error, stack) {
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
      state = AsyncValue.error(error, stack);
    }
  }
}
