import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/refuel.dart';
import '../widgets/add_refuel_form.dart';

class AddRefuelScreen extends StatelessWidget {
  static const routeName = '/add';

  final Refuel? refuel;

  const AddRefuelScreen({super.key, this.refuel});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isEditing = refuel != null;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final formState = AddRefuelForm.formKeyOf(context);
        final isDirty = formState?.isDirty ?? false;
        if (!isDirty) {
          Navigator.of(context).pop();
          return;
        }
        final shouldPop = await _confirmDiscard(context, l10n);
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(isEditing ? l10n.editRefuel : l10n.addRefuel),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: AddRefuelForm(
              refuel: refuel,
              autofocus: !isEditing,
              onSaved: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmDiscard(BuildContext context, AppLocalizations l10n) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.discardChanges),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.keepEditing),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.discard),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
