import 'package:flutter/material.dart';

import 'checkin_screen.dart';
import 'finish_class_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart Class Check-in')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                _FeatureCard(
                  title: 'Check-in to Class',
                  description: 'Verify your attendance using QR code and GPS.',
                  buttonLabel: 'Start Check-in',
                  buttonColor: const Color(0xFF2563EB),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const CheckinScreen()),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  title: 'Finish Class',
                  description:
                      'Submit your learning reflection after the class ends.',
                  buttonLabel: 'Finish Class',
                  buttonColor: const Color(0xFF16A34A),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const FinishClassScreen(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                _FeatureCard(
                  title: 'Attendance History',
                  description:
                      'Review your submitted check-in and reflection records.',
                  buttonLabel: 'View Attendance History',
                  buttonColor: const Color(0xFF2563EB),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const HistoryScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onPressed,
  });

  final String title;
  final String description;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                height: 1.4,
                color: const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: onPressed,
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
