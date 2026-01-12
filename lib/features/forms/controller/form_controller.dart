import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/form_model.dart';
import '../../submissions/repository/submission_repository.dart';
import '../../submissions/models/submission_model.dart';

final formListProvider = Provider<List<FormModel>>((ref) {
  return [
    FormModel(
      id: '1', 
      title: 'Pest Scouter', 
      description: 'Record pest activity in the field', 
      fields: ['Pest Type', 'Count', 'Location']
    ),
    FormModel(
      id: '2', 
      title: 'Crop Health Inspector', 
      description: 'General crop health assessment', 
      fields: ['Crop Height (cm)', 'Leaf Color', 'Disease Signs']
    ),
    FormModel(
      id: '3', 
      title: 'Equipment Usage Log', 
      description: 'Track equipment hours and fuel', 
      fields: ['Equipment ID', 'Hours Used', 'Fuel Level (%)']
    ),
  ];
});

final formControllerProvider = Provider((ref) => FormController(ref));

class FormController {
  final Ref _ref;
  FormController(this._ref);

  Future<void> submitForm(String formId, Map<String, dynamic> data, {SyncStatus status = SyncStatus.pending}) async {
    final submission = SubmissionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      formId: formId,
      data: data,
      createdAt: DateTime.now(),
      syncStatus: status,
    );
    await _ref.read(submissionRepositoryProvider).createSubmission(submission);
  }
}
