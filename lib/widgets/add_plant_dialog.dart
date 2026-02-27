import 'package:flutter/material.dart';
import 'package:monitor_baby/models/plant.dart';

class AddPlantDialog extends StatefulWidget {
  const AddPlantDialog({
    super.key,
    required this.onSaved,
  });

  final ValueChanged<Plant> onSaved;

  @override
  State<AddPlantDialog> createState() => _AddPlantDialogState();
}

class _AddPlantDialogState extends State<AddPlantDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  final _scientificNameController = TextEditingController();
  final _frequencyController = TextEditingController(text: '3');

  @override
  void dispose() {
    _nicknameController.dispose();
    _scientificNameController.dispose();
    _frequencyController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final frequency = int.parse(_frequencyController.text.trim());
    final plant = Plant(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      nickname: _nicknameController.text.trim(),
      scientificName: _scientificNameController.text.trim(),
      waterFrequencyDays: frequency,
    );

    widget.onSaved(plant);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar planta'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                controller: _nicknameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un nombre';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _scientificNameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre científico',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa el nombre científico';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _frequencyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Frecuencia de riego (días)',
                ),
                validator: (value) {
                  final parsed = int.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
