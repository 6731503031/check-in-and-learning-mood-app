class LocationPoint {
  const LocationPoint({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'latitude': latitude, 'longitude': longitude};
  }

  factory LocationPoint.fromMap(Map<String, dynamic> map) {
    return LocationPoint(
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0,
    );
  }
}

class CheckInPayload {
  const CheckInPayload({
    required this.studentId,
    required this.classId,
    required this.timestamp,
    required this.gpsLocation,
    required this.previousClassTopic,
    required this.expectedTopicToday,
    required this.moodScore,
    required this.qrCode,
  });

  final String studentId;
  final String classId;
  final DateTime timestamp;
  final LocationPoint gpsLocation;
  final String previousClassTopic;
  final String expectedTopicToday;
  final int moodScore;
  final String qrCode;
}

class FinishClassPayload {
  const FinishClassPayload({
    required this.timestamp,
    required this.gpsLocation,
    required this.learnedToday,
    required this.feedback,
    required this.qrCode,
  });

  final DateTime timestamp;
  final LocationPoint gpsLocation;
  final String learnedToday;
  final String feedback;
  final String qrCode;
}

class ClassSession {
  const ClassSession({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.checkInTimestamp,
    required this.checkInLocation,
    required this.previousClassTopic,
    required this.expectedTopicToday,
    required this.moodScore,
    required this.checkInQr,
    this.finishTimestamp,
    this.finishLocation,
    this.learnedToday,
    this.feedback,
    this.finishQr,
  });

  final String id;
  final String studentId;
  final String classId;
  final DateTime checkInTimestamp;
  final LocationPoint checkInLocation;
  final String previousClassTopic;
  final String expectedTopicToday;
  final int moodScore;
  final String checkInQr;
  final DateTime? finishTimestamp;
  final LocationPoint? finishLocation;
  final String? learnedToday;
  final String? feedback;
  final String? finishQr;

  bool get isFinished => finishTimestamp != null;

  ClassSession copyWith({
    DateTime? finishTimestamp,
    LocationPoint? finishLocation,
    String? learnedToday,
    String? feedback,
    String? finishQr,
  }) {
    return ClassSession(
      id: id,
      studentId: studentId,
      classId: classId,
      checkInTimestamp: checkInTimestamp,
      checkInLocation: checkInLocation,
      previousClassTopic: previousClassTopic,
      expectedTopicToday: expectedTopicToday,
      moodScore: moodScore,
      checkInQr: checkInQr,
      finishTimestamp: finishTimestamp ?? this.finishTimestamp,
      finishLocation: finishLocation ?? this.finishLocation,
      learnedToday: learnedToday ?? this.learnedToday,
      feedback: feedback ?? this.feedback,
      finishQr: finishQr ?? this.finishQr,
    );
  }

  factory ClassSession.fromMap(String id, Map<String, dynamic> map) {
    final checkInLocationMap =
        (map['check_in_gps_location'] as Map?)?.cast<String, dynamic>() ??
        <String, dynamic>{};
    final finishLocationMap = (map['finish_gps_location'] as Map?)
        ?.cast<String, dynamic>();

    return ClassSession(
      id: id,
      studentId: map['student_id'] as String? ?? '',
      classId: map['class_id'] as String? ?? '',
      checkInTimestamp: _asDateTime(map['check_in_timestamp']),
      checkInLocation: LocationPoint.fromMap(checkInLocationMap),
      previousClassTopic: map['previous_class_topic'] as String? ?? '',
      expectedTopicToday: map['expected_topic_today'] as String? ?? '',
      moodScore: map['mood_score'] as int? ?? 3,
      checkInQr: map['check_in_qr'] as String? ?? '',
      finishTimestamp: _asNullableDateTime(map['finish_timestamp']),
      finishLocation: finishLocationMap == null
          ? null
          : LocationPoint.fromMap(finishLocationMap),
      learnedToday: map['learned_today'] as String?,
      feedback: map['feedback'] as String?,
      finishQr: map['finish_qr'] as String?,
    );
  }
}

DateTime _asDateTime(dynamic value) {
  final date = _asNullableDateTime(value);
  return date ?? DateTime.fromMillisecondsSinceEpoch(0);
}

DateTime? _asNullableDateTime(dynamic value) {
  if (value == null) {
    return null;
  }

  if (value is DateTime) {
    return value;
  }

  if (value is String) {
    return DateTime.tryParse(value);
  }

  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value);
  }

  try {
    final dynamic maybeDate = value.toDate();
    if (maybeDate is DateTime) {
      return maybeDate;
    }
  } catch (_) {
    return null;
  }

  return null;
}
