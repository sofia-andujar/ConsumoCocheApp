import 'package:flutter_test/flutter_test.dart';
import 'package:tankup/models/refuel.dart';
import 'package:tankup/widgets/chart_viewport.dart';

void main() {
  group('ChartViewport', () {
    test('calculateDefault returns zoom 1.0 for empty list', () {
      final viewport = ChartViewport.calculateDefault([]);
      expect(viewport.zoom, 1.0);
      expect(viewport.offset, 0.0);
    });

    test('calculateDefault returns zoom 1.0 for single item', () {
      final refuels = [
        Refuel(date: DateTime(2024), kilometers: 100, liters: 10),
      ];
      final viewport = ChartViewport.calculateDefault(refuels);
      expect(viewport.zoom, 1.0);
      expect(viewport.offset, 0.0);
    });

    test('calculateDefault limits zoom to 3.0', () {
      final now = DateTime.now();
      final refuels = List.generate(
        100,
        (i) => Refuel(
          date: now.subtract(Duration(days: i * 30)),
          kilometers: 100,
          liters: 10,
        ),
      );
      final viewport = ChartViewport.calculateDefault(refuels);
      expect(viewport.zoom, lessThanOrEqualTo(3.0));
      expect(viewport.zoom, greaterThanOrEqualTo(1.0));
    });

    test('calculateDefault shows last 12 items when data is recent', () {
      final now = DateTime.now();
      final refuels = List.generate(
        20,
        (i) => Refuel(
          date: now.subtract(Duration(days: i * 10)),
          kilometers: 100,
          liters: 10,
        ),
      );
      final viewport = ChartViewport.calculateDefault(refuels);
      expect(viewport.offset, greaterThanOrEqualTo(0.0));
    });
  });
}
