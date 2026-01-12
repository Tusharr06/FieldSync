import 'dart:convert';

/// Enum representing the synchronization status of a submission.
enum SyncStatus {
  pending,
  synced,
  failed,
}

/// Model class representing a form submission.
///
/// Contains the data collected from the form, metadata like ID and creation time,
/// and the current synchronization status.
class SubmissionModel {
  final String id;
  final String formId;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final SyncStatus syncStatus;

  const SubmissionModel({
    required this.id,
    required this.formId,
    required this.data,
    required this.createdAt,
    required this.syncStatus,
  });

  /// Creates a copy of this submission with the given fields replaced with new values.
  SubmissionModel copyWith({
    String? id,
    String? formId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    SyncStatus? syncStatus,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      formId: formId ?? this.formId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  /// Converts the submission to a Map for storage/JSON.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'formId': formId,
      'data': data,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'syncStatus': syncStatus.toString(), // Store as string for Hive simplicity
    };
  }

  /// Creates a SubmissionModel from a Map.
  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    return SubmissionModel(
      id: map['id'] ?? '',
      formId: map['formId'] ?? '',
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
