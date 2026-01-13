import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/submission_model.dart';
import '../repository/submission_repository.dart';

final submissionListProvider = StreamProvider.autoDispose<List<SubmissionModel>>((ref) async* {
  final repository = ref.watch(submissionRepositoryProvider);
  final user = FirebaseAuth.instance.currentUser;
  
  if (user == null) {
    yield [];
    return;
  }

  
  var initialList = await repository.getAllSubmissions();
  yield initialList.where((s) => s.userId == user.uid).toList();

  
  await for (final submissions in repository.watchSubmissions()) {
    yield submissions.where((s) => s.userId == user.uid).toList();
  }
});
