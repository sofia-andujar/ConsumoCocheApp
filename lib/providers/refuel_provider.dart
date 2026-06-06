import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/refuel_database.dart';
import '../models/refuel.dart';

// This class manages the state of the list of refuels using Riverpod's StateNotifierProvider

final refuelListProvider = StateNotifierProvider<RefuelListNotifier, AsyncValue<List<Refuel>>>(
  (ref) => RefuelListNotifier(),
);

class RefuelListNotifier extends StateNotifier<AsyncValue<List<Refuel>>> {
  RefuelListNotifier() : super(const AsyncValue.loading()) {
    _loadRefuels();
  }

  Future<void> _loadRefuels() async {
    try {
      final items = await RefuelDatabase.instance.fetchRefuels();
      state = AsyncValue.data(items);
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> addRefuel(Refuel refuel) async {
    try {
      await RefuelDatabase.instance.insertRefuel(refuel);
      await _loadRefuels();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> updateRefuel(Refuel refuel) async {
    try {
      await RefuelDatabase.instance.updateRefuel(refuel);
      await _loadRefuels();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }

  Future<void> deleteRefuel(int id) async {
    try {
      await RefuelDatabase.instance.deleteRefuel(id);
      await _loadRefuels();
    } catch (error, stack) {
      state = AsyncValue.error(error, stack);
    }
  }
}
