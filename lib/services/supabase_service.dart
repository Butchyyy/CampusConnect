import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subject.dart';
import '../models/schedule.dart';
import '../models/tracking_record.dart';
import '../models/assignment.dart';

class SupabaseService {
  static final SupabaseClient _client = Supabase.instance.client;

  // Initialize Supabase
  static Future<void> initialize({
    required String supabaseUrl,
    required String supabaseAnonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: supabaseAnonKey,
    );
    print('✅ Supabase initialized');
  }

  // ✅ Get user ID from Firebase with detailed logging
  static String get userId {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    print('🔍 Getting userId from Firebase:');
    print('   - User: ${user?.email ?? "null"}');
    print('   - UID: ${uid ?? "null"}');

    if (uid == null || uid.isEmpty) {
      print('❌ ERROR: No user logged in!');
      throw Exception('No user logged in. Please sign in first.');
    }

    return uid;
  }

  // ✅ Safe check if user is logged in
  static bool get isUserLoggedIn {
    final user = FirebaseAuth.instance.currentUser;
    final isLoggedIn = user != null;
    print('🔍 isUserLoggedIn: $isLoggedIn (${user?.email ?? "null"})');
    return isLoggedIn;
  }

  static Future<List<Subject>> getSubjects() async {
    try {
      if (!isUserLoggedIn) {
        print('⚠️ No user logged in, returning empty list');
        return [];
      }

      print('📚 Fetching subjects for user: $userId');

      final response = await _client
          .from('subjects')
          .select()
          .eq('user_id', userId)
          .order('created_at');

      print('✅ Fetched ${(response as List).length} subjects');

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
      print('❌ Error fetching subjects: $e');
      return [];
    }
  }

  static Future<Subject?> addSubject(Subject subject) async {
    try {
      if (!isUserLoggedIn) {
        print('❌ Cannot add subject - no user logged in');
        throw Exception('No user logged in');
      }

      print('➕ Adding subject to Supabase:');
      print('   - User ID: $userId');
      print('   - Name: ${subject.name}');
      print('   - Code: ${subject.code}');
      print('   - Instructor: ${subject.instructor}');
      print('   - Credits: ${subject.credits}');
      print('   - Color: ${subject.color.value}');

      final data = {
        'user_id': userId,
        'name': subject.name,
        'code': subject.code,
        'instructor': subject.instructor,
        'credits': subject.credits,
        'color': subject.color.value,
        'total_classes': subject.totalClasses ?? 0,
        'attended_classes': subject.attendedClasses ?? 0,
      };

      print('📤 Sending data to Supabase: $data');

      final response = await _client
          .from('subjects')
          .insert(data)
          .select()
          .single();

      print('✅ Subject added successfully!');
      print('📥 Response: $response');

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
    } on PostgrestException catch (e) {
      print('❌ Supabase error adding subject:');
      print('   - Message: ${e.message}');
      print('   - Code: ${e.code}');
      print('   - Details: ${e.details}');
      print('   - Hint: ${e.hint}');
      throw Exception('Database error: ${e.message}');
    } catch (e) {
      print('❌ Unexpected error adding subject: $e');
      print('   - Type: ${e.runtimeType}');
      throw Exception('Failed to add subject: ${e.toString()}');
    }
  }

