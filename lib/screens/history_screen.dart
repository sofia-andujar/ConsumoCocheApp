import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/refuel_provider.dart';
import '../widgets/refuel_tile.dart';
import 'add_refuel_screen.dart';

// This class controls what is displayed on the history screen, which shows the list of refuels and allows editing/deleting them

class HistoryScreen extends ConsumerStatefulWidget {
  static const routeName = '/history';

  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  bool _showFilter = false;

  Future<void> _selectStartDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now.subtract(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: _endDate ?? now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate!.add(const Duration(days: 365));
        }
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? now,
      firstDate: _startDate ?? DateTime(2000),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _clearFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final refuelState = ref.watch(refuelListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => setState(() {
              _showFilter = !_showFilter;
              if (_showFilter && _startDate == null && _endDate == null) {
                final now = DateTime.now();
                _startDate = now.subtract(const Duration(days: 365));
                _endDate = now;
              }
            }),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_showFilter)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filtrar por fecha',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectStartDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Desde',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _startDate != null
                                  ? DateFormat.yMMMd().format(_startDate!)
                                  : 'Seleccionar',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectEndDate(context),
                          child: InputDecorator(
                            decoration: const InputDecoration(
                              labelText: 'Hasta',
                              border: OutlineInputBorder(),
                            ),
                            child: Text(
                              _endDate != null
                                  ? DateFormat.yMMMd().format(_endDate!)
                                  : 'Seleccionar',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Limpiar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _showFilter = false),
                        icon: const Icon(Icons.check),
                        label: const Text('Aplicar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: refuelState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
              data: (refuels) {
                if (refuels.isEmpty) {
                  return const Center(child: Text('No hay repostajes registrados.'));
                }

                final filteredRefuels = refuels.where((refuel) {
                  if (_startDate != null && refuel.date.isBefore(_startDate!)) {
                    return false;
                  }
                  if (_endDate != null) {
                    final endOfDay = _endDate!.add(const Duration(days: 1));
                    if (refuel.date.isAfter(endOfDay)) {
                      return false;
                    }
                  }
                  return true;
                }).toList();

                if (filteredRefuels.isEmpty) {
                  return const Center(child: Text('No hay repostajes en ese rango de fechas.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: filteredRefuels.length,
                  itemBuilder: (context, index) {
                    final item = filteredRefuels[index];
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
          ),
        ],
      ),
    );
  }
}
