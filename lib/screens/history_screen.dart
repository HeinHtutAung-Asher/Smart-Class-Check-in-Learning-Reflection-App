import 'package:flutter/material.dart';

import '../services/database_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final DatabaseService _databaseService = DatabaseService();
  late Future<List<Map<String, dynamic>>> _recordsFuture;

  @override
  void initState() {
    super.initState();
    _recordsFuture = _databaseService.getAllRecords();
  }

  String? _moodEmoji(dynamic moodScore) {
    switch (moodScore) {
      case 1:
        return '😡';
      case 2:
        return '😕';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return null;
    }
  }

  bool _hasValue(dynamic value) {
    if (value == null) {
      return false;
    }

    final text = value.toString().trim();
    return text.isNotEmpty && text != '-';
  }

  String? _textValue(dynamic value) {
    if (!_hasValue(value)) {
      return null;
    }

    return value.toString().trim();
  }

  String? _coordinateValue(dynamic value) {
    if (!_hasValue(value)) {
      return null;
    }

    if (value is num) {
      return value.toDouble().toStringAsFixed(4);
    }

    final parsed = double.tryParse(value.toString());
    return parsed?.toStringAsFixed(4);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Attendance History')),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _recordsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Failed to load records: ${snapshot.error}'),
            );
          }

          final records = snapshot.data ?? <Map<String, dynamic>>[];
          if (records.isEmpty) {
            return const Center(child: Text('No attendance records yet.'));
          }

          final reversedRecords = records.reversed.toList();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reversedRecords.length,
            itemBuilder: (context, index) {
              final record = reversedRecords[index];
              final isCheckInRecord = _hasValue(record['checkInTime']);
              final isFinishRecord =
                  !isCheckInRecord && _hasValue(record['finishTime']);

              if (!isCheckInRecord && !isFinishRecord) {
                return const SizedBox.shrink();
              }

              final studentId = _textValue(record['studentId']);
              final sessionDate = _textValue(record['sessionDate']);
              final checkInTime = _textValue(record['checkInTime']);
              final finishTime = _textValue(record['finishTime']);
              final checkInLat = _coordinateValue(record['checkInLatitude']);
              final checkInLng = _coordinateValue(record['checkInLongitude']);
              final finishLat = _coordinateValue(record['finishLatitude']);
              final finishLng = _coordinateValue(record['finishLongitude']);
              final previousTopic = _textValue(record['previousTopic']);
              final expectedTopic = _textValue(record['expectedTopic']);
              final learnedToday = _textValue(record['learnedToday']);
              final feedback = _textValue(record['feedback']);
              final mood = _moodEmoji(record['moodScore']);

              final accentColor = isCheckInRecord
                  ? const Color(0xFF2563EB)
                  : const Color(0xFF16A34A);
              final title = isCheckInRecord
                  ? 'Check-in Record'
                  : 'Finish Class Record';
              final icon = isCheckInRecord ? Icons.login : Icons.check_circle;
              final secondaryStyle = Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: const Color(0xFF64748B));

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(icon, color: accentColor, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: accentColor,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (studentId != null) Text('Student ID: $studentId'),
                      if (sessionDate != null)
                        Text('Session Date: $sessionDate'),

                      const SizedBox(height: 8),
                      if (isCheckInRecord) ...[
                        if (checkInTime != null)
                          Text('Check-in Time: $checkInTime'),
                        const SizedBox(height: 8),
                        if (checkInLat != null || checkInLng != null)
                          Text('Location (Check-in)', style: secondaryStyle),
                        if (checkInLat != null)
                          Text('Lat: $checkInLat', style: secondaryStyle),
                        if (checkInLng != null)
                          Text('Lng: $checkInLng', style: secondaryStyle),
                        const SizedBox(height: 8),
                        if (previousTopic != null)
                          Text('Previous Topic: $previousTopic'),
                        if (expectedTopic != null)
                          Text('Expected Topic: $expectedTopic'),
                        if (mood != null) ...[
                          const SizedBox(height: 8),
                          Text('Mood Before Class: $mood'),
                        ],
                      ] else if (isFinishRecord) ...[
                        if (finishTime != null)
                          Text('Finish Time: $finishTime'),
                        const SizedBox(height: 8),
                        if (finishLat != null || finishLng != null)
                          Text('Location (Finish)', style: secondaryStyle),
                        if (finishLat != null)
                          Text('Lat: $finishLat', style: secondaryStyle),
                        if (finishLng != null)
                          Text('Lng: $finishLng', style: secondaryStyle),
                        const SizedBox(height: 8),
                        if (learnedToday != null)
                          Text('Learned Today: $learnedToday'),
                        if (feedback != null) Text('Feedback: $feedback'),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
