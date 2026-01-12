import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/form_model.dart';
import '../models/form_field_model.dart';
import '../controller/form_controller.dart';

class FormBuilderScreen extends ConsumerStatefulWidget {
  const FormBuilderScreen({super.key});

  @override
  ConsumerState<FormBuilderScreen> createState() => _FormBuilderScreenState();
}
  
class _FormBuilderScreenState extends ConsumerState<FormBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final List<FormFieldModel> _fields = [];
  bool _isSaving = false;

  void _addField() {
    setState(() {
      _fields.add(FormFieldModel(
        id: 'field_${DateTime.now().millisecondsSinceEpoch}',
        label: 'New Field',
        type: FieldType.text,
      ));
    });
    _editField(_fields.length - 1);
  }

  void _editField(int index) async {
    final field = _fields[index];
    final updatedField = await showDialog<FormFieldModel>(
      context: context,
      builder: (context) => _FieldEditorDialog(field: field),
    );

    if (updatedField != null) {
      setState(() {
        _fields[index] = updatedField;
      });
    }
  }

  void _removeField(int index) {
    setState(() {
      _fields.removeAt(index);
    });
  }

  Future<void> _saveForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_fields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one field')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      final form = FormModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descController.text,
        fields: _fields,
      );

      await ref.read(formControllerProvider).createForm(form);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving form: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Form'),
        actions: [
          IconButton(
            icon: _isSaving 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) 
              : const Icon(Icons.check),
            onPressed: _isSaving ? null : _saveForm,
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Form Title'),
                    validator: (v) => v?.isEmpty == true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _descController,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                ],
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _fields.length,
                itemBuilder: (context, index) {
                  final field = _fields[index];
                  return ListTile(
                    title: Text(field.label),
                    subtitle: Text(field.type.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _editField(index)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _removeField(index)),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addField,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _FieldEditorDialog extends StatefulWidget {
  final FormFieldModel field;
  const _FieldEditorDialog({required this.field});

  @override
  State<_FieldEditorDialog> createState() => _FieldEditorDialogState();
}

class _FieldEditorDialogState extends State<_FieldEditorDialog> {
  late TextEditingController _labelController;
  late FieldType _type;
  late bool _required;
  late TextEditingController _optionsController;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.field.label);
    _type = widget.field.type;
    _required = widget.field.required;
    _optionsController = TextEditingController(text: widget.field.options?.join(', '));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Field'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<FieldType>(
              value: _type,
              decoration: const InputDecoration(labelText: 'Type'),
              items: FieldType.values.map((t) => DropdownMenuItem(value: t, child: Text(t.name))).toList(),
              onChanged: (v) => setState(() => _type = v!),
            ),
            const SizedBox(height: 16),
            if (_type == FieldType.dropdown)
              TextField(
                controller: _optionsController,
                decoration: const InputDecoration(labelText: 'Options (comma separated)'),
              ),
            CheckboxListTile(
              title: const Text('Required'),
              value: _required,
              onChanged: (v) => setState(() => _required = v!),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: () {
            List<String>? options;
            if (_type == FieldType.dropdown && _optionsController.text.isNotEmpty) {
              options = _optionsController.text.split(',').map((e) => e.trim()).toList();
            }
            
            Navigator.pop(context, FormFieldModel(
              id: widget.field.id, // Keep ID
              label: _labelController.text,
              type: _type,
              required: _required,
              options: options,
            ));
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
