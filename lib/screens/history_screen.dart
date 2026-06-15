import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../providers/refuel_provider.dart';
import '../models/refuel.dart';
import '../utils/formatters.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/add_refuel_form.dart';
import '../widgets/refuel_tile.dart';

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
  String _searchQuery = '';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        SnackBarHelper.showUndo(
          context,
          l10n.deletedRecords(refuels.length),
          undoLabel: l10n.undo,
          onUndo: () async {
            await ref.read(refuelListProvider.notifier).restoreAllRefuels(refuels);
          },
        );
      }
    }
  }

  Future<void> _confirmDeleteSingle(BuildContext context, Refuel item) async {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        final date = DateFormat.yMMMd(locale).format(item.date);
        return AlertDialog(
          title: Text(l10n.deleteRefuel),
          content: Text(
            l10n.confirmDeleteRefuel(date, decimalFormat(locale).format(item.consumptionLPer100Km)),
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
        SnackBarHelper.showUndo(
          context,
          l10n.refuelDeleted,
          undoLabel: l10n.undo,
          onUndo: () {
            ref.read(refuelListProvider.notifier).addRefuel(item);
          },
        );
      }
    }
  }

  void _showEditBottomSheet(Refuel item) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.editRefuel, style: Theme.of(ctx).textTheme.titleMedium),
                const SizedBox(height: 12),
                AddRefuelForm(
                  refuel: item,
                  onSaved: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
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
      if (_searchQuery.isNotEmpty) {
        if (!refuel.comment.toLowerCase().contains(_searchQuery.toLowerCase())) {
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
            icon: const Icon(Icons.sort),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            tooltip: l10n.moreOptions,
            onSelected: (value) {
              if (value == 'deleteAll') {
                _confirmDeleteAll(context);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'deleteAll',
                child: Row(
                  children: [
                    Icon(Icons.delete_forever, color: Theme.of(context).colorScheme.error, size: 20),
                    const SizedBox(width: 12),
                    Text(l10n.deleteAll),
                  ],
                ),
              ),
            ],
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: l10n.searchComments,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
                isDense: true,
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
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
                  return _buildEmptyState(context, l10n);
                }

                final filteredRefuels = _applySortAndFilter(refuels);

                if (filteredRefuels.isEmpty) {
                  return _buildNoResultsState(context, l10n);
                }

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: Row(
                        children: [
                          Text(
                            l10n.recordCount(filteredRefuels.length),
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            l10n.swipeHint,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        itemCount: filteredRefuels.length,
                        itemBuilder: (context, index) {
                          final item = filteredRefuels[index];
                          return Dismissible(
                            key: ValueKey(item.id ?? index),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.error,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.only(right: 20),
                              child: Icon(
                                Icons.delete_outline,
                                color: Theme.of(context).colorScheme.onError,
                              ),
                            ),
                            confirmDismiss: (direction) async {
                              if (item.id == null) return false;
                              await _confirmDeleteSingle(context, item);
                              return false;
                            },
                            child: RefuelTile(
                              refuel: item,
                              onDelete: item.id != null
                                  ? () => _confirmDeleteSingle(context, item)
                                  : () {},
                              onEdit: () => _showEditBottomSheet(item),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(80),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noRefuelsRegistered,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: theme.colorScheme.onSurface.withAlpha(80),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noResults,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}
