import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../features/submissions/repository/submission_repository.dart';
import '../../features/submissions/models/submission_model.dart';
import '../network/connectivity_service.dart';
import '../utils/firebase_paths.dart';

class SyncEngine {
  final Ref _ref;
  final FirebaseFirestore _firestore;

  SyncEngine(this._ref, {FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  void init() {
    print('SyncEngine: Initializing...');
    
    _ref.listen<AsyncValue<List<ConnectivityResult>>>(connectivityStatusProvider, (previous, next) {
      next.whenData((results) {
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

  Future<void> syncData() async {
    final repository = _ref.read(submissionRepositoryProvider);
    
    final pendingSubmissions = await repository.getPendingSubmissions();
    
    if (pendingSubmissions.isEmpty) {
      print('SyncEngine: No pending submissions to sync.');
      return;
    }

    print('SyncEngine: Found ${pendingSubmissions.length} pending submissions.');

    for (final submission in pendingSubmissions) {
      await _processSubmission(repository, submission);
    }
    
    print('SyncEngine: Batch sync complete.');
  }

  Future<void> _processSubmission(SubmissionRepository repository, SubmissionModel submission) async {
     print('SyncEngine: Syncing submission ${submission.id}...');
     
     try {
       final docRef = _firestore.collection(FirebasePaths.submissions).doc(submission.id);

       final dataToUpload = {
         ...submission.toMap(),
         'serverTimestamp': FieldValue.serverTimestamp(),
       };
       
       await docRef.set(dataToUpload, SetOptions(merge: true));

       await repository.updateSubmissionStatus(submission.id, SyncStatus.synced);
       print('SyncEngine: Submission ${submission.id} SYNCED.');
       
     } catch (e) {
       print('SyncEngine: Failed to sync submission ${submission.id}. Error: $e');
       await repository.updateSubmissionStatus(submission.id, SyncStatus.failed);
     }
  }
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(ref);
});
