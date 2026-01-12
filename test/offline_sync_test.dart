import 'package:flutter_test/flutter_test.dart';
import 'package:fieldsync/core/database/local_database.dart';
import 'package:fieldsync/core/sync/sync_engine.dart';
import 'package:fieldsync/core/network/connectivity_service.dart';
import 'package:fieldsync/features/submissions/models/submission_model.dart';
import 'package:fieldsync/features/submissions/repository/submission_repository.dart';
import 'package:fieldsync/features/forms/controller/form_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class MockLocalDatabase implements LocalDatabase {
  final Map<String, Map<String, dynamic>> _storage = {};

  @override
  Future<void> init() async {}

  @override
  Future<void> save(String boxName, String key, Map<String, dynamic> data) async {
    _storage[key] = data;
  }

  @override
  Future<Map<String, dynamic>?> get(String boxName, String key) async {
    return _storage[key];
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String boxName) async {
    return _storage.values.toList();
  }

  @override
  Future<void> delete(String boxName, String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear(String boxName) async {
    _storage.clear();
  }
}

class MockConnectivityService extends ConnectivityService {
  final List<ConnectivityResult> _status;
  
  MockConnectivityService(this._status);

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return _status;
  }
  
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged => Stream.value(_status);
}

void main() {
  group('Offline-First Pipeline Tests', () {
    late ProviderContainer container;
    late MockLocalDatabase mockDb;

    setUp(() {
      mockDb = MockLocalDatabase();
      container = ProviderContainer(
        overrides: [
          localDatabaseProvider.overrideWithValue(mockDb),
          connectivityServiceProvider.overrideWithValue(MockConnectivityService([ConnectivityResult.wifi])),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('Submission is saved locally with SyncStatus.pending', () async {
      final repository = container.read(submissionRepositoryProvider);
      
      final submission = SubmissionModel(
        id: '123',
        formId: 'form_1',
        data: {'key': 'value'},
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );

      await repository.createSubmission(submission);

      final fetched = await repository.getSubmission('123');
      expect(fetched, isNotNull);
      expect(fetched?.id, '123');
      expect(fetched?.syncStatus, SyncStatus.pending);
    });

    test('SyncEngine processes pending submissions', skip: true, () async {
      final repository = container.read(submissionRepositoryProvider);
      final syncEngine = container.read(syncEngineProvider);

      final submission = SubmissionModel(
        id: '456',
        formId: 'form_2',
        data: {'foo': 'bar'},
        createdAt: DateTime.now(),
        syncStatus: SyncStatus.pending,
      );
      await repository.createSubmission(submission);

      await syncEngine.syncData();

      final updated = await repository.getSubmission('456');
      
      expect(updated?.syncStatus, isNot(SyncStatus.pending));
    });

    test('FormController creates and saves submission', () async {
      final controller = container.read(formControllerProvider);
      
      await controller.submitForm('form_3', {'test': 'data'});
      
      await Future.delayed(const Duration(milliseconds: 100));

      final repository = container.read(submissionRepositoryProvider);
      final pending = await repository.getAllSubmissions();
      
      expect(pending, isNotEmpty);
      expect(pending.last.formId, 'form_3');
    });
  });
}
