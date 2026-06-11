import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/refuel.dart';
import '../providers/refuel_provider.dart';
import '../utils/formatters.dart';

class AddRefuelForm extends ConsumerStatefulWidget {
  final Refuel? refuel;
  final VoidCallback? onSaved;
  final bool clearOnSave;
  final bool compact;

  const AddRefuelForm({super.key, this.refuel, this.onSaved, this.clearOnSave = false, this.compact = false});

  @override
  AddRefuelFormState createState() => AddRefuelFormState();
}

class AddRefuelFormState extends ConsumerState<AddRefuelForm> {
  final _formKey = GlobalKey<FormState>();
  final _kilometerController = TextEditingController();
  final _litersController = TextEditingController();
  final _commentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  bool get isEditing => widget.refuel != null;

  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    if (widget.refuel != null) {
      _selectedDate = widget.refuel!.date;
      _commentController.text = widget.refuel!.comment;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.refuel != null) {
      _initialized = true;
      final locale = Localizations.localeOf(context).toString();
      final r = widget.refuel!;
      _kilometerController.text = decimalFormat(locale).format(r.kilometers);
      _litersController.text = decimalFormat(locale).format(r.liters);
    }
  }

  @override
  void dispose() {
    _kilometerController.dispose();
    _litersController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _clearForm() {
    _kilometerController.clear();
    _litersController.clear();
    _commentController.clear();
    setState(() {
      _selectedDate = DateTime.now();
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final refuel = Refuel(
      id: widget.refuel?.id,
      date: _selectedDate,
      kilometers: parseDecimalInput(_kilometerController.text)!,
      comment: _commentController.text,
      liters: parseDecimalInput(_litersController.text)!,
    );

    if (isEditing) {
      await ref.read(refuelListProvider.notifier).updateRefuel(refuel);
    } else {
      await ref.read(refuelListProvider.notifier).addRefuel(refuel);
    }

    if (!mounted) return;

    if (widget.clearOnSave && !isEditing) {
      _clearForm();
    }

    widget.onSaved?.call();

    if (!isEditing && widget.onSaved == null) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.refuelAddedSuccessfully)),
      );
    }

    if (isEditing && widget.onSaved == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateText = DateFormat.yMMMd(locale).format(_selectedDate);

    if (widget.compact) {
      return Form(
        key: _formKey,
        child: Column(
          children: [
            InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(8),
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: l10n.date,
                  border: const OutlineInputBorder(),
                  suffixIcon: const Icon(Icons.calendar_month),
                ),
                child: Text(dateText),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _kilometerController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.distanceKm,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.required;
                      }
                      final n = parseDecimalInput(value);
                      if (n == null) return l10n.invalid;
                      if (n <= 0) return l10n.mustBeGreaterThanZero;
                      if (n > 5000) return l10n.unrealisticDistance;
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _litersController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: l10n.liters,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.required;
                      }
                      final n = parseDecimalInput(value);
                      if (n == null) return l10n.invalid;
                      if (n <= 0) return l10n.mustBeGreaterThanZero;
                      if (n > 200) return l10n.unrealisticLiters;
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              keyboardType: TextInputType.text,
              maxLength: 200,
              decoration: InputDecoration(
                labelText: l10n.commentOptional,
                border: const OutlineInputBorder(),
                isDense: true,
                hintText: l10n.addNote,
                counterText: '',
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _save,
                child: Text(isEditing ? l10n.update : l10n.save),
              ),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: Column(
        children: [
          ListTile(
            title: Text(l10n.date),
            subtitle: Text(dateText),
            trailing: const Icon(Icons.calendar_month),
            onTap: () => _pickDate(context),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _kilometerController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.distanceKm,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterDistance;
              }
              final n = parseDecimalInput(value);
              if (n == null) return l10n.invalidNumericValue;
              if (n <= 0) return l10n.mustBeGreaterThanZeroFull;
              if (n > 5000) return l10n.unrealisticDistance;
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _litersController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.litersRefueled,
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.enterLiters;
              }
              final n = parseDecimalInput(value);
              if (n == null) return l10n.invalidNumericValue;
              if (n <= 0) return l10n.mustBeGreaterThanZeroFull;
              if (n > 200) return l10n.unrealisticLiters;
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            keyboardType: TextInputType.text,
            maxLength: 200,
            decoration: InputDecoration(
              labelText: l10n.commentOptional,
              border: const OutlineInputBorder(),
              hintText: l10n.addNoteFull,
              counterText: '',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? l10n.update : l10n.saveRefuel),
            ),
          ),
        ],
      ),
    );
  }
}
