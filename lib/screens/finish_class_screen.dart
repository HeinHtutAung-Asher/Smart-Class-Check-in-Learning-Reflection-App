import 'package:flutter/material.dart';

import '../services/database_service.dart';
import '../services/location_service.dart';
import 'qr_scanner_screen.dart';

class FinishClassScreen extends StatefulWidget {
  const FinishClassScreen({super.key});

  @override
  State<FinishClassScreen> createState() => _FinishClassScreenState();
}

class _FinishClassScreenState extends State<FinishClassScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _studentIdController = TextEditingController();
  final TextEditingController _learningController = TextEditingController();
  final TextEditingController _feedbackController = TextEditingController();
  final LocationService _locationService = LocationService();
  final DatabaseService _databaseService = DatabaseService();
  String studentId = '';
  String? finishQrValue;
  double? finishLatitude;
  double? finishLongitude;

  bool get _isQrScanned =>
      finishQrValue != null && finishQrValue!.trim().isNotEmpty;
  bool get _isLocationCaptured =>
      finishLatitude != null && finishLongitude != null;

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

  Future<void> _scanQrCode() async {
    final result = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const QRScannerScreen()));

    if (result == null || result.isEmpty) {
      return;
    }

    setState(() {
      finishQrValue = result;
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
        finishLatitude = position.latitude;
        finishLongitude = position.longitude;
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

  Future<void> _submitFinishClass() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final qrValue = finishQrValue?.trim();
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
    final finishTime = _formatTimestamp(now);
    final sessionDate = finishTime.substring(0, 10);

    // MVP approach: append a finish-class record in local storage.
    final Map<String, dynamic> payload = {
      'recordId': now.microsecondsSinceEpoch.toString(),
      'studentId': studentId,
      'sessionDate': sessionDate,
      'checkInTime': null,
      'checkInLatitude': null,
      'checkInLongitude': null,
      'checkInQrValue': null,
      'previousTopic': null,
      'expectedTopic': null,
      'moodScore': null,
      'finishTime': finishTime,
      'finishLatitude': finishLatitude,
      'finishLongitude': finishLongitude,
      'finishQrValue': qrValue,
      'learnedToday': _learningController.text.trim(),
      'feedback': _feedbackController.text.trim(),
    };

    try {
      await _databaseService.saveCheckInRecord(payload);
      if (!mounted) {
        return;
      }

      _showSnackMessage(
        'Class completion submitted successfully',
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

      _showSnackMessage('Failed to save finish class: $error');
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _learningController.dispose();
    _feedbackController.dispose();
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
                    'Finish Class Form',
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
                          if (finishQrValue != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'QR Code: $finishQrValue',
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
                          if (finishLatitude != null &&
                              finishLongitude != null) ...[
                            const SizedBox(height: 12),
                            Text(
                              'Location Captured',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Latitude: ${finishLatitude!.toStringAsFixed(6)}',
                            ),
                            Text(
                              'Longitude: ${finishLongitude!.toStringAsFixed(6)}',
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Class Reflection',
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
                            controller: _learningController,
                            decoration: const InputDecoration(
                              labelText: 'What did you learn today?',
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
                            controller: _feedbackController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Feedback about the class',
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
                  _buildActionButton(
                    label: 'Finish Class',
                    color: const Color(0xFF16A34A),
                    onPressed: () async {
                      // TODO: In a later phase, connect this flow to sync/cloud storage.
                      await _submitFinishClass();
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
