class FormModel {
  final String id;
  final String title;
  final String description;
  final List<String> fields;

  FormModel({
    required this.id,
    required this.title,
    required this.description,
    required this.fields,
  });

  factory FormModel.fromMap(Map<String, dynamic> map) {
    return FormModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      fields: List<String>.from(map['fields'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'fields': fields,
    };
  }
}
