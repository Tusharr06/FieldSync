import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class LocalDatabase {
  Future<void> init();
  Future<void> save(String boxName, String key, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> get(String boxName, String key);
  Future<List<Map<String, dynamic>>> getAll(String boxName);
  Future<void> delete(String boxName, String key);
  Future<void> clear(String boxName);
  Stream<void> watch(String boxName);
}

class HiveLocalDatabase implements LocalDatabase {
  
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('submissions');
  }

  Future<Box> _getBox(String boxName) async {
    if (!Hive.isBoxOpen(boxName)) {
      return await Hive.openBox(boxName);
    }
    return Hive.box(boxName);
  }

  @override
  Future<void> save(String boxName, String key, Map<String, dynamic> data) async {
    final box = await _getBox(boxName);
    await box.put(key, data);
  }

  @override
  Future<Map<String, dynamic>?> get(String boxName, String key) async {
    final box = await _getBox(boxName);
    final data = box.get(key);
    if (data != null) {
      try {
        return Map<String, dynamic>.from(data);
      } catch (e) {
        print('Error parsing data from Hive: $e');
        return null;
      }
    }
    return null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String boxName) async {
    final box = await _getBox(boxName);
    final List<Map<String, dynamic>> results = [];
    
    for (var i = 0; i < box.length; i++) {
        final data = box.getAt(i);
        if (data != null) {
            try {
                 results.add(Map<String, dynamic>.from(data));
            } catch (e) {
                print('Error parsing item at index $i from Hive: $e');
            }
        }
    }
    return results;
  }

  @override
  Future<void> delete(String boxName, String key) async {
    final box = await _getBox(boxName);
    await box.delete(key);
  }

  @override
  Future<void> clear(String boxName) async {
    final box = await _getBox(boxName);
    await box.clear();
  }

  @override
  Stream<void> watch(String boxName) async* {
    final box = await _getBox(boxName);
    yield* box.watch().map((event) {});
  }
}

final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return HiveLocalDatabase();
});
