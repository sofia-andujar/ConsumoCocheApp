import 'package:flutter/material.dart';
import '../models/refuel.dart';
import '../widgets/add_refuel_form.dart';

class AddRefuelScreen extends StatelessWidget {
  static const routeName = '/add';

  final Refuel? refuel;

  const AddRefuelScreen({super.key, this.refuel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(refuel != null ? 'Editar repostaje' : 'Añadir repostaje'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: AddRefuelForm(
            refuel: refuel,
            onSaved: () {
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }
}
