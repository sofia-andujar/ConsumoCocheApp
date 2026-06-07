import 'package:flutter_test/flutter_test.dart';
import 'package:calculadora_consumo_app/widgets/chart_computations.dart';

void main() {
  group('ChartComputations', () {
    test('cumulativeMean calculates running average', () {
      final values = [5.0, 7.0, 6.0];
      final result = ChartComputations.cumulativeMean(values);
      expect(result, [5.0, 6.0, 6.0]);
    });

    test('cumulativeMean with empty list returns empty', () {
      expect(ChartComputations.cumulativeMean([]), isEmpty);
    });

    test('cumulativeMean with single value returns that value', () {
      expect(ChartComputations.cumulativeMean([3.0]), [3.0]);
    });

    test('movingAverage calculates windowed average', () {
      final values = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0];
      final result = ChartComputations.movingAverage(values, 3);
      expect(result[0], 1.0);
      expect(result[1], 1.5);
      expect(result[2], 2.0);
      expect(result[3], closeTo(3.0, 0.001));
      expect(result[4], closeTo(4.0, 0.001));
      expect(result[5], closeTo(5.0, 0.001));
    });

    test('movingAverage with window larger than data uses available items', () {
      final values = [2.0, 4.0];
      final result = ChartComputations.movingAverage(values, 5);
      expect(result[0], 2.0);
      expect(result[1], 3.0);
    });

    test('movingAverage with empty list returns empty', () {
      expect(ChartComputations.movingAverage([], 3), isEmpty);
    });
  });
}
