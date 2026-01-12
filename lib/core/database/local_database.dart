import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class LocalDatabase {
  Future<void> init();
  Future<void> save(String boxName, String key, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> get(String boxName, String key);
  Future<List<Map<String, dynamic>>> getAll(String boxName);
  Future<void> delete(String boxName, String key);
  Future<void> clear(String boxName);
}

class HiveLocalDatabase implements LocalDatabase {
  @override
  Future<void> init() async {
    print('LocalDatabase initialized');
  }

  @override
  Future<void> save(String boxName, String key, Map<String, dynamic> data) async {
    print('Saved to $boxName: $key');
  }

  @override
  Future<Map<String, dynamic>?> get(String boxName, String key) async {
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String boxName) async {
    return [];
  }

  @override
  Future<void> delete(String boxName, String key) async {
  }

  @override
  Future<void> clear(String boxName) async {
  }
}

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return HiveLocalDatabase();
});
