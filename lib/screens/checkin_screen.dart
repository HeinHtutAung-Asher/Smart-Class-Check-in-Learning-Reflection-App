import 'package:flutter/material.dart';

import '../services/database_service.dart';
import 'qr_scanner_screen.dart';
import '../services/location_service.dart';

class CheckinScreen extends StatefulWidget {
  const CheckinScreen({super.key});

  @override
  State<CheckinScreen> createState() => _CheckinScreenState();
}

class _CheckinScreenState extends State<CheckinScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _previousTopicController =
      TextEditingController();
  final TextEditingController _expectedTopicController =
      TextEditingController();
  final LocationService _locationService = LocationService();
  final DatabaseService _databaseService = DatabaseService();
  String studentId = '';
  int? _selectedMood;
  String? scannedQrValue;
  double? latitude;
  double? longitude;

  bool get _isQrScanned =>
      scannedQrValue != null && scannedQrValue!.trim().isNotEmpty;
  bool get _isLocationCaptured => latitude != null && longitude != null;

  void _showSnackMessage(String message, {Duration? duration}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: duration ?? const Duration(seconds: 4),
        ),
      );
  }

  String _formatTimestamp(DateTime time) {
    final month = time.month.toString().padLeft(2, '0');
    final day = time.day.toString().padLeft(2, '0');
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '${time.year}-$month-$day $hour:$minute';
  }

  String? _selectedMoodDescription() {
    switch (_selectedMood) {
      case 1:
        return 'Very negative';
      case 2:
        return 'Negativet';
      case 3:
        return 'Neutral';
      case 4:
        return 'Positive';
      case 5:
        return 'Very positive';
      default:
        return null;
    }
  }

  Future<void> _scanQrCode() async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const QRScannerScreen()));

    if (result == null || result.isEmpty) {
      return;
    }

    setState(() {
      scannedQrValue = result;
    });

    _showSnackMessage('QR code verified.');
  }

  Future<void> _captureLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (!mounted) {
        return;
      }

      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      _showSnackMessage('Location captured successfully.');
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString().replaceFirst('Exception: ', '');
      _showSnackMessage(message);
    }
  }

  Future<void> _submitCheckIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    if (_selectedMood == null) {
      _showSnackMessage('Please select your mood before submitting.');
      return;
    }

    final qrValue = scannedQrValue?.trim();
    if (qrValue == null || qrValue.isEmpty) {
      _showSnackMessage('Please scan the classroom QR code before submitting.');
      return;
    }

    if (!_isLocationCaptured) {
      _showSnackMessage(
        'Location not captured. Please enable GPS and try again.',
      );
      return;
    }

    studentId = _studentIdController.text.trim();

    final now = DateTime.now();
    final checkInTime = _formatTimestamp(now);
    final sessionDate = checkInTime.substring(0, 10);

    final Map<String, dynamic> payload = {
      'recordId': now.microsecondsSinceEpoch.toString(),
      'studentId': studentId,
      'sessionDate': sessionDate,
      'checkInTime': checkInTime,
      'checkInLatitude': latitude,
      'checkInLongitude': longitude,
      'checkInQrValue': qrValue,
      'previousTopic': _previousTopicController.text.trim(),
      'expectedTopic': _expectedTopicController.text.trim(),
      'moodScore': _selectedMood,
      'finishTime': null,
      'finishLatitude': null,
      'finishLongitude': null,
      'finishQrValue': null,
      'learnedToday': null,
      'feedback': null,
    };

    try {
      await _databaseService.saveCheckInRecord(payload);
      if (!mounted) {
        return;
      }

      _showSnackMessage(
        'Check-in submitted successfully',
        duration: const Duration(seconds: 1),
      );

      await Future<void>.delayed(const Duration(seconds: 1));
      if (!mounted) {
        return;
      }

      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showSnackMessage('Failed to save check-in: $error');
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }

  Widget _buildMoodOption({required int value, required String emoji}) {
    final isSelected = _selectedMood == value;

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() {
              _selectedMood = value;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE0EAFF) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFD6DDE8),
                width: isSelected ? 1.6 : 1,
              ),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 22)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Class Check-in')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Check-in Form',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Student Information',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _studentIdController,
                            decoration: const InputDecoration(
                              labelText: 'Student ID',
                              hintText: 'Enter your student ID',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'QR Scan',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildActionButton(
                            label: 'Scan QR Code',
                            color: const Color(0xFF0F766E),
                            onPressed: _scanQrCode,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'QR Status: ${_isQrScanned ? 'Scanned' : 'Not scanned'}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF475569)),
                          ),
                          if (scannedQrValue != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'QR Code: $scannedQrValue',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Location Verification',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildActionButton(
                            label: 'Get GPS Location',
                            color: const Color(0xFF4F46E5),
                            onPressed: _captureLocation,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Location Status: ${_isLocationCaptured ? 'Captured' : 'Not captured'}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: const Color(0xFF475569)),
                          ),
                          if (latitude != null && longitude != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Location Captured',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text('Latitude: ${latitude!.toStringAsFixed(6)}'),
                            Text('Longitude: ${longitude!.toStringAsFixed(6)}'),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pre-Class Reflection',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _previousTopicController,
                            decoration: const InputDecoration(
                              labelText: 'Previous class topic',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _expectedTopicController,
                            decoration: const InputDecoration(
                              labelText: 'Expected topic for today',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'This field is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'How do you feel before class?',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildMoodOption(value: 1, emoji: '😡'),
                              _buildMoodOption(value: 2, emoji: '😕'),
                              _buildMoodOption(value: 3, emoji: '😐'),
                              _buildMoodOption(value: 4, emoji: '🙂'),
                              _buildMoodOption(value: 5, emoji: '😄'),
                            ],
                          ),
                          if (_selectedMoodDescription() != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              _selectedMoodDescription()!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF64748B)),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildActionButton(
                    label: 'Submit Check-in',
                    color: const Color(0xFF2563EB),
                    onPressed: () async {
                      // This captures current form snapshot and saves it to local storage.
                      await _submitCheckIn();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
