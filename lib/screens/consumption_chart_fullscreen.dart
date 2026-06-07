import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/refuel.dart';
import '../widgets/consumption_chart.dart';

class ConsumptionChartFullScreen extends StatefulWidget {
  final List<Refuel> refuels;
  const ConsumptionChartFullScreen({super.key, required this.refuels});

  @override
  State<ConsumptionChartFullScreen> createState() => _ConsumptionChartFullScreenState();
}

class _ConsumptionChartFullScreenState extends State<ConsumptionChartFullScreen> {
  double _xZoom = 1.0;
  double _xOffset = 0.0;
  late double _initialXZoom;
  late double _defaultZoom;
  late double _defaultOffset;

  @override
  void initState() {
    super.initState();
    _initViewport();
    _defaultZoom = _xZoom;
    _defaultOffset = _xOffset;

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
  }

  void _initViewport() {
    final maxDataX = math.max(0.0, (widget.refuels.length - 1).toDouble());
    if (maxDataX <= 0) {
      _xZoom = 1.0;
      _xOffset = 0.0;
      return;
    }
    final now = DateTime.now();
    final oneYearAgo = now.subtract(const Duration(days: 365));
    var startIdx = widget.refuels.indexWhere((r) => !r.date.isBefore(oneYearAgo));
    if (startIdx == -1) {
      startIdx = widget.refuels.length > 12 ? widget.refuels.length - 12 : 0;
    }
    var viewportWidth = (maxDataX - startIdx.toDouble());
    if (viewportWidth < 1.0) viewportWidth = 1.0;
    final computedZoom = maxDataX / viewportWidth;
    _xZoom = computedZoom.clamp(1.0, 3.0);
    _xOffset = startIdx.toDouble().clamp(0.0, math.max(0.0, maxDataX - viewportWidth));
  }

  void _resetViewport() {
    setState(() {
      _xZoom = _defaultZoom;
      _xOffset = _defaultOffset;
    });
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.consumptionEvolution),
      ),
      body: SafeArea(
        child: GestureDetector(
          onDoubleTap: _resetViewport,
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
          child: Stack(
            children: [
              LayoutBuilder(
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
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withAlpha(200),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_xZoom.toStringAsFixed(1)}x',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                  ),
                ),
              ),
              if (_xZoom != _defaultZoom || _xOffset != _defaultOffset)
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: FilledButton.tonalIcon(
                      onPressed: _resetViewport,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n.resetZoom),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
