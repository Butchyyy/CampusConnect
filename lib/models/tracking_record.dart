

class AttendanceRecord {
  final String id;
  final DateTime date;
  final String subjectId;
  final bool present;
  final bool late;
  final String? notes;
  final DateTime? checkInTime;

  AttendanceRecord({
    required this.id,
    required this.date,
    required this.subjectId,
    required this.present,
    this.late = false,
    this.notes,
    this.checkInTime,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'subjectId': subjectId,
      'present': present,
      'late': late,
      'notes': notes,
      'checkInTime': checkInTime?.toIso8601String(),
    };
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'],
      date: DateTime.parse(json['date']),
      subjectId: json['subjectId'],
      present: json['present'],
      late: json['late'] ?? false,
      notes: json['notes'],
      checkInTime: json['checkInTime'] != null
          ? DateTime.parse(json['checkInTime'])
          : null,
    );
  }

  AttendanceRecord copyWith({
    String? id,
    DateTime? date,
    String? subjectId,
    bool? present,
    bool? late,
    String? notes,
    DateTime? checkInTime,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      subjectId: subjectId ?? this.subjectId,
      present: present ?? this.present,
      late: late ?? this.late,
      notes: notes ?? this.notes,
      checkInTime: checkInTime ?? this.checkInTime,
    );
  }
}