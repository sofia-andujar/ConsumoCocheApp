import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/refuel.dart';
import '../providers/refuel_provider.dart';
import '../widgets/add_refuel_form.dart';
import 'history_screen.dart';
import 'package:intl/intl.dart';

final format = NumberFormat("#,##0.00", "es_ES");

// This class controls what is displayed on the home screen
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('CONSUMO MAZDA 2 SOFIA'),
      ),
      body: refuelState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
        data: (refuels) {
          final average = _averageConsumption(refuels);
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Consumo medio', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 8),
                            Text(
                              average > 0 ? '${format.format(average)} L/100km' : 'Añade al menos 1 repostaje',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
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
                          const Text('Añadir repostaje', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
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
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pushNamed(context, HistoryScreen.routeName),
                      icon: const Icon(Icons.history),
                      label: const Text('Ver historial'),
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
