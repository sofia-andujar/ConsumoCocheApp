import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/refuel.dart';
import '../widgets/consumption_chart.dart';

class ConsumptionChartFullScreen extends StatefulWidget {
  final List<Refuel> refuels;
  const ConsumptionChartFullScreen({super.key, required this.refuels});

  @override
  State<ConsumptionChartFullScreen> createState() => _ConsumptionChartFullScreenState();
}

class _ConsumptionChartFullScreenState extends State<ConsumptionChartFullScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Initialize viewport to show last 1 year by default (if data available).
    final maxDataX = math.max(0.0, (widget.refuels.length - 1).toDouble());
    if (maxDataX <= 0) {
      _xZoom = 1.0;
      _xOffset = 0.0;
    } else {
      final now = DateTime.now();
      final oneYearAgo = now.subtract(const Duration(days: 365));
      var startIdx = widget.refuels.indexWhere((r) => !r.date.isBefore(oneYearAgo));
      if (startIdx == -1) {
        // fallback: show last 12 points if available
        if (widget.refuels.length > 12) {
          startIdx = (widget.refuels.length - 12);
        } else {
          startIdx = 0;
        }
      }

      // viewportWidth in data units
      var viewportWidth = (maxDataX - startIdx.toDouble());
      if (viewportWidth < 1.0) viewportWidth = 1.0;

      final computedZoom = maxDataX / viewportWidth;
      _xZoom = computedZoom.clamp(1.0, 3.0);
      _xOffset = startIdx.toDouble().clamp(0.0, math.max(0.0, maxDataX - viewportWidth));
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  double _xZoom = 1.0;
  double _xOffset = 0.0;
  late double _initialXZoom;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evolución consumo'),
      ),
      body: SafeArea(
        child: GestureDetector(
          onScaleStart: (details) {
            _initialXZoom = _xZoom;
          },
          onScaleUpdate: (details) {
            setState(() {
              final maxDataX = math.max(0.0, (widget.refuels.length - 1).toDouble());
              final newZoom = (_initialXZoom * details.scale).clamp(1.0, 3.0);
              final viewportWidth = maxDataX > 0 ? maxDataX / newZoom : 0.0;
              final chartWidth = MediaQuery.of(context).size.width - 32.0;
              final dxUnits = chartWidth > 0 ? details.focalPointDelta.dx / chartWidth * viewportWidth : 0.0;
              _xZoom = newZoom;
              _xOffset = (_xOffset - dxUnits).clamp(0.0, math.max(0.0, maxDataX - viewportWidth));
            });
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              final safeHeight = math.max(200.0, constraints.maxHeight - 120.0);
              final maxDataX = math.max(0.0, (widget.refuels.length - 1).toDouble());
              final viewportWidth = maxDataX > 0 ? maxDataX / _xZoom : 0.0;
              final startX = _xOffset.clamp(0.0, math.max(0.0, maxDataX - viewportWidth)).toDouble();
              final endX = (startX + viewportWidth).clamp(0.0, maxDataX).toDouble();
              return ConsumptionChart(
                refuels: widget.refuels,
                onTap: null,
                showTitle: false,
                xViewportStart: startX,
                xViewportEnd: endX,
                maxChartHeight: safeHeight,
              );
            },
          ),
        ),
      ),
    );
  }
}
