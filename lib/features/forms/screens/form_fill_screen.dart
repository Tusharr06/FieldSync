import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../models/form_model.dart';
import '../models/form_field_model.dart';
import '../controller/form_controller.dart';
import '../../submissions/models/submission_model.dart';

class FormFillScreen extends ConsumerStatefulWidget {
  final FormModel form;
  const FormFillScreen({super.key, required this.form});

  @override
  ConsumerState<FormFillScreen> createState() => _FormFillScreenState();
}

class _FormFillScreenState extends ConsumerState<FormFillScreen> {
  final Map<String, dynamic> _formData = {};
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    
  }

  Future<void> _submit({bool isDraft = false}) async {
    if (!isDraft && !_formKey.currentState!.validate()) return;
    
    _formKey.currentState!.save();
    setState(() => _isSubmitting = true);
    
    try {
      await ref.read(formControllerProvider).submitForm(
        widget.form.id, 
        Map<String, dynamic>.from(_formData),
        status: isDraft ? SyncStatus.draft : SyncStatus.pending,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isDraft ? 'Draft saved!' : 'Form saved locally!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.form.title)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: widget.form.fields.map((field) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildFieldWidget(field),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: Row(
                   children: [
                     Expanded(
                       child: OutlinedButton(
                         onPressed: _isSubmitting ? null : () => _submit(isDraft: true),
                         child: const Text('Save Draft'),
                       ),
                     ),
                     const SizedBox(width: 16),
                     Expanded(
                       child: ElevatedButton(
                         onPressed: _isSubmitting ? null : () => _submit(isDraft: false),
                         child: _isSubmitting 
                             ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                             : const Text('Submit'),
                       ),
                     ),
                   ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldWidget(FormFieldModel field) {
    switch (field.type) {
      case FieldType.text:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.label + (field.required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          validator: (value) {
            if (field.required && (value == null || value.isEmpty)) {
              return 'Required';
            }
            return null;
          },
          onSaved: (value) => _formData[field.label] = value,
        );
      case FieldType.number:
        return TextFormField(
          decoration: InputDecoration(
            labelText: field.label + (field.required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (field.required && (value == null || value.isEmpty)) {
              return 'Required';
            }
            return null;
          },
          onSaved: (value) => _formData[field.label] = value,
        );
      case FieldType.dropdown:
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: field.label + (field.required ? ' *' : ''),
            border: const OutlineInputBorder(),
          ),
          items: field.options?.map((opt) => DropdownMenuItem(value: opt, child: Text(opt))).toList(),
          onChanged: (value) {},
          validator: (value) {
            if (field.required && value == null) return 'Required';
            return null;
          },
          onSaved: (value) => _formData[field.label] = value,
        );
      case FieldType.date:
        return FormField<String>(
          validator: (value) {
            if (field.required && (value == null || value.isEmpty)) return 'Required';
            return null;
          },
          onSaved: (value) => _formData[field.label] = value,
          builder: (state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputDecorator(
                  decoration: InputDecoration(
                    labelText: field.label + (field.required ? ' *' : ''),
                    border: const OutlineInputBorder(),
                    errorText: state.errorText,
                  ),
                  child: InkWell(
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        final val = date.toIso8601String().split('T')[0];
                        state.didChange(val);
                        _formData[field.label] = val; 
                      }
                    },
                    child: Text(state.value ?? 'Select Date'),
                  ),
                ),
              ],
            );
          },
        );
      case FieldType.photo:
         
        return FormField<String>(
           onSaved: (value) => _formData[field.label] = value,
           builder: (state) {
             return InputDecorator(
               decoration: InputDecoration(
                 labelText: field.label,
                 border: const OutlineInputBorder(),
               ),
               child: Row(
                 children: [
                   const Icon(Icons.camera_alt),
                   const SizedBox(width: 8),
                   Expanded(child: Text(state.value ?? 'No photo selected', overflow: TextOverflow.ellipsis)),
                   TextButton(
                     onPressed: () {
                       final val = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
                       state.didChange(val);
                     },
                     child: const Text('Capture (Simulated)'),
                   )
                 ],
               ),
             );
           }
        );
      case FieldType.location:
        return FormField<String>(
           onSaved: (value) => _formData[field.label] = value,
           builder: (state) {
              return InputDecorator(
                decoration: InputDecoration(
                  labelText: field.label + (field.required ? ' *' : ''),
                  border: const OutlineInputBorder(),
                  errorText: state.errorText,
                ),
                child: Row(
                   children: [
                     const Icon(Icons.location_on, color: Colors.red),
                     const SizedBox(width: 8),
                     Expanded(child: Text(state.value ?? 'No location data', style: TextStyle(color: state.value == null ? Colors.grey : Colors.black))),
                     IconButton(
                       icon: const Icon(Icons.my_location),
                       onPressed: () async {
                          try {
                            bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
                            if (!context.mounted) return;
                            if (!serviceEnabled) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Location services are disabled.')));
                              return;
                            }
                            
                            LocationPermission permission = await Geolocator.checkPermission();
                            if (permission == LocationPermission.denied) {
                              permission = await Geolocator.requestPermission();
                              if (permission == LocationPermission.denied) return;
                            }
                            
                            if (permission == LocationPermission.deniedForever) return;

                            final pos = await Geolocator.getCurrentPosition();
                            final val = '${pos.latitude},${pos.longitude}';
                            state.didChange(val);
                          } catch (e) {
                             ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
                          }
                       },
                     ),
                   ],
                ),
              );
           },
           validator: (value) {
              if (field.required && (value == null || value.isEmpty)) return 'Required';
              return null;
           },
        );
    }
  }
}
