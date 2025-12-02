class ClassSchedule {
  final String id;
  final String subjectId;
  final int dayOfWeek;
  final String startTime;
  final String endTime;
  final String room;
  final String? fileToCheck;

  ClassSchedule({
    required this.id,
    required this.subjectId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.fileToCheck,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subjectId': subjectId,
      'dayOfWeek': dayOfWeek,
      'startTime': startTime,
      'endTime': endTime,
      'room': room,
      'fileToCheck': fileToCheck,
    };
  }

  factory ClassSchedule.fromJson(Map<String, dynamic> json) {
    return ClassSchedule(
      id: json['id'],
      subjectId: json['subjectId'],
      dayOfWeek: json['dayOfWeek'],
      startTime: json['startTime'],
      endTime: json['endTime'],
      room: json['room'] ?? '',
      fileToCheck: json['fileToCheck'],
    );
  }

  ClassSchedule copyWith({
    String? id,
    String? subjectId,
    int? dayOfWeek,
    String? startTime,
    String? endTime,
    String? room,
    String? fileToCheck,
  }) {
    return ClassSchedule(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      fileToCheck: fileToCheck ?? this.fileToCheck,
    );
  }
}