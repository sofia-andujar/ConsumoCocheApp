import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/refuel.dart';
import '../providers/refuel_provider.dart';
import '../widgets/add_refuel_form.dart';
import '../widgets/consumption_chart.dart';
import 'consumption_chart_fullscreen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';
import 'package:intl/intl.dart';

final format = NumberFormat("#,##0.00", "es_ES");

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consumo Mazda 2 Sofía'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.pushNamed(context, SettingsScreen.routeName),
          ),
        ],
      ),
      body: refuelState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (refuels) {
          final average = _averageConsumption(refuels);
          final sortedRefuels = [...refuels]..sort((a, b) => a.date.compareTo(b.date));
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: InkWell(
                        onTap: () => Navigator.pushNamed(context, HistoryScreen.routeName),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Consumo medio', style: theme.textTheme.titleMedium),
                              const SizedBox(height: 8),
                              Text(
                                average > 0 ? '${format.format(average)} L/100km' : 'Añade al menos 1 repostaje',
                                style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ConsumptionChart(
                    refuels: sortedRefuels,
                    onTap: (ctx) => Navigator.push(
                      ctx,
                      MaterialPageRoute(
                        builder: (_) => ConsumptionChartFullScreen(refuels: sortedRefuels),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Añadir repostaje', style: theme.textTheme.titleLarge),
                          const SizedBox(height: 12),
                          AddRefuelForm(
                            clearOnSave: true,
                            onSaved: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Repostaje añadido correctamente')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
