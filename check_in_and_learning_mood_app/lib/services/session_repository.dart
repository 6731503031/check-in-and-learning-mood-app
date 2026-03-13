import '../models/class_session.dart';

abstract class SessionRepository {
  Future<String> createCheckIn(CheckInPayload payload);

  Future<ClassSession?> getOpenSession({
    required String studentId,
    required String classId,
  });

  Future<void> finishClass({
    required String sessionId,
    required FinishClassPayload payload,
  });

  Future<List<ClassSession>> getRecentSessions({
    required String studentId,
    int limit = 10,
  });

  Future<List<ClassSession>> getSessionsByClass({
    required String classId,
    int limit = 100,
  });
}
