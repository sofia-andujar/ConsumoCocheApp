import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/refuel_provider.dart';
import '../widgets/refuel_tile.dart';
import 'add_refuel_screen.dart';

// This class controls what is displayed on the history screen, which shows the list of refuels and allows editing/deleting them

class HistoryScreen extends ConsumerWidget {
  static const routeName = '/history';

  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final refuelState = ref.watch(refuelListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Historial')),

      body: refuelState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        
        data: (refuels) {
          if (refuels.isEmpty) return const Center(child: Text('No hay repostajes registrados.'));

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: refuels.length,
            itemBuilder: (context, index) {
              final item = refuels[index];
              return RefuelTile(
                refuel: item,
                onDelete: item.id != null
                    ? () => ref.read(refuelListProvider.notifier).deleteRefuel(item.id!)
                    : () {},
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddRefuelScreen(refuel: item)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
