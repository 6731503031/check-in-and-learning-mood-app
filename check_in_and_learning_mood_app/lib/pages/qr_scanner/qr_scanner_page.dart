import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../services/qr_image_decoder.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final _controller = MobileScannerController();
  final _manualController = TextEditingController();
  var _hasPopped = false;
  var _isDecodingImage = false;

  Future<void> _retryCamera() async {
    try {
      await _controller.start();
    } catch (_) {
      // MobileScanner error UI is rendered by errorBuilder.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _manualController.dispose();
    super.dispose();
  }

  void _returnCode(String code) {
    if (_hasPopped || code.trim().isEmpty) {
      return;
    }
    _hasPopped = true;
    Navigator.of(context).pop(code.trim());
  }

  void _onDetect(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      final code = barcode.rawValue;
      if (code != null && code.isNotEmpty) {
        _returnCode(code);
        return;
      }
    }
  }

  Future<void> _pickQrFromImage() async {
    setState(() => _isDecodingImage = true);
    try {
      final code = await pickAndDecodeQrFromImage();
      if (!mounted || code == null || code.isEmpty) {
        return;
      }

      _manualController.text = code;
      _returnCode(code);
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot decode QR from image: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isDecodingImage = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  controller: _controller,
                  onDetect: _onDetect,
                  errorBuilder: (context, error, child) {
                    return Container(
                      color: Colors.black12,
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 520),
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.videocam_off,
                                    size: 40,
                                    color: Colors.redAccent,
                                  ),
                                  const SizedBox(height: 10),
                                  const Text(
                                    'Cannot access camera',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text('$error', textAlign: TextAlign.center),
                                  const SizedBox(height: 12),
                                  if (kIsWeb)
                                    const Text(
                                      'For web scanner support, allow camera access and keep the ZXing script loaded in web/index.html.',
                                      textAlign: TextAlign.center,
                                    ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    alignment: WrapAlignment.center,
                                    children: [
                                      OutlinedButton.icon(
                                        onPressed: _retryCamera,
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Try camera again'),
                                      ),
                                      if (kIsWeb)
                                        OutlinedButton.icon(
                                          onPressed: _isDecodingImage
                                              ? null
                                              : _pickQrFromImage,
                                          icon: _isDecodingImage
                                              ? const SizedBox(
                                                  width: 14,
                                                  height: 14,
                                                  child:
                                                      CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                )
                                              : const Icon(Icons.upload_file),
                                          label: const Text('Upload QR image'),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'You can still continue using manual QR code input below.',
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        child: Text(
                          kIsWeb
                              ? 'Point camera at QR code or use upload/manual input'
                              : 'Point camera at the classroom QR code',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Manual entry – especially useful on web / desktop
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  kIsWeb
                      ? 'Or type / paste the QR code value'
                      : 'Or enter QR code manually:',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _manualController,
                        autofocus: kIsWeb,
                        decoration: const InputDecoration(
                          hintText: 'e.g. CLASS-CS101-2026',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: _returnCode,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (kIsWeb) ...[
                      OutlinedButton.icon(
                        onPressed: _isDecodingImage ? null : _pickQrFromImage,
                        icon: const Icon(Icons.image),
                        label: const Text('Image'),
                      ),
                      const SizedBox(width: 8),
                    ],
                    ElevatedButton(
                      onPressed: () => _returnCode(_manualController.text),
                      child: const Text('Confirm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
