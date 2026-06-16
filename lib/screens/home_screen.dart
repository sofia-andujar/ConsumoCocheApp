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
        loading: () => const _SkeletonLoading(),
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
          if (refuels.isEmpty) {
            return _buildEmptyState(context, theme, l10n);
          }
          final average = _averageConsumption(refuels);
          final sortedRefuels = [...refuels]..sort((a, b) => a.date.compareTo(b.date));
          return _buildBody(context, theme, average, sortedRefuels, l10n, locale, ref);
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 48),
        Icon(
          Icons.local_gas_station_outlined,
          size: 80,
          color: theme.colorScheme.primary.withAlpha(100),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.emptyStateTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(180),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.emptyStateSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withAlpha(120),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        const _EmptyFormCard(),
      ],
    );
  }

  Widget _buildBody(BuildContext context, ThemeData theme, double average, List<Refuel> sortedRefuels, AppLocalizations l10n, String locale, WidgetRef ref) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          _buildAverageCard(context, theme, average, l10n, locale, sortedRefuels),
          const SizedBox(height: 8),
          _buildSummaryRow(context, theme, sortedRefuels, l10n, locale),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final chartHeight = (constraints.maxWidth * 0.65).clamp(240.0, 340.0);
              return SizedBox(
                height: chartHeight,
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
              );
            },
          ),
          const SizedBox(height: 8),
          _buildFormCard(context, theme, l10n),
        ],
      ),
    );
  }

  Widget _buildAverageCard(BuildContext context, ThemeData theme, double average, AppLocalizations l10n, String locale, List<Refuel> refuels) {
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.averageConsumption, style: theme.textTheme.labelLarge),
                    Text(
                      average > 0 ? '${format.format(average)} L/100km' : l10n.addAtLeastOneRefuel,
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: theme.colorScheme.onSurface.withAlpha(100)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, ThemeData theme, List<Refuel> refuels, AppLocalizations l10n, String locale) {
    final format = decimalFormat(locale);
    final totalKm = refuels.fold<double>(0, (s, r) => s + r.kilometers);
    final totalL = refuels.fold<double>(0, (s, r) => s + r.liters);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _SummaryItem(
              icon: Icons.straighten,
              label: l10n.totalKm,
              value: '${format.format(totalKm)} km',
              theme: theme,
            ),
            _SummaryDivider(theme: theme),
            _SummaryItem(
              icon: Icons.opacity,
              label: l10n.totalLiters,
              value: '${format.format(totalL)} L',
              theme: theme,
            ),
          ],
        ),
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

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final ThemeData theme;
  final Color? valueColor;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.theme,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.primary.withAlpha(180)),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: valueColor ?? theme.colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(120),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  final ThemeData theme;
  const _SummaryDivider({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      width: 1,
      color: theme.colorScheme.onSurface.withAlpha(25),
    );
  }
}

class _SkeletonLoading extends StatelessWidget {
  const _SkeletonLoading();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final skeletonColor = theme.colorScheme.onSurface.withAlpha(20);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          _SkeletonCard(
            height: 72,
            color: skeletonColor,
          ),
          const SizedBox(height: 8),
          _SkeletonCard(
            height: 60,
            color: skeletonColor,
          ),
          const SizedBox(height: 8),
          _SkeletonCard(
            height: 280,
            color: skeletonColor,
          ),
          const SizedBox(height: 8),
          _SkeletonCard(
            height: 260,
            color: skeletonColor,
          ),
        ],
      ),
    );
  }
}

class _SkeletonCard extends StatelessWidget {
  final double height;
  final Color color;

  const _SkeletonCard({required this.height, required this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}

class _EmptyFormCard extends StatelessWidget {
  const _EmptyFormCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
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
