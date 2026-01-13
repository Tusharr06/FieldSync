import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/form_model.dart';
import '../models/form_field_model.dart';
import '../repository/form_repository.dart';
import '../../submissions/repository/submission_repository.dart';
import '../../submissions/models/submission_model.dart';

final formListProvider = FutureProvider<List<FormModel>>((ref) async {
  final repository = ref.watch(formRepositoryProvider);
  return repository.getAllForms();
});

final formControllerProvider = Provider((ref) => FormController(ref));

class FormController {
  final Ref _ref;
  FormController(this._ref);

  Future<void> createForm(FormModel form) async {
    await _ref.read(formRepositoryProvider).saveForm(form);
    _ref.invalidate(formListProvider);
  }

  Future<void> seedDebugForms() async {
    final forms = [
      FormModel(
        id: '1', 
        title: 'Pest Scouter', 
        description: 'Record pest activity in the field', 
        fields: [
          FormFieldModel(id: 'pest_type', label: 'Pest Type', type: FieldType.text, required: true),
          FormFieldModel(id: 'count', label: 'Count', type: FieldType.number),
          FormFieldModel(id: 'location', label: 'Location', type: FieldType.text),
        ]
      ),
      FormModel(
        id: '2', 
        title: 'Crop Health Inspector', 
        description: 'General crop health assessment', 
        fields: [
          FormFieldModel(id: 'crop_height', label: 'Crop Height (cm)', type: FieldType.number),
          FormFieldModel(id: 'leaf_color', label: 'Leaf Color', type: FieldType.dropdown, options: ['Green', 'Yellow', 'Brown']),
          FormFieldModel(id: 'photo', label: 'Photo', type: FieldType.photo),
        ]
      ),
    ];

    for (var form in forms) {
      await createForm(form);
    }
  }

  Future<void> submitForm(String formId, Map<String, dynamic> data, {SyncStatus status = SyncStatus.pending}) async {
    final user = FirebaseAuth.instance.currentUser;
    final submission = SubmissionModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      formId: formId,
      userId: user?.uid,
      data: data,
      createdAt: DateTime.now(),
      syncStatus: status,
    );
    await _ref.read(submissionRepositoryProvider).createSubmission(submission);
  }
}
