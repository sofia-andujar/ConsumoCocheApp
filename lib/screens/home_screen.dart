import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/refuel.dart';
import '../providers/refuel_provider.dart';
import '../widgets/add_refuel_form.dart';
import '../widgets/consumption_chart.dart';
import 'consumption_chart_fullscreen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerWidget {
  static const routeName = '/';

  const HomeScreen({super.key});

  double _averageConsumption(List<Refuel> refuels) {
    final totalDistance = refuels.fold<double>(0, (sum, item) => sum + item.kilometers);
    final totalLiters = refuels.fold<double>(0, (sum, item) => sum + item.liters);
    if (totalDistance <= 0) return 0.0;
    return (totalLiters / totalDistance) * 100;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refuelState = ref.watch(refuelListProvider);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
          ),
        ],
      ),
      body: refuelState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(l10n.errorPrefix(error.toString()))),
        data: (refuels) {
          final average = _averageConsumption(refuels);
          final sortedRefuels = [...refuels]..sort((a, b) => a.date.compareTo(b.date));
          return _buildBody(context, theme, average, sortedRefuels, l10n, locale);
        },
      ),
    );
  }

  Widget _buildAverageCard(BuildContext context, ThemeData theme, double average, AppLocalizations l10n, String locale) {
    final format = NumberFormat("#,##0.00", locale);
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => Navigator.pushNamed(context, HistoryScreen.routeName),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.local_gas_station, color: theme.colorScheme.primary, size: 28),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.averageConsumption, style: theme.textTheme.labelLarge),
                  Text(
                    average > 0 ? '${format.format(average)} L/100km' : l10n.addAtLeastOneRefuel,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, double average, List<Refuel> sortedRefuels, AppLocalizations l10n, String locale) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, keyboardHeight + 8),
      child: Column(
        children: [
          _buildAverageCard(context, theme, average, l10n, locale),
          const SizedBox(height: 8),
          SizedBox(
            height: 280,
            child: _ZoomableChart(
              refuels: sortedRefuels,
              onTap: (ctx) => Navigator.push(
                ctx,
                MaterialPageRoute(
                  builder: (_) => ConsumptionChartFullScreen(refuels: sortedRefuels),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildFormCard(context, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildFormCard(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.addRefuel, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            AddRefuelForm(
              compact: true,
              clearOnSave: true,
              onSaved: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.refuelAddedSuccessfully)),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomableChart extends StatefulWidget {
  final List<Refuel> refuels;
  final void Function(BuildContext context)? onTap;

  const _ZoomableChart({required this.refuels, this.onTap});

  @override
  State<_ZoomableChart> createState() => _ZoomableChartState();
}

class _ZoomableChartState extends State<_ZoomableChart> {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return GestureDetector(
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
              final safeHeight = math.max(160.0, constraints.maxHeight - 100.0);
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
              top: 8,
              left: 8,
              child: FilledButton.tonalIcon(
                onPressed: _resetViewport,
                icon: const Icon(Icons.refresh, size: 16),
                label: Text(l10n.reset, style: const TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }
}
