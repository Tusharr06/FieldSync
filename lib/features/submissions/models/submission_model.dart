import 'dart:convert';

enum SyncStatus {
  draft,
  pending,
  synced,
  failed,
}

class SubmissionModel {
  final String id;
  final String formId;
  final String? userId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final SyncStatus syncStatus;

  const SubmissionModel({
    required this.id,
    required this.formId,
    this.userId,
    required this.data,
    required this.createdAt,
    required this.syncStatus,
  });

  SubmissionModel copyWith({
    String? id,
    String? formId,
    String? userId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      formId: formId ?? this.formId,
      userId: userId ?? this.userId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'formId': formId,
      'userId': userId,
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'syncStatus': syncStatus.toString(), 
    };
  }

  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    return SubmissionModel(
      id: map['id'] ?? '',
      formId: map['formId'] ?? '',
      userId: map['userId'],
      data: Map<String, dynamic>.from(map['data'] ?? {}),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
      syncStatus: SyncStatus.values.firstWhere(
        (e) => e.toString() == map['syncStatus'],
        orElse: () => SyncStatus.pending,
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory SubmissionModel.fromJson(String source) =>
      SubmissionModel.fromMap(json.decode(source));

  @override
  String toString() {
    return 'SubmissionModel(id: $id, formId: $formId, data: $data, createdAt: $createdAt, syncStatus: $syncStatus)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is SubmissionModel &&
      other.id == id &&
      other.formId == formId &&
      other.createdAt == createdAt &&
      other.syncStatus == syncStatus;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      formId.hashCode ^
      createdAt.hashCode ^
      syncStatus.hashCode;
  }
}
