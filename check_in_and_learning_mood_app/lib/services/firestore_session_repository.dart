import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/class_session.dart';
import 'session_repository.dart';

class FirestoreSessionRepository implements SessionRepository {
  FirestoreSessionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _sessions {
    return _firestore.collection('class_sessions');
  }

  @override
  Future<String> createCheckIn(CheckInPayload payload) async {
    final doc = await _sessions.add(<String, dynamic>{
      'student_id': payload.studentId,
      'class_id': payload.classId,
      'check_in_timestamp': payload.timestamp,
      'check_in_gps_location': payload.gpsLocation.toMap(),
      'previous_class_topic': payload.previousClassTopic,
      'expected_topic_today': payload.expectedTopicToday,
      'mood_score': payload.moodScore,
      'check_in_qr': payload.qrCode,
      'finish_timestamp': null,
      'finish_gps_location': null,
      'learned_today': null,
      'feedback': null,
      'finish_qr': null,
    });
    return doc.id;
  }

  @override
  Future<ClassSession?> getOpenSession({
    required String studentId,
    required String classId,
  }) async {
    final snapshot = await _sessions
        .where('student_id', isEqualTo: studentId)
        .limit(50)
        .get();

    final openSessions =
        snapshot.docs
            .map((doc) => ClassSession.fromMap(doc.id, doc.data()))
            .where(
              (session) =>
                  session.classId == classId && session.finishTimestamp == null,
            )
            .toList()
          ..sort((a, b) => b.checkInTimestamp.compareTo(a.checkInTimestamp));

    if (openSessions.isEmpty) {
      return null;
    }

    return openSessions.first;
  }

  @override
  Future<void> finishClass({
    required String sessionId,
    required FinishClassPayload payload,
  }) {
    return _sessions.doc(sessionId).update(<String, dynamic>{
      'finish_timestamp': payload.timestamp,
      'finish_gps_location': payload.gpsLocation.toMap(),
      'learned_today': payload.learnedToday,
      'feedback': payload.feedback,
      'finish_qr': payload.qrCode,
    });
  }

  @override
  Future<List<ClassSession>> getRecentSessions({
    required String studentId,
    int limit = 10,
  }) async {
    final snapshot = await _sessions
        .where('student_id', isEqualTo: studentId)
        .get();

    final sessions =
        snapshot.docs
            .map((doc) => ClassSession.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => b.checkInTimestamp.compareTo(a.checkInTimestamp));

    return sessions.take(limit).toList();
  }

  @override
  Future<List<ClassSession>> getSessionsByClass({
    required String classId,
    int limit = 100,
  }) async {
    final snapshot = await _sessions
        .where('class_id', isEqualTo: classId)
        .get();

    final sessions =
        snapshot.docs
            .map((doc) => ClassSession.fromMap(doc.id, doc.data()))
            .toList()
          ..sort((a, b) => b.checkInTimestamp.compareTo(a.checkInTimestamp));

    return sessions.take(limit).toList();
  }
}
