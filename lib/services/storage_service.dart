import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static const String _subjectsKey = 'subjects';
  static const String _schedulesKey = 'schedules';
  static const String _attendanceKey = 'attendance';
  static const String _streakKey = 'streak';


  static Future<void> saveSubjects(List<Map<String, dynamic>> subjects) async {
    await _prefs?.setString(_subjectsKey, json.encode(subjects));
  }




  static Future<List<Map<String, dynamic>>> loadSubjects() async {
    final jsonString = _prefs?.getString(_subjectsKey);
    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((j) => j as Map<String, dynamic>).toList();
  }


  static Future<void> saveSchedules(List<Map<String, dynamic>> schedules) async {
    await _prefs?.setString(_schedulesKey, json.encode(schedules));
  }


  static Future<List<Map<String, dynamic>>> loadSchedules() async {
    final jsonString = _prefs?.getString(_schedulesKey);
    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((j) => j as Map<String, dynamic>).toList();
  }


  static Future<void> saveAttendanceRecords(List<Map<String, dynamic>> records) async {
    await _prefs?.setString(_attendanceKey, json.encode(records));
  }


  static Future<List<Map<String, dynamic>>> loadAttendanceRecords() async {
    final jsonString = _prefs?.getString(_attendanceKey);
    if (jsonString == null) return [];

    final jsonList = json.decode(jsonString) as List;
    return jsonList.map((j) => j as Map<String, dynamic>).toList();
  }


  static Future<void> saveStreak(int streak) async {
    await _prefs?.setInt(_streakKey, streak);
  }


  static Future<int> loadStreak() async {
    return _prefs?.getInt(_streakKey) ?? 0;
  }


  static Future<void> clearAll() async {
    await _prefs?.clear();
  }


  static Future<void> deleteSubject(String subjectId) async {
    final subjects = await loadSubjects();
    subjects.removeWhere((s) => s['id'] == subjectId);
    await saveSubjects(subjects);
  }


  static Future<void> deleteSchedule(String scheduleId) async {
    final schedules = await loadSchedules();
    schedules.removeWhere((s) => s['id'] == scheduleId);
    await saveSchedules(schedules);
  }


  static Future<DateTime?> getLastSyncTime() async {
    final timestamp = _prefs?.getInt('lastSync');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }


  static Future<void> updateLastSyncTime() async {
    await _prefs?.setInt('lastSync', DateTime.now().millisecondsSinceEpoch);
  }
}