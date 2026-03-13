import 'dart:convert';
import 'dart:html' as html;

class DatabaseService {
  DatabaseService._internal();

  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;

  static const String _storageKey = 'attendance_records';

  Future<void> saveCheckInRecord(Map<String, dynamic> record) async {
    final records = await getAllRecords();
    records.add(record.map((key, value) => MapEntry(key.toString(), value)));

    html.window.localStorage[_storageKey] = jsonEncode(records);
  }

  Future<List<Map<String, dynamic>>> getAllRecords() async {
    final raw = html.window.localStorage[_storageKey];
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
          .map(
            (item) => item.map((key, value) => MapEntry(key.toString(), value)),
          )
          .toList();
    } catch (_) {
      return <Map<String, dynamic>>[];
    }
  }
}