  static Future<bool> updateSubject(Subject subject) async {
    try {
      if (!isUserLoggedIn) {
        print('❌ Cannot update subject - no user logged in');
        return false;
      }

      print('🔄 Updating subject: ${subject.id}');

      await _client.from('subjects').update({
        'name': subject.name,
        'code': subject.code,
        'instructor': subject.instructor,
        'credits': subject.credits,
        'color': subject.color.value,
        'total_classes': subject.totalClasses ?? 0,
        'attended_classes': subject.attendedClasses ?? 0,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', subject.id).eq('user_id', userId);

      print('✅ Subject updated successfully');
      return true;
    } catch (e) {
      print('❌ Error updating subject: $e');
      return false;
    }
  }

  static Future<bool> deleteSubject(String subjectId) async {
    try {
      if (!isUserLoggedIn) {
        print('❌ Cannot delete subject - no user logged in');
        return false;
      }

      print('🗑️ Deleting subject: $subjectId');

      await _client
          .from('subjects')
          .delete()
          .eq('id', subjectId)
          .eq('user_id', userId);

      print('✅ Subject deleted successfully');
      return true;
    } catch (e) {
      print('❌ Error deleting subject: $e');
      return false;
    }
  }

  static Future<List<ClassSchedule>> getSchedules() async {
    try {
      if (!isUserLoggedIn) {
        print('⚠️ No user logged in, returning empty list');
        return [];
      }

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
      print('❌ Error fetching schedules: $e');
      return [];
    }
  }

  static Future<ClassSchedule?> addSchedule(ClassSchedule schedule) async {
    try {
      if (!isUserLoggedIn) {
        print('❌ Cannot add schedule - no user logged in');
        return null;
      }

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
      print('❌ Error adding schedule: $e');
      return null;
    }
  }

  static Future<bool> updateSchedule(ClassSchedule schedule) async {
    try {
      if (!isUserLoggedIn) {
        print('❌ Cannot update schedule - no user logged in');
        return false;
      }

      await _client.from('schedules').update({
        'subject_id': schedule.subjectId,
        'day_of_week': schedule.dayOfWeek,
        'start_time': schedule.startTime,
        'end_time': schedule.endTime,
        'room': schedule.room,
        'file_to_check': schedule.fileToCheck,
      }).eq('id', schedule.id).eq('user_id', userId);

      return true;
    } catch (e) {
      print('❌ Error updating schedule: $e');
      return false;
    }
  }

  static Future<bool> deleteSchedule(String scheduleId) async {
    try {
      if (!isUserLoggedIn) {
        print('❌ Cannot delete schedule - no user logged in');
        return false;
      }

      await _client
          .from('schedules')
          .delete()
          .eq('id', scheduleId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('❌ Error deleting schedule: $e');
      return false;
    }
  }

  static Future<List<AttendanceRecord>> getAttendanceRecords() async {
    try {
      if (!isUserLoggedIn) {
        print('⚠️ No user logged in, returning empty list');
        return [];
      }

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
      print('❌ Error fetching attendance records: $e');
      return [];
    }
  }

  static Future<bool> hasAttendanceForSubjectToday(String subjectId) async {
    try {
      if (!isUserLoggedIn) return false;

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      final response = await _client
          .from('attendance_records')
          .select()
          .eq('user_id', userId)
          .eq('subject_id', subjectId)
          .gte('date', startOfDay.toIso8601String())
          .lte('date', endOfDay.toIso8601String());

      return (response as List).isNotEmpty;
    } catch (e) {
      print('❌ Error checking today\'s attendance for subject: $e');
      return false;
    }
  }

  static Future<bool> hasAttendanceForToday() async {
    try {
      if (!isUserLoggedIn) return false;

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
      print('❌ Error checking today\'s attendance: $e');
      return false;
    }
  }

  static Future<AttendanceRecord?> addAttendanceRecord(
      AttendanceRecord record) async {
    try {
      if (!isUserLoggedIn) {
        print('❌ Cannot add attendance - no user logged in');
        return null;
      }

      final hasAttendance = await hasAttendanceForSubjectToday(record.subjectId);

      if (hasAttendance) {
        print('⚠️ Attendance already recorded for subject ${record.subjectId} today');
        return null;
      }

      print('➕ Adding attendance record: ${record.toJson()}');

      final response = await _client.from('attendance_records').insert({
        'user_id': userId,
        'subject_id': record.subjectId,
        'date': record.date.toIso8601String(),
        'present': record.present,
        'late': record.late,
        'check_in_time': record.checkInTime?.toIso8601String(),
      }).select().single();

      print('✅ Attendance record added successfully: $response');

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
      print('❌ Error adding attendance record: $e');
      return null;
    }
  }

  static Future<List<Assignment>> getAssignments() async {
    try {
      if (!isUserLoggedIn) {
        print('⚠️ No user logged in, returning empty list');
        return [];
      }

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
      print('❌ Error fetching assignments: $e');
      return [];
    }
  }

  static Future<Assignment?> addAssignment(Assignment assignment) async {
    try {
      if (!isUserLoggedIn) {
        print('❌ Cannot add assignment - no user logged in');
        return null;
      }

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
      print('❌ Error adding assignment: $e');
      return null;
    }
  }

  static Future<bool> updateAssignment(Assignment assignment) async {
    try {
      if (!isUserLoggedIn) {
        print('❌ Cannot update assignment - no user logged in');
        return false;
      }

      await _client.from('assignments').update({
        'title': assignment.title,
        'description': assignment.description,
        'subject_id': assignment.subjectId,
        'due_date': assignment.dueDate.toIso8601String(),
        'priority': assignment.priority.index,
        'completed': assignment.completed,
        'completed_date': assignment.completedDate?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', assignment.id).eq('user_id', userId);

      return true;
    } catch (e) {
      print('❌ Error updating assignment: $e');
      return false;
    }
  }

  static Future<bool> deleteAssignment(String assignmentId) async {
    try {
      if (!isUserLoggedIn) {
        print('❌ Cannot delete assignment - no user logged in');
        return false;
      }

      await _client
          .from('assignments')
          .delete()
          .eq('id', assignmentId)
          .eq('user_id', userId);

      return true;
    } catch (e) {
      print('❌ Error deleting assignment: $e');
      return false;
    }
  }
}