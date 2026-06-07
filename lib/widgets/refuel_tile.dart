import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/refuel.dart';
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
    final dateText = DateFormat.yMMMd(locale).format(refuel.date);
    final format = decimalFormat(locale);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(dateText, style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      Text('${format.format(refuel.consumptionLPer100Km)} L/100km', style: Theme.of(context).textTheme.titleMedium),
                    ],
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.ideographic,
                    children: [
                      Text('${format.format(refuel.kilometers)} km'),
                      Text('${format.format(refuel.liters)} L'),
                    ],
                  ),
                ),
                
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: l10n.deleteRefuelTooltip,
                  onPressed: onDelete,
                ),

                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: l10n.editRefuelTooltip,
                  onPressed: onEdit,
                ),
              ],
            ),
            if (refuel.comment.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                refuel.comment,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
