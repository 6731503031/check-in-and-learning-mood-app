import 'package:flutter/material.dart';

import 'pages/home/home_page.dart';
import 'services/session_repository.dart';

class CheckInMoodApp extends StatelessWidget {
  const CheckInMoodApp({
    super.key,
    required this.repository,
    required this.usingFirestore,
  });

  final SessionRepository repository;
  final bool usingFirestore;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Check-in & Learning Mood',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: HomePage(repository: repository, usingFirestore: usingFirestore),
    );
  }
}
