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

  Color _consumptionColor(double consumption, ThemeData theme) {
    if (consumption <= 6.0) return Colors.green.shade700;
    if (consumption <= 9.0) return Colors.orange.shade700;
    return Colors.red.shade700;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateText = locale.startsWith('ca')
        ? DateFormat('d MMMM y', locale).format(refuel.date)
        : DateFormat.yMMMd(locale).format(refuel.date);
    final format = decimalFormat(locale);
    final theme = Theme.of(context);
    final consumptionColor = _consumptionColor(refuel.consumptionLPer100Km, theme);

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: AppTheme.spaceSm),
        child: InkWell(
          onLongPress: onEdit != null
              ? () {
                  final box = context.findRenderObject() as RenderBox?;
                  if (box == null) return;
                  final position = box.localToGlobal(Offset.zero);
                  showMenu(
                    context: context,
                    position: RelativeRect.fromLTRB(
                      position.dx + box.size.width,
                      position.dy,
                      position.dx + box.size.width,
                      position.dy + box.size.height,
                    ),
                    items: [
                      PopupMenuItem(
                        onTap: onEdit,
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.primary),
                            const SizedBox(width: 12),
                            Text(l10n.editRefuel),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: onDelete,
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                            const SizedBox(width: 12),
                            Text(l10n.delete, style: TextStyle(color: theme.colorScheme.error)),
                          ],
                        ),
                      ),
                    ],
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(12),
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
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: consumptionColor,
                              fontWeight: FontWeight.bold,
                            ),
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
                    const SizedBox(width: 4),
                    Semantics(
                      label: l10n.moreOptions,
                      child: IconButton(
                        icon: const Icon(Icons.more_vert, size: 20),
                        tooltip: l10n.moreOptions,
                        visualDensity: VisualDensity.compact,
                        onPressed: onEdit != null
                            ? () {
                                final box = context.findRenderObject() as RenderBox?;
                                if (box == null) return;
                                final position = box.localToGlobal(Offset.zero);
                                showMenu(
                                  context: context,
                                  position: RelativeRect.fromLTRB(
                                    position.dx + box.size.width,
                                    position.dy,
                                    position.dx + box.size.width,
                                    position.dy + box.size.height,
                                  ),
                                  items: [
                                    PopupMenuItem(
                                      onTap: onEdit,
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit_outlined, size: 20, color: theme.colorScheme.primary),
                                          const SizedBox(width: 12),
                                          Text(l10n.editRefuel),
                                        ],
                                      ),
                                    ),
                                    PopupMenuItem(
                                      onTap: onDelete,
                                      child: Row(
                                        children: [
                                          Icon(Icons.delete_outline, size: 20, color: theme.colorScheme.error),
                                          const SizedBox(width: 12),
                                          Text(l10n.delete, style: TextStyle(color: theme.colorScheme.error)),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
                if (refuel.comment.isNotEmpty) ...[
                  const SizedBox(height: AppTheme.spaceMd),
                  Text(
                    refuel.comment,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withAlpha(160),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
