import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_options.dart';
import 'services/firestore_session_repository.dart';
import 'services/in_memory_session_repository.dart';
import 'services/session_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SessionRepository repository;
  var usingFirestore = false;

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    repository = FirestoreSessionRepository();
    usingFirestore = true;
  } catch (_) {
    repository = InMemorySessionRepository();
  }

  runApp(
    CheckInMoodApp(repository: repository, usingFirestore: usingFirestore),
  );
}
