import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/app_localizations.dart';
import '../models/refuel.dart';
import '../widgets/zoomable_chart.dart';

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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.consumptionEvolution),
      ),
      body: SafeArea(
        child: ZoomableChart(
          refuels: widget.refuels,
          minChartHeight: 200.0,
        ),
      ),
    );
  }
}
