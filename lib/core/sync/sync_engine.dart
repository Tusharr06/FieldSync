import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../../features/submissions/repository/submission_repository.dart';
import '../../features/submissions/models/submission_model.dart';
import '../network/connectivity_service.dart';

/// Engine responsible for synchronizing local data with the remote server.
/// - Listens to connectivity changes.
/// - Iterates through pending submissions.
/// - Simulates upload logic.
/// - Ensures data safety by not deleting local records until confirmed.
class SyncEngine {
  final Ref _ref;

  SyncEngine(this._ref);

  /// Initializes the sync engine.
  /// Should be called at app startup.
  void init() {
    print('SyncEngine: Initializing...');
    
    // Listen to connectivity changes to trigger sync automatically.
    _ref.listen<AsyncValue<List<ConnectivityResult>>>(connectivityStatusProvider, (previous, next) {
      next.whenData((results) {
         // Check if we have a valid connection (any connection type other than none)
         final isConnected = results.any((result) => result != ConnectivityResult.none);
         
         if (isConnected) {
           print('SyncEngine: Connection detected. Triggering sync...');
           syncData();
         } else {
           print('SyncEngine: No connection.');
         }
      });
    });
  }

  /// Triggers the synchronization process.
  /// Can be called manually or automatically.
  /// It is designed to be idempotent and safe.
  Future<void> syncData() async {
    final repository = _ref.read(submissionRepositoryProvider);
    
    // 1. Fetch pending submissions
    final pendingSubmissions = await repository.getPendingSubmissions();
    
    if (pendingSubmissions.isEmpty) {
      print('SyncEngine: No pending submissions to sync.');
      return;
    }

    print('SyncEngine: Found ${pendingSubmissions.length} pending submissions.');

    // 2. Iterate and attempt to sync each one
    for (final submission in pendingSubmissions) {
      await _processSubmission(repository, submission);
    }
    
    print('SyncEngine: Batch sync complete.');
  }

  /// Processes a single submission.
  Future<void> _processSubmission(SubmissionRepository repository, SubmissionModel submission) async {
     print('SyncEngine: Syncing submission ${submission.id}...');
     
     try {
       // --- SIMULATED FIREBASE UPLOAD START ---
       // TODO: Replace with actual Firebase Firestore/Storage logic.
       // Example: await FirebaseFirestore.instance.collection('submissions').add(submission.toMap());
       
       await Future.delayed(const Duration(seconds: 1)); // Simulate network latency
       
       // Simulate a random failure for testing robustness (10% chance fail)
       // Remove this in production.
       final bool success = DateTime.now().millisecond % 10 != 0; 
       
       if (!success) {
         throw Exception('Simulated network error');
       }
       // --- SIMULATED FIREBASE UPLOAD END ---

       // Success! Update local status to synced.
       await repository.updateSubmissionStatus(submission.id, SyncStatus.synced);
       print('SyncEngine: Submission ${submission.id} SYNCED.');
       
     } catch (e) {
       // Failure. Update local status to failed.
       // Note: In a real app, you might want a retry count or 'failed' might just mean 'retry later'.
       // Here we explicitly mark as failed to show visibility in UI.
       print('SyncEngine: Failed to sync submission ${submission.id}. Error: $e');
       await repository.updateSubmissionStatus(submission.id, SyncStatus.failed);
     }
  }
}

/// Provider for the SyncEngine.
final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(ref);
});
