import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/refuel.dart';


// This widget represents a single refuel entry in the list on the home screen.
// It displays the date, kilometers, and liters of a refuel, and includes a delete button to remove the entry.

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
    final dateText = DateFormat.yMMMd().format(refuel.date);
    final format = NumberFormat("#,##0.00", "es_ES");


    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Left: date (top) and consumption (below)
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

                // Center: kilometers and liters
                Expanded (
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.ideographic,
                  children: [
                    Text('${format.format(refuel.kilometers)} km'),
                    Text('${format.format(refuel.liters)} L'),
                  ],
                  )
                ),
                
                // Right: action icons (edit, delete)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: Theme.of(context).colorScheme.error,
                  tooltip: 'Eliminar repostaje',
                  onPressed: onDelete,
                ),

                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Editar repostaje',
                  onPressed: onEdit,
                ),
              ],
            ),
            // Comment section (shown only if not empty)
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
