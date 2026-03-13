import 'package:flutter/material.dart';

import '../../models/class_session.dart';
import '../../services/session_repository.dart';

class TeacherSubmissionsPage extends StatefulWidget {
  const TeacherSubmissionsPage({
    super.key,
    required this.repository,
    this.initialClassId,
  });

  final SessionRepository repository;
  final String? initialClassId;

  @override
  State<TeacherSubmissionsPage> createState() => _TeacherSubmissionsPageState();
}

class _TeacherSubmissionsPageState extends State<TeacherSubmissionsPage> {
  late final TextEditingController _classIdController;
  List<ClassSession> _sessions = <ClassSession>[];
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    _classIdController = TextEditingController(
      text: widget.initialClassId ?? 'CS101',
    );
  }

  @override
  void dispose() {
    _classIdController.dispose();
    super.dispose();
  }

  Future<void> _loadSubmissions() async {
    final classId = _classIdController.text.trim();
    if (classId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter class ID first.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final sessions = await widget.repository.getSessionsByClass(
        classId: classId,
      );

      if (!mounted) {
        return;
      }

      setState(() => _sessions = sessions);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load submissions: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teacher: Student Submissions')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _classIdController,
                decoration: const InputDecoration(
                  labelText: 'Class ID',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _loadSubmissions(),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _loadSubmissions,
                icon: const Icon(Icons.search),
                label: const Text('Load Submissions'),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _sessions.isEmpty
                    ? const Center(
                        child: Text('No student submissions found for class.'),
                      )
                    : ListView.separated(
                        itemCount: _sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          return Card(
                            child: ListTile(
                              leading: Icon(
                                session.isFinished
                                    ? Icons.check_circle
                                    : Icons.hourglass_top,
                                color: session.isFinished
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              title: Text('Student: ${session.studentId}'),
                              subtitle: Text(
                                'Check-in: ${session.checkInTimestamp}\n'
                                'Mood: ${session.moodScore}/5\n'
                                'Status: ${session.isFinished ? 'Finished' : 'Open'}',
                              ),
                              isThreeLine: true,
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
