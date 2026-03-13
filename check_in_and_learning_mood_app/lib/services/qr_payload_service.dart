import 'dart:convert';

const Duration kTeacherQrTtl = Duration(minutes: 10);

class ParsedClassQrPayload {
  const ParsedClassQrPayload({required this.classId, this.issuedAt});

  final String classId;
  final DateTime? issuedAt;

  bool get hasIssuedAt => issuedAt != null;

  bool get isExpired {
    final issued = issuedAt;
    if (issued == null) {
      return false;
    }
    return DateTime.now().isAfter(issued.add(kTeacherQrTtl));
  }
}

String buildTeacherCheckInQrPayload({required String classId}) {
  return jsonEncode(<String, String>{
    'type': 'class_checkin',
    'class_id': classId.trim(),
    'issued_at': DateTime.now().toIso8601String(),
  });
}

ParsedClassQrPayload? tryParseClassQrPayload(String rawQr) {
  final raw = rawQr.trim();
  if (raw.isEmpty) {
    return null;
  }

  try {
    final decoded = jsonDecode(raw);
    if (decoded is Map<String, dynamic>) {
      final classId = decoded['class_id'];
      if (classId is String && classId.trim().isNotEmpty) {
        final issuedAtRaw = decoded['issued_at'];
        DateTime? issuedAt;
        if (issuedAtRaw is String) {
          issuedAt = DateTime.tryParse(issuedAtRaw);
        }
        return ParsedClassQrPayload(
          classId: classId.trim(),
          issuedAt: issuedAt,
        );
      }
    }
  } catch (_) {
    // Keep backward compatibility: plain text QR is allowed.
  }

  return ParsedClassQrPayload(classId: raw);
}

String? tryExtractClassIdFromQr(String rawQr) {
  return tryParseClassQrPayload(rawQr)?.classId;
}
