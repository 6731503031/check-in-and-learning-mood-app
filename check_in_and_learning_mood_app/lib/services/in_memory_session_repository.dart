import '../models/class_session.dart';
import 'session_repository.dart';

class InMemorySessionRepository implements SessionRepository {
  final Map<String, ClassSession> _sessions = <String, ClassSession>{};
  var _counter = 0;

  @override
  Future<String> createCheckIn(CheckInPayload payload) async {
    _counter++;
    final id = 'session_$_counter';

    _sessions[id] = ClassSession(
      id: id,
      studentId: payload.studentId,
      classId: payload.classId,
      checkInTimestamp: payload.timestamp,
      checkInLocation: payload.gpsLocation,
      previousClassTopic: payload.previousClassTopic,
      expectedTopicToday: payload.expectedTopicToday,
      moodScore: payload.moodScore,
      checkInQr: payload.qrCode,
    );

    return id;
  }

  @override
  Future<ClassSession?> getOpenSession({
    required String studentId,
    required String classId,
  }) async {
    final openSessions =
        _sessions.values
            .where(
              (session) =>
                  session.studentId == studentId &&
                  session.classId == classId &&
                  !session.isFinished,
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
  }) async {
    final session = _sessions[sessionId];
    if (session == null) {
      throw StateError('Session not found');
    }

    _sessions[sessionId] = session.copyWith(
      finishTimestamp: payload.timestamp,
      finishLocation: payload.gpsLocation,
      learnedToday: payload.learnedToday,
      feedback: payload.feedback,
      finishQr: payload.qrCode,
    );
  }

  @override
  Future<List<ClassSession>> getRecentSessions({
    required String studentId,
    int limit = 10,
  }) async {
    final sessions =
        _sessions.values
            .where((session) => session.studentId == studentId)
            .toList()
          ..sort((a, b) => b.checkInTimestamp.compareTo(a.checkInTimestamp));

    return sessions.take(limit).toList();
  }

  @override
  Future<List<ClassSession>> getSessionsByClass({
    required String classId,
    int limit = 100,
  }) async {
    final sessions =
        _sessions.values.where((session) => session.classId == classId).toList()
          ..sort((a, b) => b.checkInTimestamp.compareTo(a.checkInTimestamp));

    return sessions.take(limit).toList();
  }
}
