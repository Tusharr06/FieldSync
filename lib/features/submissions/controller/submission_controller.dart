import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/submission_model.dart';
import '../repository/submission_repository.dart';

final submissionListProvider = StreamProvider.autoDispose<List<SubmissionModel>>((ref) async* {
  final repository = ref.watch(submissionRepositoryProvider);
  
  yield await repository.getAllSubmissions();

  await for (final submissions in repository.watchSubmissions()) {
    yield submissions;
  }
});
