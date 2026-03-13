import 'package:flutter/material.dart';

import '../../services/session_repository.dart';
import '../check_in/check_in_page.dart';
import '../finish_class/finish_class_page.dart';
import '../student_history/student_history_page.dart';

class StudentMenuPage extends StatelessWidget {
  const StudentMenuPage({super.key, required this.repository});

  final SessionRepository repository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Menu')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CheckInPage(repository: repository),
                    ),
                  );
                },
                icon: const Icon(Icons.login),
                label: const Text('Check In'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => FinishClassPage(repository: repository),
                    ),
                  );
                },
                icon: const Icon(Icons.task_alt),
                label: const Text('Finish'),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          StudentHistoryPage(repository: repository),
                    ),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('History'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
