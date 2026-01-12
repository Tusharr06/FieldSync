class SubmissionModel {
  final String id;
  final String formId;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String status;

  SubmissionModel({
    required this.id,
    required this.formId,
    required this.data,
    required this.timestamp,
    required this.status,
  });

  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    return SubmissionModel(
      id: map['id'] as String,
      formId: map['formId'] as String,
      data: map['data'] as Map<String, dynamic>,
      timestamp: DateTime.parse(map['timestamp'] as String),
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'formId': formId,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'status': status,
    };
  }
}
