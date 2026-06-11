import 'package:flutter_test/flutter_test.dart';
import 'package:tankup/models/refuel.dart';

void main() {
  group('RefuelTile', () {
    test('formats consumption correctly', () {
      final refuel = Refuel(
        id: 1,
        date: DateTime(2024, 6, 15),
        kilometers: 450.5,
        liters: 35.2,
        comment: 'Test comment',
      );
      expect(refuel.consumptionLPer100Km, closeTo(7.815, 0.01));
    });
  });
}