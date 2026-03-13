import 'package:flutter/material.dart';

import '../../models/class_session.dart';
import '../../services/location_service.dart';
import '../../services/qr_payload_service.dart';
import '../../services/session_repository.dart';
import '../qr_scanner/qr_scanner_page.dart';

class CheckInPage extends StatefulWidget {
  const CheckInPage({
    super.key,
    required this.repository,
    this.initialStudentId,
  });

  final SessionRepository repository;
  final String? initialStudentId;

  @override
  State<CheckInPage> createState() => _CheckInPageState();
}

class _CheckInPageState extends State<CheckInPage> {
  final _formKey = GlobalKey<FormState>();
  final _previousTopicController = TextEditingController();
  final _expectedTopicController = TextEditingController();
  final _locationService = LocationService();

  late final TextEditingController _studentIdController;

  double _moodScore = 3;
  String? _qrCode;
  String? _classIdFromQr;
  var _submitting = false;

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
    _previousTopicController.dispose();
    _expectedTopicController.dispose();
    super.dispose();
  }

  int get _moodScoreInt => _moodScore.round();

  String _moodEmoji(int score) {
    switch (score) {
      case 1:
        return '😞';
      case 2:
        return '🙁';
      case 3:
        return '😐';
      case 4:
        return '🙂';
      case 5:
        return '😄';
      default:
        return '😐';
    }
  }

  String _moodLabel(int score) {
    switch (score) {
      case 1:
        return 'Very negative';
      case 2:
        return 'Negative';
      case 3:
        return 'Neutral';
      case 4:
        return 'Positive';
      case 5:
        return 'Very positive';
      default:
        return 'Neutral';
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
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
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
      final payload = CheckInPayload(
        studentId: _studentIdController.text.trim(),
        classId: _classIdFromQr!,
        timestamp: DateTime.now(),
        gpsLocation: location,
        previousClassTopic: _previousTopicController.text.trim(),
        expectedTopicToday: _expectedTopicController.text.trim(),
        moodScore: _moodScoreInt,
        qrCode: _qrCode!,
      );

      final sessionId = await widget.repository.createCheckIn(payload);

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check-in completed. Session: $sessionId')),
      );
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to check-in: $error')));
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final moodScore = _moodScoreInt;

    return Scaffold(
      appBar: AppBar(title: const Text('Class Check-in')),
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
              const SizedBox(height: 12),
              TextFormField(
                controller: _previousTopicController,
                decoration: const InputDecoration(
                  labelText: 'Previous class topic',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter previous class topic';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _expectedTopicController,
                decoration: const InputDecoration(
                  labelText: 'Expected topic today',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter expected topic';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mood before class',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            _moodEmoji(moodScore),
                            style: const TextStyle(fontSize: 28),
                          ),
                          const SizedBox(width: 10),
                          Text('$moodScore/5 - ${_moodLabel(moodScore)}'),
                        ],
                      ),
                      Slider(
                        value: _moodScore,
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '$moodScore',
                        onChanged: (value) {
                          setState(() => _moodScore = value);
                        },
                      ),
                    ],
                  ),
                ),
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
                label: const Text('Submit Check-in'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
