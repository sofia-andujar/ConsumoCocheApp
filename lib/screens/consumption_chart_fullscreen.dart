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
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  double _xStretch = 1.0;
  double _yStretch = 1.0;
  late double _initialXStretch;
  late double _initialYStretch;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Evolución consumo'),
      ),
      body: SafeArea(
        child: GestureDetector(
          onScaleStart: (details) {
            _initialXStretch = _xStretch;
            _initialYStretch = _yStretch;
          },
          onScaleUpdate: (details) {
            setState(() {
              final horizontal = details.horizontalScale.clamp(0.5, 3.0);
              final vertical = details.verticalScale.clamp(0.5, 3.0);
              _xStretch = (_initialXStretch * horizontal).clamp(0.5, 3.0);
              _yStretch = (_initialYStretch * vertical).clamp(0.5, 3.0);
            });
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final safeHeight = math.max(200.0, constraints.maxHeight - 120.0);
                      return ConsumptionChart(
                        refuels: widget.refuels,
                        onTap: null,
                        showTitle: false,
                        enableAxisStretch: true,
                        xAxisStretch: _xStretch,
                        yAxisStretch: _yStretch,
                        maxChartHeight: safeHeight,
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(
                    'Pincha para estirar/encoger los ejes',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
