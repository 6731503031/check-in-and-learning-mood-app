import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../services/qr_payload_service.dart';
import '../../services/session_repository.dart';
import '../teacher_submissions/teacher_submissions_page.dart';

class TeacherQrPage extends StatefulWidget {
  const TeacherQrPage({super.key, this.repository});

  final SessionRepository? repository;

  @override
  State<TeacherQrPage> createState() => _TeacherQrPageState();
}

class _TeacherQrPageState extends State<TeacherQrPage> {
  final _classIdController = TextEditingController(text: 'CS101');
  String? _qrPayload;
  DateTime? _generatedAt;

  @override
  void dispose() {
    _classIdController.dispose();
    super.dispose();
  }

  void _generateQr() {
    final classId = _classIdController.text.trim();
    if (classId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter class ID first.')),
      );
      return;
    }

    setState(() {
      _qrPayload = buildTeacherCheckInQrPayload(classId: classId);
      _generatedAt = DateTime.now();
    });
  }

  void _openSubmissions() {
    final repository = widget.repository;
    if (repository == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Repository is unavailable.')),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeacherSubmissionsPage(
          repository: repository,
          initialClassId: _classIdController.text.trim(),
        ),
      ),
    );
  }

  Future<void> _copyPayload() async {
    final payload = _qrPayload;
    if (payload == null || payload.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: payload));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QR payload copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher: Generate Check-in QR')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Enter class ID to generate QR code for students to check in.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _classIdController,
              decoration: const InputDecoration(
                labelText: 'Class ID',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _generateQr(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _generateQr,
              icon: const Icon(Icons.qr_code_2),
              label: const Text('Generate QR Code'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _openSubmissions,
              icon: const Icon(Icons.list_alt),
              label: const Text('Student Submissions'),
            ),
            const SizedBox(height: 20),
            if (_qrPayload != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      QrImageView(
                        data: _qrPayload!,
                        version: QrVersions.auto,
                        size: 250,
                      ),
                      const SizedBox(height: 12),
                      SelectableText(
                        _qrPayload!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _generatedAt == null
                            ? ''
                            : 'Generated at: $_generatedAt\nExpires in 10 minutes',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _copyPayload,
                        icon: const Icon(Icons.copy),
                        label: const Text('Copy Payload'),
                      ),
                    ],
                  ),
                ),
              )
            else
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('QR code will appear here after generation.'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
