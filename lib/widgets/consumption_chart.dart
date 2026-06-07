import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/refuel.dart';

class ConsumptionChart extends StatefulWidget {
  const ConsumptionChart({
    super.key,
    required this.refuels,
    this.onTap,
    this.showTitle = true,
    this.enableAxisStretch = false,
    this.xAxisStretch = 1.0,
    this.yAxisStretch = 1.0,
    this.maxChartHeight,
  });

  final List<Refuel> refuels;
  final void Function(BuildContext context)? onTap;
  final bool showTitle;
  final bool enableAxisStretch;
  final double xAxisStretch;
  final double yAxisStretch;
  final double? maxChartHeight;

  @override
  State<ConsumptionChart> createState() => _ConsumptionChartState();
}

class _ConsumptionChartState extends State<ConsumptionChart> {
  bool showConsumption = true;
  bool showMean = true;
  bool showAO5 = true;

  void toggleLine(int index) {
    final activeStates = [showConsumption, showMean, showAO5];
    final visibleLines = activeStates.where((item) => item).length;
    setState(() {
      switch (index) {
        case 0:
          if (showConsumption && visibleLines == 1) return;
          showConsumption = !showConsumption;
          break;
        case 1:
          if (showMean && visibleLines == 1) return;
          showMean = !showMean;
          break;
        case 2:
          if (showAO5 && visibleLines == 1) return;
          showAO5 = !showAO5;
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.refuels.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('Añade repostajes para ver la evolución del consumo.'),
        ),
      );
    }

    final consumptionValues = _consumptionValues();
    final cumulativeMeanValues = _cumulativeMean(consumptionValues);
    final ao5Values = _movingAverage(consumptionValues, 5);
    final visibleLines = [showConsumption, showMean, showAO5].where((item) => item).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showTitle)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text('Evolución consumo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            if (!widget.showTitle) const SizedBox(height: 6),
            LayoutBuilder(builder: (context, constraints) {
              final maxH = constraints.maxHeight.isFinite ? constraints.maxHeight : 400.0;
              final preferredH = constraints.maxWidth / 1.7;
              final chartHeight = preferredH.clamp(200.0, maxH * 0.8);
              final effectiveHeight = widget.maxChartHeight != null
                  ? math.min(preferredH, widget.maxChartHeight!)
                  : chartHeight;

              return SizedBox(
                height: effectiveHeight,
                child: GestureDetector(
                  onTap: widget.onTap == null ? null : () => widget.onTap!(context),
                  child: SizedBox(
                    width: double.infinity,
                    height: effectiveHeight,
                    child: LineChart(
                      _buildChartData(
                        showConsumption ? _spotsForValues(consumptionValues) : const [],
                        showMean ? _spotsForValues(cumulativeMeanValues) : const [],
                        showAO5 ? _spotsForValues(ao5Values) : const [],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                _LegendToggle(
                  color: Colors.blueAccent,
                  label: 'Consumo',
                  active: showConsumption,
                  onTap: () => toggleLine(0),
                ),
                _LegendToggle(
                  color: Colors.green,
                  label: 'Media',
                  active: showMean,
                  onTap: () => toggleLine(1),
                ),
                _LegendToggle(
                  color: Colors.orange,
                  label: 'Ao5',
                  active: showAO5,
                  onTap: () => toggleLine(2),
                ),
              ],
            ),
            if (visibleLines == 0)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Text(
                  'No hay líneas visibles. Toca una leyenda para mostrarla.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<double> _consumptionValues() {
    return widget.refuels.map((fuel) => fuel.consumptionLPer100Km).toList();
  }

  List<double> _cumulativeMean(List<double> values) {
    final result = <double>[];
    var sum = 0.0;
    for (var i = 0; i < values.length; i++) {
      sum += values[i];
      result.add(sum / (i + 1));
    }
    return result;
  }

  List<double> _movingAverage(List<double> values, int window) {
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

  List<FlSpot> _spotsForValues(List<double> values) {
    return List<FlSpot>.generate(
      values.length,
      (index) => FlSpot(index.toDouble(), values[index]),
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat.Md().format(date);
  }

  LineChartData _buildChartData(List<FlSpot> consumptionSpots, List<FlSpot> meanSpots,
      List<FlSpot> ao5Spots) {
    final allValues = <double>[];
    allValues.addAll(consumptionSpots.map((spot) => spot.y));
    allValues.addAll(meanSpots.map((spot) => spot.y));
    allValues.addAll(ao5Spots.map((spot) => spot.y));

    final rawMinY = allValues.isEmpty ? 0.0 : allValues.reduce((a, b) => a < b ? a : b);
    final rawMaxY = allValues.isEmpty ? 1.0 : allValues.reduce((a, b) => a > b ? a : b);
    final rawCenterY = (rawMinY + rawMaxY) / 2.0;
    final rawHalfRange = math.max(0.5, (rawMaxY - rawMinY) / 2.0);
    final halfRange = rawHalfRange * widget.yAxisStretch;
    final minY = math.max(0.0, rawCenterY - halfRange);
    final maxY = rawCenterY + halfRange;
    final maxSpotCount = [consumptionSpots.length, meanSpots.length, ao5Spots.length].reduce(math.max);
    final baseMaxX = maxSpotCount > 0 ? (maxSpotCount - 1).toDouble() : 0.0;
    final maxX = widget.enableAxisStretch ? baseMaxX * widget.xAxisStretch : baseMaxX;

    return LineChartData(
      minX: 0,
      maxX: maxX,
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        horizontalInterval: 1,
        getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade300, strokeWidth: 1),
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: maxSpotCount > 4 ? (maxSpotCount / 4).floorToDouble().clamp(1.0, double.infinity) : 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= widget.refuels.length) return const SizedBox.shrink();
              final label = _formatDate(widget.refuels[index].date);
              return Center(child: Text(label, style: const TextStyle(fontSize: 10)));
            },
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 40),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: consumptionSpots,
          isCurved: true,
          color: Colors.blueAccent,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: meanSpots,
          isCurved: true,
          color: Colors.green,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
        LineChartBarData(
          spots: ao5Spots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 2,
          dotData: const FlDotData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(color: barData.color?.withValues(alpha: 153) ?? Colors.black54, strokeWidth: 2),
              const FlDotData(show: false),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                '${spot.y.toStringAsFixed(2)} L/100km',
                const TextStyle(color: Colors.white, fontSize: 12),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}

class _LegendToggle extends StatelessWidget {
  const _LegendToggle({
    required this.color,
    required this.label,
    required this.active,
    required this.onTap,
  });

  final Color color;
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.grey.shade100 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: active ? color : Colors.grey.shade400),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: active ? color : color.withValues(alpha: 90),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: active ? Colors.black : Colors.grey.shade600,
                decoration: active ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
