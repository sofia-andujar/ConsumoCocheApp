import 'dart:math' as math;

import '../models/refuel.dart';

class ChartViewport {
  final double zoom;
  final double offset;

  const ChartViewport({required this.zoom, required this.offset});

  static ChartViewport calculateDefault(List<Refuel> refuels) {
    final maxDataX = math.max(0.0, (refuels.length - 1).toDouble());
    if (maxDataX <= 0) {
      return const ChartViewport(zoom: 1.0, offset: 0.0);
    }
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    var startIdx = refuels.indexWhere((r) => !r.date.isBefore(oneYearAgo));
    if (startIdx == -1) {
      startIdx = refuels.length > 12 ? refuels.length - 12 : 0;
    }
    var viewportWidth = maxDataX - startIdx.toDouble();
    if (viewportWidth < 1.0) viewportWidth = 1.0;
    final computedZoom = maxDataX / viewportWidth;
    final zoom = computedZoom.clamp(1.0, 3.0).toDouble();
    final offset = startIdx.toDouble().clamp(0.0, math.max(0.0, maxDataX - viewportWidth)).toDouble();
    return ChartViewport(zoom: zoom, offset: offset);
  }
}
