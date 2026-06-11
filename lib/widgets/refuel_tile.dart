import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/refuel.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class RefuelTile extends StatelessWidget {
  final Refuel refuel;
  final VoidCallback onDelete;
  final VoidCallback? onEdit;

  const RefuelTile({
    super.key,
    required this.refuel,
    required this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateText = locale.startsWith('ca')
        ? DateFormat('d MMMM y', locale).format(refuel.date)
        : DateFormat.yMMMd(locale).format(refuel.date);
    final format = decimalFormat(locale);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateText, style: theme.textTheme.titleSmall, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: AppTheme.spaceSm),
                      Text(
                        '${format.format(refuel.consumptionLPer100Km)} L/100km',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${format.format(refuel.kilometers)} km', style: theme.textTheme.bodyMedium),
                    Text('${format.format(refuel.liters)} L', style: theme.textTheme.bodyMedium),
                  ],
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Semantics(
                  label: l10n.editRefuelTooltip,
                  child: IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    tooltip: l10n.editRefuelTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: onEdit,
                  ),
                ),
                Semantics(
                  label: l10n.deleteRefuelTooltip,
                  child: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: theme.colorScheme.error,
                    tooltip: l10n.deleteRefuelTooltip,
                    visualDensity: VisualDensity.compact,
                    onPressed: onDelete,
                  ),
                ),
              ],
            ),
            if (refuel.comment.isNotEmpty) ...[
              const SizedBox(height: AppTheme.spaceMd),
              Text(
                refuel.comment,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
