import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/local_database.dart';
import '../models/submission_model.dart';

class SubmissionRepository {
  final LocalDatabase _localDatabase;
  static const String _boxName = 'submissions';

  SubmissionRepository(this._localDatabase);

  Future<void> createSubmission(SubmissionModel submission) async {
    await _localDatabase.save(_boxName, submission.id, submission.toMap());
  }

  Future<SubmissionModel?> getSubmission(String id) async {
    final data = await _localDatabase.get(_boxName, id);
    if (data != null) {
      return SubmissionModel.fromMap(data);
    }
    return null;
  }

  Future<List<SubmissionModel>> getPendingSubmissions() async {
    final allData = await _localDatabase.getAll(_boxName);
    return allData
        .map((data) => SubmissionModel.fromMap(data))
        .where((submission) => submission.syncStatus == SyncStatus.pending)
        .toList();
  }

  Future<void> updateSubmissionStatus(String id, SyncStatus status) async {
    final submission = await getSubmission(id);
    if (submission != null) {
      final updatedSubmission = submission.copyWith(syncStatus: status);
      await _localDatabase.save(_boxName, id, updatedSubmission.toMap());
    }
  }

  Future<List<SubmissionModel>> getAllSubmissions() async {
    final allData = await _localDatabase.getAll(_boxName);
    return allData.map((data) => SubmissionModel.fromMap(data)).toList();
  }
}

final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  final localDatabase = ref.watch(localDatabaseProvider);
  return SubmissionRepository(localDatabase);
});
