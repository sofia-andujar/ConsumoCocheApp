import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/refuel_provider.dart';
import '../models/refuel.dart';
import '../widgets/refuel_tile.dart';
import 'add_refuel_screen.dart';

enum SortField { date, consumption, distance, liters }

enum SortDirection { ascending, descending }

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
  SortField _sortField = SortField.date;
  SortDirection _sortDirection = SortDirection.descending;

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

  void _toggleSortDirection() {
    setState(() {
      _sortDirection = _sortDirection == SortDirection.ascending
          ? SortDirection.descending
          : SortDirection.ascending;
    });
  }

  Future<void> _confirmDeleteAll(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteAll),
          content: Text(l10n.confirmDeleteAll),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (result == true) {
      final refuels = ref.read(refuelListProvider).valueOrNull ?? [];
      await ref.read(refuelListProvider.notifier).deleteAllRefuels();
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.deletedRecords(refuels.length)),
            action: SnackBarAction(
              label: l10n.undo,
              onPressed: () async {
                await ref.read(refuelListProvider.notifier).restoreAllRefuels(refuels);
              },
            ),
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteSingle(BuildContext context, Refuel item) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final date = DateFormat.yMMMd(locale).format(item.date);
        return AlertDialog(
          title: Text(l10n.deleteRefuel),
          content: Text(
            l10n.confirmDeleteRefuel(date, item.consumptionLPer100Km.toStringAsFixed(2)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );

    if (result == true) {
      await ref.read(refuelListProvider.notifier).deleteRefuel(item.id!);
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text(l10n.refuelDeleted),
            action: SnackBarAction(
              label: l10n.undo,
              onPressed: () {
                ref.read(refuelListProvider.notifier).addRefuel(item);
              },
            ),
          ),
        );
      }
    }
  }

  List<Refuel> _applySortAndFilter(List<Refuel> refuels) {
    var result = refuels.where((refuel) {
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

    result.sort((a, b) {
      int cmp;
      switch (_sortField) {
        case SortField.date:
          cmp = a.date.compareTo(b.date);
          break;
        case SortField.consumption:
          cmp = a.consumptionLPer100Km.compareTo(b.consumptionLPer100Km);
          break;
        case SortField.distance:
          cmp = a.kilometers.compareTo(b.kilometers);
          break;
        case SortField.liters:
          cmp = a.liters.compareTo(b.liters);
          break;
      }
      return _sortDirection == SortDirection.ascending ? cmp : -cmp;
    });

    return result;
  }

  String _sortFieldLabel(SortField field, AppLocalizations l10n) {
    switch (field) {
      case SortField.date:
        return l10n.sortDate;
      case SortField.consumption:
        return l10n.sortConsumption;
      case SortField.distance:
        return l10n.sortDistance;
      case SortField.liters:
        return l10n.sortLiters;
    }
  }

  @override
  Widget build(BuildContext context) {
    final refuelState = ref.watch(refuelListProvider);
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.history),
        actions: [
          PopupMenuButton<SortField>(
            icon: Icon(
              _sortDirection == SortDirection.descending
                  ? Icons.arrow_downward
                  : Icons.arrow_upward,
            ),
            tooltip: l10n.sort,
            onSelected: (field) {
              if (_sortField == field) {
                _toggleSortDirection();
              } else {
                setState(() {
                  _sortField = field;
                  _sortDirection = SortDirection.descending;
                });
              }
            },
            itemBuilder: (context) => SortField.values.map((field) {
              final isSelected = _sortField == field;
              return CheckedPopupMenuItem<SortField>(
                value: field,
                checked: isSelected,
                child: Row(
                  children: [
                    Text(_sortFieldLabel(field, l10n)),
                    if (isSelected) ...[
                      const Spacer(),
                      Icon(
                        _sortDirection == SortDirection.ascending
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 16,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
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
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.filterByDate,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectStartDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.dateFrom,
                              border: const OutlineInputBorder(),
                            ),
                            child: Text(
                              _startDate != null
                                  ? DateFormat.yMMMd(locale).format(_startDate!)
                                  : l10n.selectDate,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () => _selectEndDate(context),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: l10n.dateTo,
                              border: const OutlineInputBorder(),
                            ),
                            child: Text(
                              _endDate != null
                                  ? DateFormat.yMMMd(locale).format(_endDate!)
                                  : l10n.selectDate,
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
                        child: Text(l10n.clear),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: () => setState(() => _showFilter = false),
                        icon: const Icon(Icons.check),
                        label: Text(l10n.apply),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          Expanded(
            child: refuelState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.errorPrefix(e.toString())),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: () => ref.read(refuelListProvider.notifier).refresh(),
                      icon: const Icon(Icons.refresh),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
              data: (refuels) {
                if (refuels.isEmpty) {
                  return Center(
                    child: Text(l10n.noRefuelsRegistered),
                  );
                }

                final filteredRefuels = _applySortAndFilter(refuels);

                if (filteredRefuels.isEmpty) {
                  return Center(
                    child: Text(l10n.noRefuelsInRange),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  itemCount: filteredRefuels.length + 1,
                  itemBuilder: (context, index) {
                    if (index == filteredRefuels.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 24),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.error,
                              foregroundColor: Theme.of(context).colorScheme.onError,
                            ),
                            icon: const Icon(Icons.delete_forever),
                            label: Text(l10n.deleteAllRecords),
                            onPressed: () => _confirmDeleteAll(context),
                          ),
                        ),
                      );
                    }
                    final item = filteredRefuels[index];
                    return RefuelTile(
                      refuel: item,
                      onDelete: item.id != null
                          ? () => _confirmDeleteSingle(context, item)
                          : () {},
                      onEdit: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AddRefuelScreen(refuel: item),
                        ),
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
