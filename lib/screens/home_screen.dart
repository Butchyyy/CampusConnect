import 'package:flutter/material.dart';
import 'dart:math';
import '../models/subject.dart';
import '../models/schedule.dart';
import '../models/tracking_record.dart';
import '../models/assignment.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import 'dashboard_screen.dart';
import 'schedule_screen.dart';
import 'tracking_screen.dart';
import 'assignments_screen.dart';
import 'achievements_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isLoading = true;

  List<Subject> subjects = [];
  List<ClassSchedule> schedules = [];
  List<AttendanceRecord> attendanceRecords = [];
  List<Assignment> assignments = [];
  int attendanceStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadDataFromSupabase();
  }

  // Load all data from Supabase
  Future<void> _loadDataFromSupabase() async {
    setState(() => _isLoading = true);

    try {
      // Load all data in parallel
      final results = await Future.wait([
        SupabaseService.getSubjects(),
        SupabaseService.getSchedules(),
        SupabaseService.getAttendanceRecords(),
        SupabaseService.getAssignments(),
      ]);

      setState(() {
        subjects = results[0] as List<Subject>;
        schedules = results[1] as List<ClassSchedule>;
        attendanceRecords = results[2] as List<AttendanceRecord>;
        assignments = results[3] as List<Assignment>;
        _updateSubjectStats();
        _isLoading = false;
      });
    } catch (e) {
      ('Error loading data: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
  }

  int _calculateAttendanceStreak() {
    if (attendanceRecords.isEmpty) return 0;

    final sortedRecords = List<AttendanceRecord>.from(attendanceRecords);
    sortedRecords.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime? lastDate;

    for (var record in sortedRecords) {
      if (!record.present) {
        if (lastDate == null) break;
        continue;
      }

      if (lastDate == null) {
        streak = 1;
        lastDate = record.date;
      } else {
        final difference = lastDate.difference(record.date).inDays;
        if (difference == 1) {
          streak++;
          lastDate = record.date;
        } else if (difference > 1) {
          break;
        }
      }
    }

    return streak;
  }

  void _updateSubjectStats() {
    for (int i = 0; i < subjects.length; i++) {
      final subjectId = subjects[i].id;
      final totalClasses = attendanceRecords
          .where((r) => r.subjectId == subjectId)
          .length;
      final attendedClasses = attendanceRecords
          .where((r) => r.subjectId == subjectId && r.present)
          .length;

      subjects[i] = subjects[i].copyWith(
        totalClasses: totalClasses,
        attendedClasses: attendedClasses,
      );
    }

    attendanceStreak = _calculateAttendanceStreak();
  }


  Future<void> _addSubject(Subject newSubject) async {
    final result = await SupabaseService.addSubject(newSubject);
    if (result != null) {
      setState(() {
        subjects.add(result);
        _updateSubjectStats();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add subject')),
        );
      }
    }
  }

  Future<void> _updateSubject(Subject updatedSubject) async {
    final success = await SupabaseService.updateSubject(updatedSubject);
    if (success) {
      setState(() {
        final index = subjects.indexWhere((s) => s.id == updatedSubject.id);
        if (index != -1) {
          subjects[index] = updatedSubject;
          _updateSubjectStats();
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update subject')),
        );
      }
    }
  }

  Future<void> _deleteSubject(String subjectId) async {
    final success = await SupabaseService.deleteSubject(subjectId);
    if (success) {
      setState(() {
        subjects.removeWhere((s) => s.id == subjectId);
        schedules.removeWhere((s) => s.subjectId == subjectId);
        attendanceRecords.removeWhere((r) => r.subjectId == subjectId);
        assignments.removeWhere((a) => a.subjectId == subjectId);
        _updateSubjectStats();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete subject')),
        );
      }
    }
  }


  Future<void> _addSchedule(ClassSchedule newSchedule) async {
    final result = await SupabaseService.addSchedule(newSchedule);
    if (result != null) {
      setState(() {
        schedules.add(result);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add schedule')),
        );
      }
    }
  }

  Future<void> _updateSchedule(ClassSchedule updatedSchedule) async {
    final success = await SupabaseService.updateSchedule(updatedSchedule);
    if (success) {
      setState(() {
        final index = schedules.indexWhere((s) => s.id == updatedSchedule.id);
        if (index != -1) {
          schedules[index] = updatedSchedule;
        }
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update schedule')),
        );
      }
    }
  }

  Future<void> _deleteSchedule(String scheduleId) async {
    final success = await SupabaseService.deleteSchedule(scheduleId);
    if (success) {
      setState(() {
        schedules.removeWhere((s) => s.id == scheduleId);
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete schedule')),
        );
      }
    }
  }


  Future<void> _addAssignment(Assignment newAssignment) async {
    final result = await SupabaseService.addAssignment(newAssignment);
    if (result != null) {
      setState(() {
        assignments.add(result);
      });

      // Schedule notification
      final subject = subjects.firstWhere(
            (s) => s.id == result.subjectId,
        orElse: () => Subject.fallback(),
      );

      NotificationService.scheduleAssignmentReminder(
        assignmentId: result.id,
        assignmentTitle: result.title,
        subjectName: subject.name,
        dueDate: result.dueDate,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add assignment')),
        );
      }
    }
  }

  Future<void> _updateAssignment(Assignment updatedAssignment) async {
    final success = await SupabaseService.updateAssignment(updatedAssignment);
    if (success) {
      setState(() {
        final index = assignments.indexWhere((a) => a.id == updatedAssignment.id);
        if (index != -1) {
          assignments[index] = updatedAssignment;
        }
      });

      // Update notification
      final subject = subjects.firstWhere(
            (s) => s.id == updatedAssignment.subjectId,
        orElse: () => Subject.fallback(),
      );

      NotificationService.scheduleAssignmentReminder(
        assignmentId: updatedAssignment.id,
        assignmentTitle: updatedAssignment.title,
        subjectName: subject.name,
        dueDate: updatedAssignment.dueDate,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update assignment')),
        );
      }
    }
  }

  Future<void> _deleteAssignment(String assignmentId) async {
    final success = await SupabaseService.deleteAssignment(assignmentId);
    if (success) {
      setState(() {
        assignments.removeWhere((a) => a.id == assignmentId);
      });
      NotificationService.cancelAssignmentNotification(assignmentId);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete assignment')),
        );
      }
    }
  }


  Future<void> _onAttendanceMarked() async {
    // Reload attendance records from database
    final records = await SupabaseService.getAttendanceRecords();
    setState(() {
      attendanceRecords = records;
      _updateSubjectStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
              ),
              const SizedBox(height: 16),
              Text(
                'Loading your data...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final pages = [
      DashboardScreen(
        subjects: subjects,
        schedules: schedules,
        attendanceRecords: attendanceRecords,
        attendanceStreak: attendanceStreak,
        onSubjectAdded: _addSubject,
        onSubjectUpdated: _updateSubject,
        onSubjectDeleted: _deleteSubject,
      ),
      ScheduleScreen(
        schedules: schedules,
        subjects: subjects,
        onScheduleAdded: _addSchedule,
        onScheduleUpdated: _updateSchedule,
        onScheduleDeleted: _deleteSchedule,
      ),
      TrackingScreen(
        subjects: subjects,
        attendanceRecords: attendanceRecords,
        onAttendanceMarked: _onAttendanceMarked,
      ),
      AssignmentsScreen(
        assignments: assignments,
        subjects: subjects,
        onAssignmentAdded: _addAssignment,
        onAssignmentUpdated: _updateAssignment,
        onAssignmentDeleted: _deleteAssignment,
      ),
      AchievementsScreen(
        attendanceStreak: attendanceStreak,
        subjects: subjects,
        attendanceRecords: attendanceRecords,
      ),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.calendar_today), label: 'Schedule'),
          NavigationDestination(icon: Icon(Icons.check_circle), label: 'Attendance'),
          NavigationDestination(icon: Icon(Icons.assignment), label: 'Assignments'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Achievements'),
        ],
      ),
    );
  }
}