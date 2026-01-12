import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/form_model.dart';

abstract class FormRepository {
  Future<List<FormModel>> getForms();
}

class FormRepositoryImpl implements FormRepository {
  @override
  Future<List<FormModel>> getForms() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      FormModel(
        id: '1',
        title: 'Site Inspection',
        description: 'Daily site safety inspection form.',
        fields: ['location', 'inspector_name', 'has_issues'],
      ),
      FormModel(
        id: '2',
        title: 'Equipment Check',
        description: 'Verify equipment status.',
        fields: ['equipment_id', 'status', 'comments'],
      ),
    ];
  }
}

final formRepositoryProvider = Provider<FormRepository>((ref) {
  return FormRepositoryImpl();
});
