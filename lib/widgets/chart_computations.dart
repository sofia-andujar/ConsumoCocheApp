class ChartComputations {
  static List<double> cumulativeMean(List<double> values) {
    final result = <double>[];
    var sum = 0.0;
    for (var i = 0; i < values.length; i++) {
      sum += values[i];
      result.add(sum / (i + 1));
    }
    return result;
  }

  static List<double> movingAverage(List<double> values, int window) {
    final result = <double>[];
    var sum = 0.0;
    for (var i = 0; i < values.length; i++) {
      sum += values[i];
      if (i >= window) {
        sum -= values[i - window];
      }
      result.add(sum / (i + 1 < window ? i + 1 : window));
    }
    return result;
  }
}
