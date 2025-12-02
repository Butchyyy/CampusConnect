import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/schedule.dart';
import '../models/tracking_record.dart';
import '../models/assignment.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;
  static String? _userId;

  // Initialize Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );


    final user = _client.auth.currentUser;
    if (user == null) {
      // Sign in anonymously for demo purposes
      final response = await _client.auth.signInAnonymously();
      _userId = response.user?.id;
    } else {
      _userId = user.id;
    }
  }

  static Future<String> _getOrCreateUserId() async {
    final user = _client.auth.currentUser;
    return user?.id ?? 'anonymous';
  }

  static String get userId => _userId ?? _client.auth.currentUser?.id ?? 'anonymous';



  static Future<List<Subject>> getSubjects() async {
    try {
      final response = await _client
          .from('subjects')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      return (response as List)
          .map((json) => Subject(
        id: json['id'],
        name: json['name'],
        code: json['code'],
        instructor: json['instructor'] ?? '',
        credits: json['credits'] ?? 3,
        color: Color(json['color']),
        totalClasses: json['total_classes'],
        attendedClasses: json['attended_classes'],
      ))
          .toList();
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  static Future<Subject?> addSubject(Subject subject) async {
    try {
      final response = await _client.from('subjects').insert({
        'user_id': userId,
        'name': subject.name,
        'code': subject.code,
        'instructor': subject.instructor,
        'credits': subject.credits,
        'color': subject.color.value,
        'total_classes': subject.totalClasses ?? 0,
        'attended_classes': subject.attendedClasses ?? 0,
      }).select().single();

      return Subject(
        id: response['id'],
        name: response['name'],
        code: response['code'],
        instructor: response['instructor'] ?? '',
        credits: response['credits'] ?? 3,
        color: Color(response['color']),
        totalClasses: response['total_classes'],
        attendedClasses: response['attended_classes'],
      );
    } catch (e) {
      print('Error adding subject: $e');
      return null;
    }
  }

  static Future<bool> updateSubject(Subject subject) async {
    try {
      await _client.from('subjects').update({
        'name': subject.name,
        'code': subject.code,
        'instructor': subject.instructor,
        'credits': subject.credits,
        'color': subject.color.value,
        'total_classes': subject.totalClasses ?? 0,
        'attended_classes': subject.attendedClasses ?? 0,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', subject.id);

      return true;
    } catch (e) {
      print('Error updating subject: $e');
      return false;
    }
  }

  static Future<bool> deleteSubject(String subjectId) async {
    try {
      await _client.from('subjects').delete().eq('id', subjectId);
      return true;
    } catch (e) {
      print('Error deleting subject: $e');
      return false;
    }
  }



  static Future<List<ClassSchedule>> getSchedules() async {
    try {
      final response = await _client
          .from('schedules')
          .select()
          .eq('user_id', userId)
          .order('day_of_week');

      return (response as List)
          .map((json) => ClassSchedule(
        id: json['id'],
        subjectId: json['subject_id'],
        dayOfWeek: json['day_of_week'],
        startTime: json['start_time'],
        endTime: json['end_time'],
        room: json['room'] ?? '',
        fileToCheck: json['file_to_check'],
      ))
          .toList();
    } catch (e) {
      print('Error fetching schedules: $e');
      return [];
    }
  }

  static Future<ClassSchedule?> addSchedule(ClassSchedule schedule) async {
    try {
      final response = await _client.from('schedules').insert({
        'user_id': userId,
        'subject_id': schedule.subjectId,
        'day_of_week': schedule.dayOfWeek,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
        'room': schedule.room,
        'file_to_check': schedule.fileToCheck,
      }).select().single();

      return ClassSchedule(
        id: response['id'],
        subjectId: response['subject_id'],
        dayOfWeek: response['day_of_week'],
        startTime: response['start_time'],
        endTime: response['end_time'],
        room: response['room'] ?? '',
        fileToCheck: response['file_to_check'],
      );
    } catch (e) {
      print('Error adding schedule: $e');
      return null;
    }
  }

  static Future<bool> updateSchedule(ClassSchedule schedule) async {
    try {
      await _client.from('schedules').update({
        'subject_id': schedule.subjectId,
        'day_of_week': schedule.dayOfWeek,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
        'room': schedule.room,
        'file_to_check': schedule.fileToCheck,
      }).eq('id', schedule.id);

      return true;
    } catch (e) {
      print('Error updating schedule: $e');
      return false;
    }
  }

  static Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _client.from('schedules').delete().eq('id', scheduleId);
      return true;
    } catch (e) {
      print('Error deleting schedule: $e');
      return false;
    }
  }



  static Future<List<AttendanceRecord>> getAttendanceRecords() async {
    try {
      final response = await _client
          .from('attendance_records')
          .select()
          .eq('user_id', userId)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => AttendanceRecord(
        id: json['id'],
        subjectId: json['subject_id'],
        date: DateTime.parse(json['date']),
        present: json['present'] ?? false,
        late: json['late'] ?? false,
        checkInTime: json['check_in_time'] != null
            ? DateTime.parse(json['check_in_time'])
            : null,
      ))
          .toList();
    } catch (e) {
      print('Error fetching attendance records: $e');
      return [];
    }
  }

  // NEW METHOD: Check if any attendance already exists for today
  static Future<bool> hasAttendanceForToday() async {
    try {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final response = await _client
          .from('attendance_records')
          .select()
          .eq('user_id', userId)
          .gte('date', startOfDay.toIso8601String())
          .lte('date', endOfDay.toIso8601String());

      return (response as List).isNotEmpty;
    } catch (e) {
      print('Error checking today\'s attendance: $e');
      return false;
    }
  }

  // MODIFIED METHOD: Add attendance record with daily limit check
  static Future<AttendanceRecord?> addAttendanceRecord(
      AttendanceRecord record) async {
    try {
      // Check if any attendance already exists for today
      final hasAttendance = await hasAttendanceForToday();

      if (hasAttendance) {
        print('Attendance already recorded for today');
        return null; // Return null to indicate already submitted today
      }

      print('Adding attendance record: ${record.toJson()}');

      final response = await _client.from('attendance_records').insert({
        'user_id': userId,
        'subject_id': record.subjectId,
        'date': record.date.toIso8601String(),
        'present': record.present,
        'late': record.late,
        'check_in_time': record.checkInTime?.toIso8601String(),
      }).select().single();

      print('Attendance record added successfully: $response');

      return AttendanceRecord(
        id: response['id'],
        subjectId: response['subject_id'],
        date: DateTime.parse(response['date']),
        present: response['present'] ?? false,
        late: response['late'] ?? false,
        checkInTime: response['check_in_time'] != null
            ? DateTime.parse(response['check_in_time'])
            : null,
      );
    } catch (e) {
      print('Error adding attendance record: $e');
      print('Error details: ${e.toString()}');
      return null;
    }
  }



  static Future<List<Assignment>> getAssignments() async {
    try {
      final response = await _client
          .from('assignments')
          .select()
          .eq('user_id', userId)
          .order('due_date');

      return (response as List)
          .map((json) => Assignment(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        subjectId: json['subject_id'],
        dueDate: DateTime.parse(json['due_date']),
        priority: AssignmentPriority.values[json['priority'] ?? 1],
        completed: json['completed'] ?? false,
        completedDate: json['completed_date'] != null
            ? DateTime.parse(json['completed_date'])
            : null,
      ))
          .toList();
    } catch (e) {
      print('Error fetching assignments: $e');
      return [];
    }
  }

  static Future<Assignment?> addAssignment(Assignment assignment) async {
    try {
      final response = await _client.from('assignments').insert({
        'user_id': userId,
        'subject_id': assignment.subjectId,
        'title': assignment.title,
        'description': assignment.description,
        'due_date': assignment.dueDate.toIso8601String(),
        'priority': assignment.priority.index,
        'completed': assignment.completed,
        'completed_date': assignment.completedDate?.toIso8601String(),
      }).select().single();

      return Assignment(
        id: response['id'],
        title: response['title'],
        description: response['description'] ?? '',
        subjectId: response['subject_id'],
        dueDate: DateTime.parse(response['due_date']),
        priority: AssignmentPriority.values[response['priority'] ?? 1],
        completed: response['completed'] ?? false,
        completedDate: response['completed_date'] != null
            ? DateTime.parse(response['completed_date'])
            : null,
      );
    } catch (e) {
      print('Error adding assignment: $e');
      return null;
    }
  }

  static Future<bool> updateAssignment(Assignment assignment) async {
    try {
      await _client.from('assignments').update({
        'title': assignment.title,
        'description': assignment.description,
        'subject_id': assignment.subjectId,
        'due_date': assignment.dueDate.toIso8601String(),
        'priority': assignment.priority.index,
        'completed': assignment.completed,
        'completed_date': assignment.completedDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', assignment.id);

      return true;
    } catch (e) {
      print('Error updating assignment: $e');
      return false;
    }
  }

  static Future<bool> deleteAssignment(String assignmentId) async {
    try {
      await _client.from('assignments').delete().eq('id', assignmentId);
      return true;
    } catch (e) {
      print('Error deleting assignment: $e');
      return false;
    }
  }
}