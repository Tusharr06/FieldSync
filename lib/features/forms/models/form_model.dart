import 'form_field_model.dart';

class FormModel {
  final String id;
  final String title;
  final String description;
  final List<FormFieldModel> fields;
  final bool isSynced;

  FormModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fields,
    this.isSynced = false,
  });

  factory FormModel.fromMap(Map<String, dynamic> map) {
    return FormModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      isSynced: map['isSynced'] ?? false,
      fields: (map['fields'] as List<dynamic>?)
              ?.map((x) {
                if (x is Map) {
                  return FormFieldModel.fromMap(Map<String, dynamic>.from(x));
                }
                return null;
              })
              .whereType<FormFieldModel>()
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isSynced': isSynced,
      'fields': fields.map((x) => x.toMap()).toList(),
    };
  }
  
  FormModel copyWith({
    String? id,
    String? title,
    String? description,
    List<FormFieldModel>? fields,
    bool? isSynced,
  }) {
    return FormModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      fields: fields ?? this.fields,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
