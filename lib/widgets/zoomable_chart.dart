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

  void _zoomOutMax() {
    setState(() {
      _xZoom = 1.0;
      _xOffset = 0.0;
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
        final rawStart = _xOffset.clamp(0.0, math.max(0.0, maxDataX - viewportWidth));
        final rawEnd = (rawStart + viewportWidth).clamp(0.0, maxDataX);
        final startX = rawStart.floorToDouble();
        final endX = rawEnd.ceilToDouble();
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
            child: Material(
              color: theme.colorScheme.surfaceContainerHighest.withAlpha(200),
              borderRadius: BorderRadius.circular(12),
              child: Tooltip(
                message: _xZoom > 1.0 ? l10n.zoomFitScreen : l10n.resetZoomTooltip,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _xZoom > 1.0 ? _zoomOutMax : _resetViewport,
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      _xZoom > 1.0 ? Icons.fit_screen : Icons.zoom_in,
                      size: 18,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return chart;
  }
}
