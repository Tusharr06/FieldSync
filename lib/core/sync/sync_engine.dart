import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../features/submissions/repository/submission_repository.dart';
import '../../features/submissions/models/submission_model.dart';
import '../../features/forms/repository/form_repository.dart';
import '../network/connectivity_service.dart';
import '../utils/firebase_paths.dart';

class SyncEngine {
  final Ref _ref;
  final FirebaseFirestore _firestore;

  SyncEngine(this._ref, {FirebaseFirestore? firestore}) 
      : _firestore = firestore ?? FirebaseFirestore.instance;

  void init() {
    _ref.listen<AsyncValue<List<ConnectivityResult>>>(connectivityStatusProvider, (previous, next) {
      next.whenData((results) {
         final isConnected = results.any((result) => result != ConnectivityResult.none);
         
         if (isConnected) {
           syncData();
         }
      });
    });
  }

  Future<void> syncData() async {
    final repository = _ref.read(submissionRepositoryProvider);
    
    final pendingSubmissions = await repository.getPendingSubmissions();
    
    if (pendingSubmissions.isNotEmpty) {
      for (final submission in pendingSubmissions) {
        if (submission.syncStatus == SyncStatus.draft) {
          continue;
        }
        await _processSubmission(repository, submission);
      }
    }

    try {
      await _ref.read(formRepositoryProvider).syncForms();
    } catch (e) {
      
      print('Sync failed: $e');
    }
  }

  Future<void> _processSubmission(SubmissionRepository repository, SubmissionModel submission) async {
     final user = FirebaseAuth.instance.currentUser;
     if (user == null) {
       return; 
     }

     try {
       final docRef = _firestore.collection(FirebasePaths.userSubmissions(user.uid)).doc(submission.id);

       final dataToUpload = {
         ...submission.toMap(),
         'serverTimestamp': FieldValue.serverTimestamp(),
       };
       
       await docRef.set(dataToUpload, SetOptions(merge: true));

       await repository.updateSubmissionStatus(submission.id, SyncStatus.synced);
       
     } catch (e) {
       await repository.updateSubmissionStatus(submission.id, SyncStatus.failed);
     }
  }
}

final syncEngineProvider = Provider<SyncEngine>((ref) {
  return SyncEngine(ref);
});
