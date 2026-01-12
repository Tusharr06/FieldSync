import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/local_database.dart';
import '../models/submission_model.dart';

/// Repository for handling submission data operations.
/// Encapsulates all data access logic, primarily interacting with the local database.
class SubmissionRepository {
  final LocalDatabase _localDatabase;
  static const String _boxName = 'submissions';

  SubmissionRepository(this._localDatabase);

  /// Saves a new submission to the local database.
  /// Typically called when a user completes a form.
  /// The submission is initially stored with SyncStatus.pending.
  Future<void> createSubmission(SubmissionModel submission) async {
    await _localDatabase.save(_boxName, submission.id, submission.toMap());
  }

  /// Retrieves a specific submission by ID.
  Future<SubmissionModel?> getSubmission(String id) async {
    final data = await _localDatabase.get(_boxName, id);
    if (data != null) {
      return SubmissionModel.fromMap(data);
    }
    return null;
  }

  /// Retrieves all pending submissions that need to be synced.
  Future<List<SubmissionModel>> getPendingSubmissions() async {
    final allData = await _localDatabase.getAll(_boxName);
    return allData
        .map((data) => SubmissionModel.fromMap(data))
        .where((submission) => submission.syncStatus == SyncStatus.pending)
        .toList();
  }

  /// Updates the sync status of a submission.
  /// Used by the SyncEngine to mark success or failure.
  Future<void> updateSubmissionStatus(String id, SyncStatus status) async {
    final submission = await getSubmission(id);
    if (submission != null) {
      final updatedSubmission = submission.copyWith(syncStatus: status);
      await _localDatabase.save(_boxName, id, updatedSubmission.toMap());
    }
  }

  /// Retrieves all submissions (for history/logs).
  Future<List<SubmissionModel>> getAllSubmissions() async {
    final allData = await _localDatabase.getAll(_boxName);
    return allData.map((data) => SubmissionModel.fromMap(data)).toList();
  }
}

/// Provider for the SubmissionRepository.
final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  final localDatabase = ref.watch(localDatabaseProvider);
  return SubmissionRepository(localDatabase);
});
