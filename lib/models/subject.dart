import 'package:flutter/material.dart';

class Subject {
  final String id;
  final String name;
  final String code;
  final String instructor;
  final int credits;
  final Color color;
  final int? totalClasses;
  final int? attendedClasses;

  Subject({
    required this.id,
    required this.name,
    required this.code,
    this.instructor = '',
    this.credits = 3,
    required this.color,
    this.totalClasses,
    this.attendedClasses,
  });

  // Add this getter
  double get attendanceRate {
    if (totalClasses == null || totalClasses == 0) return 0.0;
    return (attendedClasses ?? 0) / totalClasses! * 100;
  }

  // Add this fallback method
  static Subject fallback() {
    return Subject(
      id: 'unknown',
      name: 'Unknown Subject',
      code: 'N/A',
      color: Colors.grey,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'instructor': instructor,
      'credits': credits,
      'color': color.value,
      'totalClasses': totalClasses,
      'attendedClasses': attendedClasses,
    };
  }

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      instructor: json['instructor'] ?? '',
      credits: json['credits'] ?? 3,
      color: Color(json['color']),
      totalClasses: json['totalClasses'],
      attendedClasses: json['attendedClasses'],
    );
  }

  Subject copyWith({
    String? id,
    String? name,
    String? code,
    String? instructor,
    int? credits,
    Color? color,
    int? totalClasses,
    int? attendedClasses,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      instructor: instructor ?? this.instructor,
      credits: credits ?? this.credits,
      color: color ?? this.color,
      totalClasses: totalClasses ?? this.totalClasses,
      attendedClasses: attendedClasses ?? this.attendedClasses,
    );
  }
}