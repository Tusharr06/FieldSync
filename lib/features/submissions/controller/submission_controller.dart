import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/submission_model.dart';
import '../repository/submission_repository.dart';

class SubmissionController extends StateNotifier<AsyncValue<void>> {
  final SubmissionRepository _repository;

  SubmissionController(this._repository) : super(const AsyncValue.data(null));

  Future<void> createSubmission(String formId, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      final submission = SubmissionModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        formId: formId,
        data: data,
        timestamp: DateTime.now(),
        status: 'pending',
      );
      await _repository.saveSubmission(submission);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final submissionControllerProvider = StateNotifierProvider<SubmissionController, AsyncValue<void>>((ref) {
  return SubmissionController(ref.watch(submissionRepositoryProvider));
});

final submissionsListProvider = FutureProvider.autoDispose<List<SubmissionModel>>((ref) async {
  final repository = ref.watch(submissionRepositoryProvider);
  return repository.getSubmissions();
});
