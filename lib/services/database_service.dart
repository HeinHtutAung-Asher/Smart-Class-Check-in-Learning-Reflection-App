import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  static const String _storageKey = 'attendance_records';

  Future<SharedPreferences> get _preferences async {
    return SharedPreferences.getInstance();
  }

  Future<void> saveCheckInRecord(Map<String, dynamic> record) async {
    final preferences = await _preferences;
    final records = await getAllRecords();
    records.add(record.map((key, value) => MapEntry(key.toString(), value)));

    await preferences.setString(_storageKey, jsonEncode(records));
  }

  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final preferences = await _preferences;
    final raw = preferences.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      return <Map<String, dynamic>>[];
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <Map<String, dynamic>>[];
      }

      return decoded
          .whereType<Map>()
          .map((item) => _normalizeRecord(item))
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }

  Map<String, dynamic> _normalizeRecord(Map<dynamic, dynamic> item) {
    return item.map((key, value) => MapEntry(key.toString(), value));
  }
}
