import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/refuel.dart';

class ConsumptionChart extends StatelessWidget {
  const ConsumptionChart({super.key, required this.refuels});

  final List<Refuel> refuels;

  List<double> _consumptionValues() {
    return refuels.map((fuel) => fuel.consumptionLPer100Km).toList();
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
      List<FlSpot> ao5Spots, List<FlSpot> ao12Spots) {
    final allValues = <double>[];
    allValues.addAll(consumptionSpots.map((spot) => spot.y));
    allValues.addAll(meanSpots.map((spot) => spot.y));
    allValues.addAll(ao5Spots.map((spot) => spot.y));
    allValues.addAll(ao12Spots.map((spot) => spot.y));

    final minY = allValues.isEmpty ? 0.0 : (allValues.reduce((a, b) => a < b ? a : b) - 1).clamp(0.0, double.infinity);
    final maxY = allValues.isEmpty ? 1.0 : allValues.reduce((a, b) => a > b ? a : b) + 1;

    return LineChartData(
      minX: 0,
      maxX: consumptionSpots.isEmpty ? 0 : (consumptionSpots.length - 1).toDouble(),
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
            interval: consumptionSpots.length > 4 ? (consumptionSpots.length / 4).floorToDouble().clamp(1.0, double.infinity) : 1,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= refuels.length) return const SizedBox.shrink();
              final label = _formatDate(refuels[index].date);
              return Center(child: Text(label, style: const TextStyle(fontSize: 10)));
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: true, interval: 1, reservedSize: 40),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: consumptionSpots,
          isCurved: true,
          color: Colors.blueAccent,
          barWidth: 2,
          dotData: FlDotData(show: false),
        ),
        LineChartBarData(
          spots: meanSpots,
          isCurved: true,
          color: Colors.green,
          barWidth: 2,
          dotData: FlDotData(show: false),
        ),
        LineChartBarData(
          spots: ao5Spots,
          isCurved: true,
          color: Colors.orange,
          barWidth: 2,
          dotData: FlDotData(show: false),
        ),
        LineChartBarData(
          spots: ao12Spots,
          isCurved: true,
          color: Colors.purple,
          barWidth: 2,
          dotData: FlDotData(show: false),
        ),
      ],
      lineTouchData: LineTouchData(
        getTouchedSpotIndicator: (barData, spotIndexes) => [],
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

  @override
  Widget build(BuildContext context) {
    if (refuels.isEmpty) {
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
    final ao12Values = _movingAverage(consumptionValues, 12);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Evolución consumo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            AspectRatio(
              aspectRatio: 1.7,
              child: LineChart(
                _buildChartData(
                  _spotsForValues(consumptionValues),
                  _spotsForValues(cumulativeMeanValues),
                  _spotsForValues(ao5Values),
                  _spotsForValues(ao12Values),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: const [
                _LegendDot(color: Colors.blueAccent, label: 'Consumo por entrada'),
                _LegendDot(color: Colors.green, label: 'Media acumulada'),
                _LegendDot(color: Colors.orange, label: 'AO5'),
                _LegendDot(color: Colors.purple, label: 'AO12'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
