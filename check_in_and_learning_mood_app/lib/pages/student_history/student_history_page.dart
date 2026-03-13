import 'package:flutter/material.dart';

import '../../models/class_session.dart';
import '../../services/session_repository.dart';

class StudentHistoryPage extends StatefulWidget {
  const StudentHistoryPage({super.key, required this.repository});

  final SessionRepository repository;

  @override
  State<StudentHistoryPage> createState() => _StudentHistoryPageState();
}

class _StudentHistoryPageState extends State<StudentHistoryPage> {
  final _studentIdController = TextEditingController(text: 'S001');

  List<ClassSession> _sessions = <ClassSession>[];
  var _isLoading = false;

  @override
  void dispose() {
    _studentIdController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    final studentId = _studentIdController.text.trim();
    if (studentId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter student ID first.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final sessions = await widget.repository.getRecentSessions(
        studentId: studentId,
      );

      if (!mounted) {
        return;
      }

      setState(() => _sessions = sessions);
    } catch (error) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load history: $error')));
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student History')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _studentIdController,
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _loadHistory,
                icon: const Icon(Icons.search),
                label: const Text('Load History'),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _sessions.isEmpty
                    ? const Center(child: Text('No sessions found.'))
                    : ListView.separated(
                        itemCount: _sessions.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final session = _sessions[index];
                          return Card(
                            child: ListTile(
                              title: Text(
                                '${session.classId} • Mood ${session.moodScore}/5',
                              ),
                              subtitle: Text(
                                'Check-in: ${session.checkInTimestamp}\n'
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
