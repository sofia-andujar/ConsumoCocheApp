import 'package:flutter_test/flutter_test.dart';
import 'package:tankup/models/refuel.dart';

void main() {
  group('Refuel', () {
    test('toMap and fromMap roundtrip', () {
      final refuel = Refuel(
        id: 42,
        date: DateTime(2024, 6, 15),
        kilometers: 450.5,
        liters: 35.2,
        comment: 'Test comment',
      );
      final map = refuel.toMap();
      final restored = Refuel.fromMap(map);

      expect(restored.id, refuel.id);
      expect(restored.date, refuel.date);
      expect(restored.kilometers, refuel.kilometers);
      expect(restored.liters, refuel.liters);
      expect(restored.comment, refuel.comment);
    });

    test('fromMap handles missing comment', () {
      final map = {
        'id': 1,
        'date': '2024-01-01T00:00:00.000',
        'kilometers': 100.0,
        'liters': 10.0,
      };
      final refuel = Refuel.fromMap(map);
      expect(refuel.comment, '');
    });

    test('fromMap handles legacy "comments" field', () {
      final map = {
        'id': 1,
        'date': '2024-01-01T00:00:00.000',
        'kilometers': 100.0,
        'liters': 10.0,
        'comments': 'Legacy comment',
      };
      final refuel = Refuel.fromMap(map);
      expect(refuel.comment, 'Legacy comment');
    });

    test('fromMap handles legacy "km" field', () {
      final map = {
        'id': 1,
        'date': '2024-01-01T00:00:00.000',
        'km': 200.0,
        'liters': 15.0,
      };
      final refuel = Refuel.fromMap(map);
      expect(refuel.kilometers, 200.0);
    });

    test('fromMap throws on missing kilometers', () {
      final map = {
        'id': 1,
        'date': '2024-01-01T00:00:00.000',
        'liters': 10.0,
      };
      expect(() => Refuel.fromMap(map), throwsStateError);
    });

    test('fromMap throws on missing liters', () {
      final map = {
        'id': 1,
        'date': '2024-01-01T00:00:00.000',
        'kilometers': 100.0,
      };
      expect(() => Refuel.fromMap(map), throwsStateError);
    });

    test('consumptionLPer100Km calculates correctly', () {
      final refuel = Refuel(
        date: DateTime(2024),
        kilometers: 500,
        liters: 35,
      );
      expect(refuel.consumptionLPer100Km, closeTo(7.0, 0.001));
    });

    test('consumptionLPer100Km returns 0 for zero kilometers', () {
      final refuel = Refuel(
        date: DateTime(2024),
        kilometers: 0,
        liters: 35,
      );
      expect(refuel.consumptionLPer100Km, 0.0);
    });

    test('consumptionLPer100Km returns 0 for negative kilometers', () {
      final refuel = Refuel(
        date: DateTime(2024),
        kilometers: -100,
        liters: 35,
      );
      expect(refuel.consumptionLPer100Km, 0.0);
    });

    test('litersPer100Km static method calculates correctly', () {
      expect(Refuel.litersPer100Km(liters: 35, distanceKm: 500), closeTo(7.0, 0.001));
    });

    test('litersPer100Km static method returns 0 for zero distance', () {
      expect(Refuel.litersPer100Km(liters: 35, distanceKm: 0), 0.0);
    });

    test('copyWith creates new instance with updated fields', () {
      final original = Refuel(
        id: 1,
        date: DateTime(2024),
        kilometers: 100,
        liters: 10,
        comment: 'Original',
      );
      final copy = original.copyWith(comment: 'Updated', liters: 12);

      expect(copy.id, original.id);
      expect(copy.date, original.date);
      expect(copy.kilometers, original.kilometers);
      expect(copy.liters, 12);
      expect(copy.comment, 'Updated');
    });

    test('copyWith preserves unchanged fields', () {
      final original = Refuel(
        id: 1,
        date: DateTime(2024),
        kilometers: 100,
        liters: 10,
        comment: 'Original',
      );
      final copy = original.copyWith();

      expect(copy, original);
      expect(copy == original, true);
    });

    test('equality works correctly', () {
      final a = Refuel(
        id: 1,
        date: DateTime(2024),
        kilometers: 100,
        liters: 10,
        comment: 'Test',
      );
      final b = Refuel(
        id: 1,
        date: DateTime(2024),
        kilometers: 100,
        liters: 10,
        comment: 'Test',
      );
      final c = Refuel(
        id: 2,
        date: DateTime(2024),
        kilometers: 100,
        liters: 10,
        comment: 'Test',
      );

      expect(a, equals(b));
      expect(a == c, false);
      expect(a.hashCode, b.hashCode);
    });

    test('default comment is empty string', () {
      final refuel = Refuel(
        date: DateTime(2024),
        kilometers: 100,
        liters: 10,
      );
      expect(refuel.comment, '');
    });
  });
}
