import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/submission_model.dart';
import '../../../core/database/local_database.dart';

abstract class SubmissionRepository {
  Future<void> saveSubmission(SubmissionModel submission);
  Future<List<SubmissionModel>> getSubmissions();
}

class SubmissionRepositoryImpl implements SubmissionRepository {
  final LocalDatabase _localDatabase;

  SubmissionRepositoryImpl(this._localDatabase);

  @override
  Future<void> saveSubmission(SubmissionModel submission) async {
    await _localDatabase.save('submissions', submission.id, submission.toMap());
  }

  @override
  Future<List<SubmissionModel>> getSubmissions() async {
    final maps = await _localDatabase.getAll('submissions');
    if (maps.isEmpty) {
        return [
            SubmissionModel(
                id: 'sub_1',
                formId: '1',
                data: {'location': 'Site A', 'inspector_name': 'John Doe'},
                timestamp: DateTime.now(),
                status: 'pending',
            )
        ];
    }
    return maps.map((e) => SubmissionModel.fromMap(e)).toList();
  }
}

final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  return SubmissionRepositoryImpl(ref.watch(localDatabaseProvider));
});
