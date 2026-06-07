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
    this.xViewportStart,
    this.xViewportEnd,
    this.maxChartHeight,
  });

  final List<Refuel> refuels;
  final void Function(BuildContext context)? onTap;
  final bool showTitle;
  final bool enableAxisStretch;
  final double xAxisStretch;
  final double yAxisStretch;
  final double? xViewportStart;
  final double? xViewportEnd;
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
      final theme = Theme.of(context);
      return Card(
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.bar_chart_rounded, size: 48, color: theme.colorScheme.primary.withAlpha(80)),
              const SizedBox(height: 12),
              const Text(
                'Añade repostajes para ver la evolución del consumo.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final theme = Theme.of(context);
    final consumptionColor = theme.colorScheme.primary;
    final meanColor = theme.colorScheme.tertiary;
    final ao5Color = theme.colorScheme.secondary;
    final isDark = theme.brightness == Brightness.dark;

    final consumptionValues = _consumptionValues();
    final cumulativeMeanValues = _cumulativeMean(consumptionValues);
    final ao5Values = _movingAverage(consumptionValues, 5);
    final visibleLines = [showConsumption, showMean, showAO5].where((item) => item).length;

    return Card(
      elevation: widget.showTitle ? 4 : 0,
      color: widget.showTitle ? null : Colors.transparent,
      child: InkWell(
        onTap: widget.onTap == null ? null : () => widget.onTap!(context),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.showTitle)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text('Evolución consumo', style: theme.textTheme.titleMedium),
                ),
              if (!widget.showTitle) const SizedBox(height: 6),
              LayoutBuilder(builder: (context, constraints) {
                final maxH = constraints.maxHeight.isFinite ? constraints.maxHeight : 400.0;
                final preferredH = constraints.maxWidth / 1.7;
                final chartHeight = preferredH.clamp(200.0, maxH * 0.8);
                final effectiveHeight = widget.maxChartHeight != null
                    ? math.min(preferredH, widget.maxChartHeight!)
                    : chartHeight;
                final chartWidth = constraints.maxWidth;

                return SizedBox(
                  height: effectiveHeight,
                  child: LineChart(
                    _buildChartData(
                      showConsumption ? _spotsForValues(consumptionValues) : const [],
                      showMean ? _spotsForValues(cumulativeMeanValues) : const [],
                      showAO5 ? _spotsForValues(ao5Values) : const [],
                      consumptionValues,
                      cumulativeMeanValues,
                      ao5Values,
                      consumptionColor: consumptionColor,
                      meanColor: meanColor,
                      ao5Color: ao5Color,
                      isDark: isDark,
                      chartWidth: chartWidth,
                    ),
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                );
              }),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _LegendToggle(
                    color: consumptionColor,
                    label: 'Consumo',
                    active: showConsumption,
                    onTap: () => toggleLine(0),
                  ),
                  _LegendToggle(
                    color: meanColor,
                    label: 'Media',
                    active: showMean,
                    onTap: () => toggleLine(1),
                  ),
                  _LegendToggle(
                    color: ao5Color,
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

  List<FlSpot> _visibleSpots(List<FlSpot> spots, double minX, double maxX) {
    return spots.where((spot) => spot.x >= minX && spot.x <= maxX).toList();
  }

  String _formatDate(DateTime date) {
    return DateFormat('MM/yy').format(date);
  }

  LineChartData _buildChartData(
    List<FlSpot> consumptionSpots,
    List<FlSpot> meanSpots,
    List<FlSpot> ao5Spots,
    List<double> rawConsumption,
    List<double> rawMean,
    List<double> rawAO5, {
    required Color consumptionColor,
    required Color meanColor,
    required Color ao5Color,
    required bool isDark,
    required double chartWidth,
  }) {
    final maxSpotCount = [consumptionSpots.length, meanSpots.length, ao5Spots.length].reduce(math.max);
    final maxDataX = maxSpotCount > 0 ? (maxSpotCount - 1).toDouble() : 0.0;

    // Default viewport: show last 12 months from today when available.
    double defaultStartX = 0.0;
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    final idx = widget.refuels.indexWhere((r) => !r.date.isBefore(oneYearAgo));
    if (idx != -1) {
      defaultStartX = idx.toDouble();
    } else {
      if (maxSpotCount > 12) {
        defaultStartX = (maxSpotCount - 12).toDouble();
      } else {
        defaultStartX = 0.0;
      }
    }

    final viewportStartX = (widget.xViewportStart ?? defaultStartX).clamp(0.0, maxDataX);
    final viewportEndX = (widget.xViewportEnd ?? maxDataX).clamp(0.0, maxDataX);
    final visibleConsumption = _visibleSpots(consumptionSpots, viewportStartX, viewportEndX);
    final visibleMean = _visibleSpots(meanSpots, viewportStartX, viewportEndX);
    final visibleAo5 = _visibleSpots(ao5Spots, viewportStartX, viewportEndX);
    final visibleValues = <double>[];
    visibleValues.addAll(visibleConsumption.map((spot) => spot.y));
    visibleValues.addAll(visibleMean.map((spot) => spot.y));
    visibleValues.addAll(visibleAo5.map((spot) => spot.y));

    final rawMinY = visibleValues.isEmpty
        ? 0.0
        : visibleValues.reduce((a, b) => a < b ? a : b);
    final rawMaxY = visibleValues.isEmpty
        ? 1.0
        : visibleValues.reduce((a, b) => a > b ? a : b);
    final rawRange = math.max(0.5, rawMaxY - rawMinY);
    final padding = rawRange * 0.1;
    final minY = math.max(0.0, rawMinY - padding);
    final maxY = rawMaxY + padding;

    // Dynamic Y interval — aim for ~5 horizontal lines
    final yRange = maxY - minY;
    final roughInterval = yRange / 5;
    final exp = (math.log(roughInterval) / math.ln10).floor();
    final magnitude = math.pow(10, exp).toDouble();
    final residual = roughInterval / magnitude;
    double yInterval;
    if (residual <= 1.5) {
      yInterval = magnitude;
    } else if (residual <= 3.5) {
      yInterval = 2 * magnitude;
    } else if (residual <= 7.5) {
      yInterval = 5 * magnitude;
    } else {
      yInterval = 10 * magnitude;
    }

    // Smart X interval based on available chart width
    final visibleRange = (viewportEndX - viewportStartX).clamp(1.0, maxDataX + 1.0);
    const labelWidth = 35.0;
    final maxLabels = (chartWidth / labelWidth).floor().clamp(2, 20);
    final bottomInterval = ((visibleRange / maxLabels).ceil() as num).clamp(1.0, visibleRange).toDouble();

    final gridColor = isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(18);

    // Determine dot visibility based on data density
    final showDots = visibleConsumption.length <= 15 && visibleConsumption.isNotEmpty;
    final dotData = FlDotData(
      show: showDots,
      getDotPainter: (spot, percent, barData, index) {
        return FlDotCirclePainter(
          radius: 3,
          color: barData.color ?? consumptionColor,
          strokeWidth: 1.5,
          strokeColor: isDark ? Colors.black : Colors.white,
        );
      },
    );
    final dotDataMean = FlDotData(
      show: showDots && visibleMean.length <= 15,
      getDotPainter: (spot, percent, barData, index) {
        return FlDotCirclePainter(
          radius: 3,
          color: barData.color ?? meanColor,
          strokeWidth: 1.5,
          strokeColor: isDark ? Colors.black : Colors.white,
        );
      },
    );
    final dotDataAo5 = FlDotData(
      show: showDots && visibleAo5.length <= 15,
      getDotPainter: (spot, percent, barData, index) {
        return FlDotCirclePainter(
          radius: 3,
          color: barData.color ?? ao5Color,
          strokeWidth: 1.5,
          strokeColor: isDark ? Colors.black : Colors.white,
        );
      },
    );

    return LineChartData(
      minX: viewportStartX,
      maxX: viewportEndX,
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        horizontalInterval: yInterval,
        getDrawingHorizontalLine: (value) => FlLine(color: gridColor, strokeWidth: 1),
        drawVerticalLine: false,
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: bottomInterval,
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < viewportStartX || index > viewportEndX) return const SizedBox.shrink();
              if (index < 0 || index >= widget.refuels.length) return const SizedBox.shrink();
              final label = _formatDate(widget.refuels[index].date);
              // Rotate every other label when dense
              final isAlternate = (index % (bottomInterval * 2).ceilToDouble().toInt()).abs() % 2 == 0;
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Transform.rotate(
                  angle: isAlternate ? 0 : -0.3,
                  child: Text(label, style: const TextStyle(fontSize: 9)),
                ),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: yInterval,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
                style: TextStyle(fontSize: 10, color: isDark ? Colors.white.withAlpha(180) : Colors.black.withAlpha(180)),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: visibleConsumption,
          isCurved: true,
          color: consumptionColor,
          barWidth: 2.5,
          dotData: dotData,
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                consumptionColor.withAlpha(45),
                consumptionColor.withAlpha(5),
              ],
            ),
          ),
        ),
        LineChartBarData(
          spots: visibleMean,
          isCurved: true,
          color: meanColor,
          barWidth: 2,
          dotData: dotDataMean,
          dashArray: [6, 3],
        ),
        LineChartBarData(
          spots: visibleAo5,
          isCurved: true,
          color: ao5Color,
          barWidth: 2,
          dotData: dotDataAo5,
        ),
      ],
      lineTouchData: LineTouchData(
        getTouchedSpotIndicator: (barData, spotIndexes) {
          return spotIndexes.map((spotIndex) {
            return TouchedSpotIndicatorData(
              FlLine(color: isDark ? Colors.white38 : Colors.grey.shade500, strokeWidth: 1.7),
              FlDotData(
                show: true,
                getDotPainter: (spot, percent, bar, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: bar.color ?? consumptionColor,
                    strokeWidth: 2,
                    strokeColor: isDark ? Colors.black : Colors.white,
                  );
                },
              ),
            );
          }).toList();
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => isDark ? Colors.grey.shade800.withAlpha(230) : Colors.white.withAlpha(230),
          fitInsideVertically: true,
          fitInsideHorizontally: true,
          showOnTopOfTheChartBoxArea: false,
          getTooltipItems: (touchedSpots) {
            if (touchedSpots.isEmpty) return [];

            final index = touchedSpots.first.x.toInt();
            if (index < 0 || index >= widget.refuels.length) {
              return List.filled(touchedSpots.length, null);
            }

            final date = DateFormat('dd/MM/yyyy').format(widget.refuels[index].date);
            final labelColor = isDark ? Colors.white : Colors.black87;

            final textSpans = <TextSpan>[
              TextSpan(
                text: '$date\n',
                style: TextStyle(color: labelColor, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ];

            if (showConsumption && index < rawConsumption.length) {
              textSpans.add(TextSpan(
                text: '\u25cf ',
                style: TextStyle(color: consumptionColor, fontSize: 12, fontWeight: FontWeight.bold),
              ));
              textSpans.add(TextSpan(
                text: '${rawConsumption[index].toStringAsFixed(2)} L/100km\n',
                style: TextStyle(color: consumptionColor, fontSize: 12),
              ));
            }
            if (showMean && index < rawMean.length) {
              textSpans.add(TextSpan(
                text: '\u25cf ',
                style: TextStyle(color: meanColor, fontSize: 12, fontWeight: FontWeight.bold),
              ));
              textSpans.add(TextSpan(
                text: '${rawMean[index].toStringAsFixed(2)} L/100km\n',
                style: TextStyle(color: meanColor, fontSize: 12),
              ));
            }
            if (showAO5 && index < rawAO5.length) {
              textSpans.add(TextSpan(
                text: '\u25cf ',
                style: TextStyle(color: ao5Color, fontSize: 12, fontWeight: FontWeight.bold),
              ));
              textSpans.add(TextSpan(
                text: '${rawAO5[index].toStringAsFixed(2)} L/100km',
                style: TextStyle(color: ao5Color, fontSize: 12),
              ));
            }

            final item = LineTooltipItem(
              '',
              TextStyle(color: labelColor, fontSize: 12),
              children: textSpans,
            );

            final items = List<LineTooltipItem?>.filled(touchedSpots.length, null);
            items[0] = item;
            return items;
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
    final theme = Theme.of(context);
    final bgColor = active ? theme.colorScheme.primaryContainer.withAlpha(80) : theme.colorScheme.surfaceContainerHighest;
    final borderColor = active ? color : theme.colorScheme.outlineVariant;
    final textColor = active ? theme.colorScheme.onSurface : theme.colorScheme.onSurface.withAlpha(150);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                color: textColor,
                decoration: active ? TextDecoration.none : TextDecoration.lineThrough,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
