import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../l10n/app_localizations.dart';
import '../models/refuel.dart';
import '../providers/refuel_provider.dart';
import '../utils/formatters.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/add_refuel_form.dart';
import '../widgets/zoomable_chart.dart';
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
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.errorPrefix(error.toString())),
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
          final average = _averageConsumption(refuels);
          final sortedRefuels = [...refuels]..sort((a, b) => a.date.compareTo(b.date));
          return _buildBody(context, theme, average, sortedRefuels, l10n, locale);
        },
      ),
    );
  }

  Widget _buildAverageCard(BuildContext context, ThemeData theme, double average, AppLocalizations l10n, String locale) {
    final format = decimalFormat(locale);
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
            child: ZoomableChart(
              refuels: sortedRefuels,
              interactive: false,
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
                SnackBarHelper.showSuccess(context, l10n.refuelAddedSuccessfully);
              },
            ),
          ],
        ),
      ),
    );
  }
}
