enum FieldType {
  text,
  number,
  dropdown,
  date,
  photo,
  location,
}

class FormFieldModel {
  final String id;
  final String label;
  final FieldType type;
  final bool required;
  final List<String>? options;

  FormFieldModel({
    required this.id,
    required this.label,
    required this.type,
    this.required = false,
    this.options,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'label': label,
      'type': type.name,
      'required': required,
      'options': options,
    };
  }

  factory FormFieldModel.fromMap(Map<String, dynamic> map) {
    return FormFieldModel(
      id: map['id'] ?? '',
      label: map['label'] ?? '',
      type: FieldType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => FieldType.text,
      ),
      required: map['required'] ?? false,
      options: (map['options'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
    );
  }
}
