import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/submission_model.dart';
import '../repository/submission_repository.dart';

final submissionListProvider = FutureProvider.autoDispose<List<SubmissionModel>>((ref) async {
  final repository = ref.watch(submissionRepositoryProvider);
  return repository.getAllSubmissions();
});
