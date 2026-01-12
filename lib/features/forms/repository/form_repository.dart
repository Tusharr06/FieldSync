import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/database/local_database.dart';
import '../models/form_model.dart';

class FormRepository {
  final Ref _ref;
  final FirebaseFirestore _firestore;

  FormRepository(this._ref, {FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> saveForm(FormModel form) async {
    final db = _ref.read(localDatabaseProvider);
    final unsyncedForm = form.copyWith(isSynced: false);
    await db.save('forms', unsyncedForm.id, unsyncedForm.toMap());
  }

  Future<List<FormModel>> getAllForms() async {
    final db = _ref.read(localDatabaseProvider);
    final dataList = await db.getAll('forms');
    return dataList.map((map) => FormModel.fromMap(map)).toList();
  }

  Future<void> deleteForm(String formId) async {
    final db = _ref.read(localDatabaseProvider);
    await db.delete('forms', formId);
  }

  Future<void> syncForms() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final forms = await getAllForms();
    final batch = _firestore.batch();
    
    final unsyncedForms = forms.where((f) => !f.isSynced).toList();
    if (unsyncedForms.isEmpty) return;

    for (final form in unsyncedForms) {
      final docRef = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('forms')
          .doc(form.id);
      
      batch.set(docRef, form.copyWith(isSynced: true).toMap(), SetOptions(merge: true));
    }

    await batch.commit();

    final db = _ref.read(localDatabaseProvider);
    for (final form in unsyncedForms) {
        await db.save('forms', form.id, form.copyWith(isSynced: true).toMap());
    }
  }
}

final formRepositoryProvider = Provider((ref) => FormRepository(ref));
