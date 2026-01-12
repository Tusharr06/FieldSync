import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/form_model.dart';
import '../repository/form_repository.dart';

final formsListProvider = FutureProvider<List<FormModel>>((ref) async {
  final repository = ref.watch(formRepositoryProvider);
  return repository.getForms();
});
