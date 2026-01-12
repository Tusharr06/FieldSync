import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


/// Abstract definition of the local database interface.
/// Allows for swapping the underlying implementation (Hive, SQLite, etc.) in the future.
abstract class LocalDatabase {
  Future<void> init();
  Future<void> save(String boxName, String key, Map<String, dynamic> data);
  Future<Map<String, dynamic>?> get(String boxName, String key);
  Future<List<Map<String, dynamic>>> getAll(String boxName);
  Future<void> delete(String boxName, String key);
  Future<void> clear(String boxName);
}

/// Implementation of [LocalDatabase] using Hive.
/// Stores data as JSON-compatible Maps.
class HiveLocalDatabase implements LocalDatabase {
  
  @override
  Future<void> init() async {
    // Initialize Hive for Flutter.
    // This should be called in main() or before any DB operations.
    await Hive.initFlutter();
    
    // Open necessary boxes here or lazily.
    // We'll open a generic 'submissions' box for now.
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
    // Hive supports Map<dynamic, dynamic>, but we want to ensure we store clean data.
    // We convert the map to a JSON string if needed, or store as plain Map if Hive supports it.
    // Storing as Map directly is supported by Hive if keys are strings.
    await box.put(key, data);
  }

  @override
  Future<Map<String, dynamic>?> get(String boxName, String key) async {
    final box = await _getBox(boxName);
    final data = box.get(key);
    if (data != null) {
      // Cast safely to Map<String, dynamic>
      // Hive might return Map<dynamic, dynamic>.
      try {
        return Map<String, dynamic>.from(data);
      } catch (e) {
        // Fallback or error handling
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
}

/// Provider for the LocalDatabase instance.
final localDatabaseProvider = Provider<LocalDatabase>((ref) {
  return HiveLocalDatabase();
});
