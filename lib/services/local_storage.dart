import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalStorage {
  static final LocalStorage instance = LocalStorage._init();
  static const String _fileName = "offline_pelanggaran.json";

  LocalStorage._init();

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    final path = "${directory.path}/$_fileName";
    print("OFFLINE_DEBUG: JSON Storage Path: $path");
    return File(path);
  }

  Future<List<Map<String, dynamic>>> _readData() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        print("OFFLINE_DEBUG: JSON file does not exist, returning empty list.");
        return [];
      }
      final contents = await file.readAsString();
      if (contents.isEmpty) return [];
      
      final List<dynamic> jsonList = json.decode(contents);
      return jsonList.cast<Map<String, dynamic>>();
    } catch (e) {
      print("OFFLINE_DEBUG: Error reading JSON file: $e");
      return [];
    }
  }

  Future<void> _writeData(List<Map<String, dynamic>> data) async {
    try {
      final file = await _localFile;
      await file.writeAsString(json.encode(data));
      print("OFFLINE_DEBUG: Written ${data.length} items to JSON file.");
    } catch (e) {
      print("OFFLINE_DEBUG: Error writing to JSON file: $e");
    }
  }

  // Compatible API with previous SQLite implementation
  Future<int> insertPelanggaran(Map<String, dynamic> row) async {
    try {
      final currentData = await _readData();
      
      // Generate a simple ID if not present (using timestamp for uniqueness)
      final newItem = Map<String, dynamic>.from(row);
      if (!newItem.containsKey('id')) {
        newItem['id'] = DateTime.now().millisecondsSinceEpoch;
      }
      // Ensure is_synced is 0
      newItem['is_synced'] = 0;

      currentData.add(newItem);
      await _writeData(currentData);
      
      print("OFFLINE_DEBUG: Inserted item into JSON list. Total items: ${currentData.length}");
      return newItem['id'] as int;
    } catch (e) {
      print("OFFLINE_DEBUG: Insert JSON FAILED: $e");
      throw e;
    }
  }

  Future<List<Map<String, dynamic>>> getUnsyncedPelanggaran() async {
    final data = await _readData();
    // Return all items effectively, or just those with is_synced=0 (which should be all of them)
    final unsynced = data.where((item) => (item['is_synced'] ?? 0) == 0).toList();
    print("OFFLINE_DEBUG: Loaded ${unsynced.length} unsynced items from JSON.");
    return unsynced;
  }

  // Instead of marking as synced, we now REMOVE it from the list
  // so it "disappears" from the offline storage.
  Future<int> markAsSynced(int id) async {
    try {
      final currentData = await _readData();
      final initialLength = currentData.length;
      
      // Remove the item with the given ID
      currentData.removeWhere((item) => item['id'] == id);
      
      if (currentData.length < initialLength) {
        await _writeData(currentData);
        print("OFFLINE_DEBUG: Removed item $id from JSON storage. Remaining: ${currentData.length}");
        return 1; // Success count
      } else {
         print("OFFLINE_DEBUG: Item $id not found in JSON storage to remove.");
         return 0; 
      }
    } catch (e) {
      print("OFFLINE_DEBUG: Error removing synced item: $e");
      return 0;
    }
  }

  Future<int> deletePelanggaran(int id) async {
    return await markAsSynced(id); // Same behavior
  }
}
