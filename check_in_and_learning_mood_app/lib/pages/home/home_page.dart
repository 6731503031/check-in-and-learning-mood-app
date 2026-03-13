import 'package:flutter/material.dart';

import '../../services/session_repository.dart';
import '../student_menu/student_menu_page.dart';
import '../teacher_qr/teacher_qr_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.repository,
    required this.usingFirestore,
  });

  final SessionRepository repository;
  final bool usingFirestore;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<void> _openStudentMenu() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StudentMenuPage(repository: widget.repository),
      ),
    );
  }

  Future<void> _openTeacherQrPage() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TeacherQrPage(repository: widget.repository),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check-in & Learning Mood')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              if (!widget.usingFirestore)
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.info_outline),
                    title: Text('Firebase is not configured.'),
                    subtitle: Text(
                      'The app is currently using local in-memory storage.',
                    ),
                  ),
                ),
              Expanded(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Choose your role',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.school_outlined),
                            title: const Text('Student'),
                            subtitle: const Text(
                              'Check-in, finish class and view history',
                            ),
                            trailing: ElevatedButton(
                              onPressed: _openStudentMenu,
                              child: const Text('Open'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.co_present),
                            title: const Text('Teacher'),
                            subtitle: const Text(
                              'Generate QR code from class ID',
                            ),
                            trailing: ElevatedButton(
                              onPressed: _openTeacherQrPage,
                              child: const Text('Open'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
