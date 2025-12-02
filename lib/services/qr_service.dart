import 'dart:convert';

class QRService {
  static String generateClassQR({
    required String classId,
    required String subjectId,
    required DateTime date,
    String? location,
  }) {
    final data = {
      'classId': classId,
      'subjectId': subjectId,
      'date': date.toIso8601String(),
      'location': location,
    };
    return json.encode(data);
  }

  static Map<String, dynamic>? validateQR(String qrData) {
    try {
      return json.decode(qrData) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}