import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/refuel.dart';
import '../providers/refuel_provider.dart';

class AddRefuelForm extends ConsumerStatefulWidget {
  final Refuel? refuel;
  final VoidCallback? onSaved;
  final bool clearOnSave;

  const AddRefuelForm({super.key, this.refuel, this.onSaved, this.clearOnSave = false});

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

  @override
  void initState() {
    super.initState();
    if (widget.refuel != null) {
      final r = widget.refuel!;
      _selectedDate = r.date;
      _kilometerController.text = r.kilometers.toString();
      _litersController.text = r.liters.toString();
      _commentController.text = r.comment;
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

  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    final refuel = Refuel(
      id: widget.refuel?.id,
      date: _selectedDate,
      kilometers: double.parse(_kilometerController.text),
      comment: _commentController.text,
      liters: double.parse(_litersController.text),
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Repostaje añadido correctamente')),
      );
    }

    if (isEditing && widget.onSaved == null) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat.yMMMd().format(_selectedDate);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          ListTile(
            title: const Text('Fecha'),
            subtitle: Text(dateText),
            trailing: const Icon(Icons.calendar_month),
            onTap: () => _pickDate(context),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _kilometerController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Distancia (km)',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introduce la distancia del trayecto';
              }
              return double.tryParse(value) == null ? 'Valor numérico inválido' : null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _litersController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Litros repostados',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Introduce los litros';
              }
              return double.tryParse(value) == null ? 'Valor numérico inválido' : null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _commentController,
            keyboardType: TextInputType.text,
            decoration: const InputDecoration(
              labelText: 'Comentario (opcional)',
              border: OutlineInputBorder(),
              hintText: 'Añade una nota sobre este repostaje',
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              child: Text(isEditing ? 'Actualizar' : 'Guardar repostaje'),
            ),
          ),
        ],
      ),
    );
  }
}
