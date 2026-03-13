import 'package:flutter/material.dart';

import '../../models/class_session.dart';
import '../../services/location_service.dart';
import '../../services/qr_payload_service.dart';
import '../../services/session_repository.dart';
import '../qr_scanner/qr_scanner_page.dart';

class FinishClassPage extends StatefulWidget {
  const FinishClassPage({
    super.key,
    required this.repository,
    this.initialStudentId,
  });

  final SessionRepository repository;
  final String? initialStudentId;

  @override
  State<FinishClassPage> createState() => _FinishClassPageState();
}

class _FinishClassPageState extends State<FinishClassPage> {
  final _formKey = GlobalKey<FormState>();
  final _learnedTodayController = TextEditingController();
  final _feedbackController = TextEditingController();
  final _locationService = LocationService();

  late final TextEditingController _studentIdController;

  ClassSession? _openSession;
  var _loadingSession = false;
  var _submitting = false;
  String? _qrCode;
  String? _classIdFromQr;

  @override
  void initState() {
    super.initState();
    _studentIdController = TextEditingController(
      text: widget.initialStudentId ?? 'S001',
    );
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _learnedTodayController.dispose();
    _feedbackController.dispose();
    super.dispose();
  }

  Future<void> _loadOpenSession() async {
    final studentId = _studentIdController.text.trim();
    final classId = _classIdFromQr;

    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter student ID first.')),
      );
      return;
    }

    if (classId == null || classId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan classroom QR code first.')),
      );
      return;
    }

    setState(() => _loadingSession = true);

    try {
      final session = await widget.repository.getOpenSession(
        studentId: studentId,
        classId: classId,
      );

      if (!mounted) {
        return;
      }

      setState(() => _openSession = session);

      if (session == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No open check-in session found for this student.'),
          ),
        );
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load open session: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _loadingSession = false);
      }
    }
  }

  Future<void> _scanQrCode() async {
    final code = await Navigator.of(
      context,
    ).push<String>(MaterialPageRoute(builder: (_) => const QrScannerPage()));

    if (code == null || !mounted) {
      return;
    }

    final parsed = tryParseClassQrPayload(code);
    if (parsed == null || parsed.classId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid QR code. Please scan teacher generated QR.'),
        ),
      );
      return;
    }

    if (parsed.hasIssuedAt && parsed.isExpired) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code has expired (more than 10 minutes).'),
        ),
      );
      return;
    }

    setState(() {
      _qrCode = code;
      _classIdFromQr = parsed.classId;
      _openSession = null;
    });

    await _loadOpenSession();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_openSession == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No open session to finish.')),
      );
      return;
    }

    if (_qrCode == null || _qrCode!.isEmpty || _classIdFromQr == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please scan classroom QR code first.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final location = await _locationService.getCurrentLocation();
      final payload = FinishClassPayload(
        timestamp: DateTime.now(),
        gpsLocation: location,
        learnedToday: _learnedTodayController.text.trim(),
        feedback: _feedbackController.text.trim(),
        qrCode: _qrCode!,
      );

      await widget.repository.finishClass(
        sessionId: _openSession!.id,
        payload: payload,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Class completion submitted.')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit finish class: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Finish Class')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              TextFormField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter student ID';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: Icon(
                    _qrCode == null ? Icons.qr_code : Icons.check_circle,
                    color: _qrCode == null ? null : Colors.green,
                  ),
                  title: const Text('Classroom QR code'),
                  subtitle: Text(
                    _classIdFromQr == null
                        ? 'Not scanned yet'
                        : 'Class ID from QR: $_classIdFromQr',
                  ),
                  trailing: OutlinedButton(
                    onPressed: _scanQrCode,
                    child: Text(_qrCode == null ? 'Scan' : 'Rescan'),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _loadingSession ? null : _loadOpenSession,
                icon: _loadingSession
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.search),
                label: const Text('Find Open Session'),
              ),
              const SizedBox(height: 12),
              if (_openSession != null)
                Card(
                  child: ListTile(
                    title: const Text('Open session found'),
                    subtitle: Text(
                      'Class: ${_openSession!.classId}\n'
                      'Check-in time: ${_openSession!.checkInTimestamp}\n'
                      'Mood score: ${_openSession!.moodScore}/5',
                    ),
                    isThreeLine: true,
                  ),
                )
              else
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('No open session loaded yet.'),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _learnedTodayController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'What did you learn today?',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please write what you learned today';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _feedbackController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Feedback about class or instructor',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please provide your feedback';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _submitting ? null : _submit,
                icon: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: const Text('Submit Class Completion'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
