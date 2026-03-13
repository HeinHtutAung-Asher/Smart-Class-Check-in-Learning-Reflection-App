import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  bool _hasScanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              onDetect: (capture) {
                if (_hasScanned) {
                  return;
                }

                String? scannedValue;
                for (final barcode in capture.barcodes) {
                  final value = barcode.rawValue;
                  if (value != null && value.isNotEmpty) {
                    scannedValue = value;
                    break;
                  }
                }

                if (scannedValue == null || scannedValue.isEmpty) {
                  return;
                }

                _hasScanned = true;
                Navigator.pop(context, scannedValue);
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Align the QR code within the frame',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
