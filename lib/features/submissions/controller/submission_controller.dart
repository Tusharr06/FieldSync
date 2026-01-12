import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/submission_repository.dart';
import '../models/submission_model.dart';
import '../../../core/sync/sync_engine.dart';
import 'dart:math';

/// Controller for managing the state of submissions and handling user actions.
/// It uses [AsyncNotifier] to manage the list of pending submissions.
class SubmissionController extends AsyncNotifier<List<SubmissionModel>> {
  late final SubmissionRepository _repository;
  late final SyncEngine _syncEngine;

  @override
  Future<List<SubmissionModel>> build() async {
    _repository = ref.read(submissionRepositoryProvider);
    _syncEngine = ref.read(syncEngineProvider);
    return _fetchPendingSubmissions();
  }

  /// Fetches pending submissions from the repository.
  Future<List<SubmissionModel>> _fetchPendingSubmissions() async {
    return _repository.getPendingSubmissions();
  }

  /// Reloads the state.
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchPendingSubmissions());
  }

  /// Submits a form.
  /// 1. Creates a SubmissionModel.
  /// 2. Saves it locally via Repository (offline-first).
  /// 3. Triggers a sync attempt.
  /// 4. Updates state.
  Future<void> submitForm({
    required String formId,
    required Map<String, dynamic> data,
  }) async {
    final newId = _generateId();
    final submission = SubmissionModel(
      id: newId,
      formId: formId,
      data: data,
      createdAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    // Save locally
    await _repository.createSubmission(submission);
    
    // Update UI state immediately to show the new pending submission
    state = await AsyncValue.guard(() async {
      final currentList = state.value ?? [];
      return [...currentList, submission];
    });

    // Attempt to sync immediately (fire and forget from UI perspective)
    // The SyncEngine will check connectivity and proceed if possible.
    _syncEngine.syncData().then((_) {
       // After sync attempt (success or fail), refresh the list to show updated status
       refresh();
    });
  }
  
  /// Simple ID generator since 'uuid' package is missing.
  /// Combines timestamp and a random number.
  String _generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = Random().nextInt(10000);
    return '$timestamp-$random';
  }
}

/// Provider for the SubmissionController.
final submissionControllerProvider = AsyncNotifierProvider<SubmissionController, List<SubmissionModel>>(() {
  return SubmissionController();
});
