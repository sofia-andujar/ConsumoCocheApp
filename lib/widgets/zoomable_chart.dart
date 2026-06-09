import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/refuel.dart';
import 'chart_viewport.dart';
import 'consumption_chart.dart';

class ZoomableChart extends StatefulWidget {
  final List<Refuel> refuels;
  final void Function(BuildContext context)? onTap;
  final double minChartHeight;
  final bool interactive;

  const ZoomableChart({
    super.key,
    required this.refuels,
    this.onTap,
    this.minChartHeight = 160.0,
    this.interactive = true,
  });

  @override
  State<ZoomableChart> createState() => _ZoomableChartState();
}

class _ZoomableChartState extends State<ZoomableChart> {
  double _xZoom = 1.0;
  double _xOffset = 0.0;
  late double _initialXZoom;
  late ChartViewport _defaultViewport;

  @override
  void initState() {
    super.initState();
    _defaultViewport = ChartViewport.calculateDefault(widget.refuels);
    _xZoom = _defaultViewport.zoom;
    _xOffset = _defaultViewport.offset;
  }

  void _resetViewport() {
    setState(() {
      _xZoom = _defaultViewport.zoom;
      _xOffset = _defaultViewport.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    Widget chart = LayoutBuilder(
      builder: (context, constraints) {
        final safeHeight = math.max(widget.minChartHeight, constraints.maxHeight - 100.0);
        final maxDataX = math.max(0.0, (widget.refuels.length - 1).toDouble());
        final viewportWidth = maxDataX > 0 ? maxDataX / _xZoom : 0.0;
        final startX = _xOffset.clamp(0.0, math.max(0.0, maxDataX - viewportWidth)).toDouble();
        final endX = (startX + viewportWidth).clamp(0.0, maxDataX).toDouble();
        return ConsumptionChart(
          refuels: widget.refuels,
          showTitle: false,
          xViewportStart: startX,
          xViewportEnd: endX,
          maxChartHeight: safeHeight,
          onTap: widget.onTap,
        );
      },
    );

    if (widget.interactive) {
      chart = GestureDetector(
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
        child: chart,
      );
    }

    if (widget.interactive) {
      chart = Stack(
        children: [
          chart,
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
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ),
          if (_xZoom != _defaultViewport.zoom || _xOffset != _defaultViewport.offset)
            Positioned(
              top: 8,
              left: 8,
              child: FilledButton.tonalIcon(
                onPressed: _resetViewport,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(l10n.reset, style: const TextStyle(fontSize: 12)),
              ),
            ),
        ],
      );
    }

    return chart;
  }
}
