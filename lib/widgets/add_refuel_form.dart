import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../l10n/app_localizations.dart';
import '../models/refuel.dart';
import '../providers/refuel_provider.dart';
import '../utils/formatters.dart';
import '../utils/snackbar_helper.dart';

class AddRefuelForm extends ConsumerStatefulWidget {
  final Refuel? refuel;
  final VoidCallback? onSaved;
  final bool clearOnSave;
  final bool compact;
  final bool autofocus;

  const AddRefuelForm({
    super.key,
    this.refuel,
    this.onSaved,
    this.clearOnSave = false,
    this.compact = false,
    this.autofocus = false,
  });

  static AddRefuelFormState? formKeyOf(BuildContext context) {
    return context.findAncestorStateOfType<AddRefuelFormState>();
  }

  @override
  AddRefuelFormState createState() => AddRefuelFormState();
}

class AddRefuelFormState extends ConsumerState<AddRefuelForm> {
  final _formKey = GlobalKey<FormState>();
  final _kilometerController = TextEditingController();
  final _litersController = TextEditingController();
  final _commentController = TextEditingController();
  final _kmFocusNode = FocusNode();
  final _litersFocusNode = FocusNode();
  final _commentFocusNode = FocusNode();
  DateTime _selectedDate = DateTime.now();

  bool get isEditing => widget.refuel != null;

  bool _initialized = false;
  bool _isDirty = false;

  bool get isDirty => _isDirty;

  @override
  void initState() {
    super.initState();
    if (widget.refuel != null) {
      _selectedDate = widget.refuel!.date;
      _commentController.text = widget.refuel!.comment;
    }
    _kilometerController.addListener(_markDirty);
    _litersController.addListener(_markDirty);
    _commentController.addListener(_markDirty);
  }

  void _markDirty() {
    if (!_isDirty) {
      setState(() => _isDirty = true);
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
    _kilometerController.removeListener(_markDirty);
    _litersController.removeListener(_markDirty);
    _commentController.removeListener(_markDirty);
    _kilometerController.dispose();
    _litersController.dispose();
    _commentController.dispose();
    _kmFocusNode.dispose();
    _litersFocusNode.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final endOfToday = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: endOfToday,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _isDirty = true;
      });
    }
  }

  void _clearForm() {
    _kilometerController.clear();
    _litersController.clear();
    _commentController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _isDirty = false;
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

    await HapticFeedback.selectionClick();

    if (!mounted) return;

    if (widget.clearOnSave && !isEditing) {
      _clearForm();
    } else {
      _isDirty = false;
    }

    widget.onSaved?.call();

    if (!isEditing && widget.onSaved == null) {
      final l10n = AppLocalizations.of(context)!;
      SnackBarHelper.showSuccess(context, l10n.refuelAddedSuccessfully);
    }

    if (isEditing && widget.onSaved == null) {
      Navigator.pop(context);
    }
  }

  String? _validateDistance(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return widget.compact ? l10n.required : l10n.enterDistance;
    }
    final n = parseDecimalInput(value);
    if (n == null) return widget.compact ? l10n.invalid : l10n.invalidNumericValue;
    if (n <= 0) return widget.compact ? l10n.mustBeGreaterThanZero : l10n.mustBeGreaterThanZeroFull;
    if (n > 5000) return l10n.unrealisticDistance;
    return null;
  }

  String? _validateLiters(String? value, AppLocalizations l10n) {
    if (value == null || value.isEmpty) {
      return widget.compact ? l10n.required : l10n.enterLiters;
    }
    final n = parseDecimalInput(value);
    if (n == null) return widget.compact ? l10n.invalid : l10n.invalidNumericValue;
    if (n <= 0) return widget.compact ? l10n.mustBeGreaterThanZero : l10n.mustBeGreaterThanZeroFull;
    if (n > 200) return l10n.unrealisticLiters;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toString();
    final dateText = DateFormat.yMMMd(locale).format(_selectedDate);

    if (widget.compact) {
      return _buildCompactForm(l10n, dateText);
    }

    return _buildFullForm(l10n, dateText);
  }

  Widget _buildCompactForm(AppLocalizations l10n, String dateText) {
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
                  focusNode: _kmFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.distanceKm,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) => _validateDistance(v, l10n),
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_litersFocusNode),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  controller: _litersController,
                  focusNode: _litersFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: l10n.liters,
                    border: const OutlineInputBorder(),
                    isDense: true,
                  ),
                  validator: (v) => _validateLiters(v, l10n),
                  onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_commentFocusNode),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _commentController,
            focusNode: _commentFocusNode,
            keyboardType: TextInputType.text,
            maxLength: 200,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.commentOptional,
              border: const OutlineInputBorder(),
              isDense: true,
              hintText: l10n.addNote,
            ),
            onFieldSubmitted: (_) => _save(),
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

  Widget _buildFullForm(AppLocalizations l10n, String dateText) {
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
            focusNode: _kmFocusNode,
            autofocus: widget.autofocus,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.distanceKm,
              border: const OutlineInputBorder(),
            ),
            validator: (v) => _validateDistance(v, l10n),
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_litersFocusNode),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _litersController,
            focusNode: _litersFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: l10n.litersRefueled,
              border: const OutlineInputBorder(),
            ),
            validator: (v) => _validateLiters(v, l10n),
            onFieldSubmitted: (_) => FocusScope.of(context).requestFocus(_commentFocusNode),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            focusNode: _commentFocusNode,
            keyboardType: TextInputType.text,
            maxLength: 200,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l10n.commentOptional,
              border: const OutlineInputBorder(),
              hintText: l10n.addNoteFull,
            ),
            onFieldSubmitted: (_) => _save(),
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
