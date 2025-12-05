import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math';
import '../services/storage_service.dart';
import '../models/subject.dart';
import '../models/schedule.dart';
import '../models/tracking_record.dart';
import '../models/assignment.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../utils/responsive_helper.dart';
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

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isDataLoaded = false;

  List<Subject> subjects = [];
  List<ClassSchedule> schedules = [];
  List<AttendanceRecord> attendanceRecords = [];
  List<Assignment> assignments = [];
  int attendanceStreak = 0;

  String? _lastLoadedUserId;

  // 🔥 NEW: Track if we're currently loading to prevent concurrent loads
  bool _isCurrentlyLoading = false;

  @override
  void initState() {
    super.initState();
    // Add observer to detect app lifecycle changes
    WidgetsBinding.instance.addObserver(this);
    print('🔵 HomeScreen initState called');
    _loadDataFromSupabase();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    print(
        '🧹 HomeScreen disposed - clearing all data');
    subjects.clear();
    schedules.clear();
    attendanceRecords.clear();
    assignments.clear();
    _isDataLoaded = false;
    _lastLoadedUserId = null;
    super.dispose();
  }

  // 🔥 NEW: Detect when app resumes from background
  @override
  void didChangeAppLifecycleState(
      AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      print('🔄 App resumed from background');
      // Don't auto-reload, just log it
      // Users can manually refresh if needed
    }
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    final currentUserId = FirebaseAuth.instance
        .currentUser?.uid;

    if (currentUserId != _lastLoadedUserId &&
        currentUserId != null) {
      print(
          '🔄 User changed! Old: $_lastLoadedUserId, New: $currentUserId');
      _forceReload();
    }
  }

  // 🔥 NEW: Centralized force reload method
  void _forceReload() {
    print('🧹 Force reloading all data...');

    setState(() {
      subjects = [];
      schedules = [];
      attendanceRecords = [];
      assignments = [];
      attendanceStreak = 0;
      _isDataLoaded = false;
      _lastLoadedUserId = null;
      _isLoading = true;
      _isCurrentlyLoading = false;
    });

    _loadDataFromSupabase();
  }

  Future<void> _loadDataFromSupabase() async {
    if (!mounted) return;

    // 🔥 CRITICAL: Prevent concurrent loads
    if (_isCurrentlyLoading) {
      print(
          '⚠️ Already loading data, skipping duplicate call');
      return;
    }

    final currentUserId = FirebaseAuth.instance
        .currentUser?.uid;

    print(
        '═══════════════════════════════════════');
    print('🔍 LOAD DATA DEBUG:');
    print('   Current User ID: $currentUserId');
    print(
        '   Last Loaded User ID: $_lastLoadedUserId');
    print('   Is Data Loaded: $_isDataLoaded');
    print(
        '   Is Currently Loading: $_isCurrentlyLoading');
    print('   Current Subjects Count: ${subjects
        .length}');
    print('   Subject IDs: ${subjects.map((s) =>
    s.id).toList()}');
    print(
        '═══════════════════════════════════════');

    // Skip if already loaded for THIS user
    if (_isDataLoaded &&
        _lastLoadedUserId == currentUserId &&
        currentUserId != null) {
      print(
          '⚠️ Data already loaded for user $currentUserId, skipping');
      setState(() => _isLoading = false);
      return;
    }

    // Mark as currently loading
    _isCurrentlyLoading = true;
    setState(() => _isLoading = true);

    try {
      print('🔄 Loading data from Supabase...');
      print(
          '🔍 Current user: ${FirebaseAuth.instance
              .currentUser?.email}');

      // Load all data in parallel
      print('📡 Fetching from Supabase...');
      final results = await Future.wait([
        SupabaseService.getSubjects(),
        SupabaseService.getSchedules(),
        SupabaseService.getAttendanceRecords(),
        SupabaseService.getAssignments(),
      ]);

      if (!mounted) {
        _isCurrentlyLoading = false;
        return;
      }

      print('📦 Raw results from Supabase:');
      print('   Subjects: ${(results[0] as List)
          .length}');
      print(
          '   Subject IDs from DB: ${(results[0] as List<
              Subject>)
              .map((s) => s.id)
              .toList()}');

      // 🔥 CRITICAL: Create NEW lists, don't modify existing ones
      final newSubjects = List<Subject>.from(
          results[0] as List<Subject>);
      final newSchedules = List<
          ClassSchedule>.from(
          results[1] as List<ClassSchedule>);
      final newAttendanceRecords = List<
          AttendanceRecord>.from(
          results[2] as List<AttendanceRecord>);
      final newAssignments = List<
          Assignment>.from(
          results[3] as List<Assignment>);

      print('✅ Created new lists:');
      print('   New Subjects: ${newSubjects
          .length}');
      print(
          '   New Subject IDs: ${newSubjects.map((
              s) => s.id).toList()}');

      // Update state with completely new lists
      setState(() {
        subjects = newSubjects;
        schedules = newSchedules;
        attendanceRecords = newAttendanceRecords;
        assignments = newAssignments;
      });

      print('✅ State updated:');
      print('   subjects.length = ${subjects
          .length}');
      print('   Subject IDs in state: ${subjects
          .map((s) => s.id).toList()}');

      _updateSubjectStats();

      _isDataLoaded = true;
      _lastLoadedUserId = currentUserId;
      _isCurrentlyLoading = false;

      setState(() => _isLoading = false);

      print(
          '✅ Data loaded successfully for user $currentUserId:');
      print('   - ${subjects.length} subjects');
      print('   - ${schedules.length} schedules');
      print('   - ${attendanceRecords
          .length} attendance records');
      print('   - ${assignments
          .length} assignments');
      print(
          '═══════════════════════════════════════');
    } catch (e) {
      print('❌ Error loading data: $e');
      _isCurrentlyLoading = false;

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
                'Error loading data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  int _calculateAttendanceStreak() {
    if (attendanceRecords.isEmpty) return 0;

    final sortedRecords = List<
        AttendanceRecord>.from(attendanceRecords);
    sortedRecords.sort((a, b) =>
        b.date.compareTo(a.date));

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
        final difference = lastDate
            .difference(record.date)
            .inDays;
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
    // 🔥 Create a NEW list with updated subjects
    final updatedSubjects = <Subject>[];

    for (var subject in subjects) {
      final subjectId = subject.id;
      final totalClasses = attendanceRecords
          .where((r) => r.subjectId == subjectId)
          .length;
      final attendedClasses = attendanceRecords
          .where((r) =>
      r.subjectId == subjectId && r.present)
          .length;

      updatedSubjects.add(subject.copyWith(
        totalClasses: totalClasses,
        attendedClasses: attendedClasses,
      ));
    }

    // Replace the entire list
    subjects = updatedSubjects;
    attendanceStreak =
        _calculateAttendanceStreak();
  }

  Future<void> _addSubject(
      Subject newSubject) async {
    print('➕ Adding subject: ${newSubject
        .name} (${newSubject.code})');
    print(
        '   Current subjects before add: ${subjects
            .length}');
    print(
        '   Current subject IDs: ${subjects.map((
            s) => s.id).toList()}');

    if (!SupabaseService.isUserLoggedIn) {
      print('❌ No user logged in');
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.error_outline,
                    color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text(
                    'Please sign in to add subjects')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius
                    .circular(12)),
          ),
        );
      }
      return;
    }

    // Check for duplicates by code
    if (subjects.any((s) =>
    s.code.toUpperCase() ==
        newSubject.code.toUpperCase())) {
      print('⚠️ Subject with code ${newSubject
          .code} already exists locally');
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(
                    'Subject ${newSubject
                        .code} already exists')),
              ],
            ),
            backgroundColor: Colors.orange
                .shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius
                    .circular(12)),
          ),
        );
      }
      return;
    }

    try {
      final result = await SupabaseService
          .addSubject(newSubject);

      if (result != null) {
        print('✅ Subject added to DB: ${result
            .id}');

        // Check if it already exists by ID (most reliable)
        if (!subjects.any((s) =>
        s.id == result.id)) {
          setState(() {
            // Create a new list with the added subject
            subjects = [...subjects, result];
            print(
                '✅ Added to local list. New count: ${subjects
                    .length}');
            print('   New subject IDs: ${subjects
                .map((s) => s.id).toList()}');
          });

          _updateSubjectStats();
        } else {
          print('⚠️ Subject ${result
              .id} already in local list, skipping');
        }
      }
    } catch (e) {
      print(
          '❌ Exception while adding subject: $e');
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline,
                    color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(
                    'Error: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius
                    .circular(12)),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _updateSubject(
      Subject updatedSubject) async {
    final success = await SupabaseService
        .updateSubject(updatedSubject);
    if (success) {
      setState(() {
        // Create a new list with the updated subject
        subjects = subjects.map((s) =>
        s.id == updatedSubject.id
            ? updatedSubject
            : s
        ).toList();
      });
      _updateSubjectStats();
    } else {
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          const SnackBar(content: Text(
              'Failed to update subject')),
        );
      }
    }
  }

  Future<void> _deleteSubject(
      String subjectId) async {
    final success = await SupabaseService
        .deleteSubject(subjectId);
    if (success) {
      setState(() {
        subjects = subjects.where((s) =>
        s.id != subjectId).toList();
        schedules = schedules.where((s) =>
        s.subjectId != subjectId).toList();
        attendanceRecords =
            attendanceRecords.where((r) =>
            r.subjectId != subjectId).toList();
        assignments = assignments.where((a) =>
        a.subjectId != subjectId).toList();
      });
      _updateSubjectStats();
    } else {
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          const SnackBar(content: Text(
              'Failed to delete subject')),
        );
      }
    }
  }

  Future<void> _addSchedule(
      ClassSchedule newSchedule) async {
    final result = await SupabaseService
        .addSchedule(newSchedule);
    if (result != null) {
      setState(() {
        schedules = [...schedules, result];
      });
    } else {
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          const SnackBar(content: Text(
              'Failed to add schedule')),
        );
      }
    }
  }

  Future<void> _updateSchedule(
      ClassSchedule updatedSchedule) async {
    final success = await SupabaseService
        .updateSchedule(updatedSchedule);
    if (success) {
      setState(() {
        schedules = schedules.map((s) =>
        s.id == updatedSchedule.id
            ? updatedSchedule
            : s
        ).toList();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          const SnackBar(content: Text(
              'Failed to update schedule')),
        );
      }
    }
  }

  Future<void> _deleteSchedule(
      String scheduleId) async {
    final success = await SupabaseService
        .deleteSchedule(scheduleId);
    if (success) {
      setState(() {
        schedules = schedules.where((s) =>
        s.id != scheduleId).toList();
      });
    } else {
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          const SnackBar(content: Text(
              'Failed to delete schedule')),
        );
      }
    }
  }

  Future<void> _addAssignment(
      Assignment newAssignment) async {
    final result = await SupabaseService
        .addAssignment(newAssignment);
    if (result != null) {
      setState(() {
        assignments = [...assignments, result];
      });

      final subject = subjects.firstWhere(
            (s) => s.id == result.subjectId,
        orElse: () => Subject.fallback(),
      );

      NotificationService
          .scheduleAssignmentReminder(
        assignmentId: result.id,
        assignmentTitle: result.title,
        subjectName: subject.name,
        dueDate: result.dueDate,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          const SnackBar(content: Text(
              'Failed to add assignment')),
        );
      }
    }
  }

  Future<void> _updateAssignment(
      Assignment updatedAssignment) async {
    final success = await SupabaseService
        .updateAssignment(updatedAssignment);
    if (success) {
      setState(() {
        assignments = assignments.map((a) =>
        a.id == updatedAssignment.id
            ? updatedAssignment
            : a
        ).toList();
      });

      final subject = subjects.firstWhere(
            (s) =>
        s.id == updatedAssignment.subjectId,
        orElse: () => Subject.fallback(),
      );

      NotificationService
          .scheduleAssignmentReminder(
        assignmentId: updatedAssignment.id,
        assignmentTitle: updatedAssignment.title,
        subjectName: subject.name,
        dueDate: updatedAssignment.dueDate,
      );
    } else {
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          const SnackBar(content: Text(
              'Failed to update assignment')),
        );
      }
    }
  }

  Future<void> _deleteAssignment(
      String assignmentId) async {
    final success = await SupabaseService
        .deleteAssignment(assignmentId);
    if (success) {
      setState(() {
        assignments = assignments.where((a) =>
        a.id != assignmentId).toList();
      });
      NotificationService
          .cancelAssignmentNotification(
          assignmentId);
    } else {
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          const SnackBar(content: Text(
              'Failed to delete assignment')),
        );
      }
    }
  }

  Future<void> _onAttendanceMarked() async {
    final records = await SupabaseService
        .getAttendanceRecords();
    setState(() {
      attendanceRecords =
      List<AttendanceRecord>.from(records);
    });
    _updateSubjectStats();
  }

  Future<void> _handleSignOut() async {
    print('🔵 Sign out button pressed');

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) =>
          AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius
                    .circular(20)),
            title: const Row(
              children: [
                Icon(Icons.logout_rounded,
                    color: Colors.red),
                SizedBox(width: 12),
                Text('Sign Out'),
              ],
            ),
            content: const Text(
              'Are you sure you want to sign out?',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () =>
                    Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius
                          .circular(12)),
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    try {
      setState(() {
        subjects = [];
        schedules = [];
        attendanceRecords = [];
        assignments = [];
        attendanceStreak = 0;
        _isLoading = false;
        _isDataLoaded = false;
        _lastLoadedUserId = null;
        _isCurrentlyLoading = false;
      });

      await StorageService.clearAll();

      try {
        final googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.disconnect();
        }
      } catch (e) {
        print('⚠️ Google sign out error: $e');
      }

      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print('❌ Sign out error: $e');
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          SnackBar(
            content: Text('Sign out failed: ${e
                .toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment
                .center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<
                    Color>(Colors.blue.shade600),
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

    return ResponsiveBuilder(
      builder: (context, deviceType) {
        if (deviceType == DeviceType.tablet ||
            deviceType == DeviceType.desktop) {
          return _buildDesktopLayout(
              context, deviceType);
        }
        return _buildMobileLayout(context);
      },
    );
  }

  Widget _buildMobileLayout(
      BuildContext context) {
    final pages = _getPages();
    final isVerySmallScreen = MediaQuery
        .sizeOf(context)
        .width < 360;

    return Scaffold(
      body: pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(
                  0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) =>
                    setState(() =>
                    _currentIndex = index),
                labelBehavior: isVerySmallScreen
                    ? NavigationDestinationLabelBehavior
                    .alwaysHide
                    : NavigationDestinationLabelBehavior
                    .alwaysShow,
                destinations: _getNavigationDestinations(
                    isVerySmallScreen),
                backgroundColor: Colors
                    .transparent,
                elevation: 0,
              ),
              Divider(height: 1,
                  thickness: 1,
                  color: Colors.grey.shade200),
              Padding(
                padding: const EdgeInsets
                    .fromLTRB(16, 8, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleSignOut,
                    icon: const Icon(
                        Icons.logout_rounded,
                        size: 18),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight
                              .w600),
                    ),
                    style: OutlinedButton
                        .styleFrom(
                      foregroundColor: Colors.red
                          .shade700,
                      side: BorderSide(
                          color: Colors.red
                              .shade300,
                          width: 1.5),
                      padding: const EdgeInsets
                          .symmetric(
                          vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius
                              .circular(12)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context,
      DeviceType deviceType) {
    final pages = _getPages();
    final isDesktop = deviceType ==
        DeviceType.desktop;

    return Scaffold(
      body: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(right: BorderSide(
                  color: Colors.grey.shade200)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(
                      0.03),
                  blurRadius: 10,
                  offset: const Offset(2, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: NavigationRail(
                    selectedIndex: _currentIndex,
                    onDestinationSelected: (
                        index) =>
                        setState(() =>
                        _currentIndex = index),
                    extended: isDesktop,
                    labelType: isDesktop
                        ? NavigationRailLabelType
                        .none
                        : NavigationRailLabelType
                        .all,
                    backgroundColor: Colors
                        .transparent,
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons
                            .dashboard_outlined),
                        selectedIcon: Icon(
                            Icons.dashboard),
                        label: Text('Dashboard'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons
                            .calendar_today_outlined),
                        selectedIcon: Icon(
                            Icons.calendar_today),
                        label: Text('Schedule'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons
                            .check_circle_outline),
                        selectedIcon: Icon(
                            Icons.check_circle),
                        label: Text('Attendance'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons
                            .assignment_outlined),
                        selectedIcon: Icon(
                            Icons.assignment),
                        label: Text('Tasks'),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons
                            .emoji_events_outlined),
                        selectedIcon: Icon(
                            Icons.emoji_events),
                        label: Text('Rewards'),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1,
                    thickness: 1,
                    color: Colors.grey.shade200,
                    indent: 8,
                    endIndent: 8),
                Padding(
                  padding: const EdgeInsets.all(
                      16),
                  child: SizedBox(
                    width: isDesktop ? 220 : null,
                    child: isDesktop
                        ? OutlinedButton.icon(
                      onPressed: _handleSignOut,
                      icon: const Icon(
                          Icons.logout_rounded,
                          size: 18),
                      label: const Text(
                          'Sign Out',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight
                                  .w600)),
                      style: OutlinedButton
                          .styleFrom(
                        foregroundColor: Colors
                            .red.shade700,
                        side: BorderSide(
                            color: Colors.red
                                .shade300,
                            width: 1.5),
                        padding: const EdgeInsets
                            .symmetric(
                            vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius
                                .circular(12)),
                      ),
                    )
                        : IconButton(
                      onPressed: _handleSignOut,
                      icon: const Icon(
                          Icons.logout_rounded),
                      color: Colors.red.shade700,
                      tooltip: 'Sign Out',
                      style: IconButton.styleFrom(
                        side: BorderSide(
                            color: Colors.red
                                .shade300,
                            width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius
                                .circular(12)),
                        padding: const EdgeInsets
                            .all(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: pages[_currentIndex]),
        ],
      ),
    );
  }

  List<Widget> _getPages() {
    return [
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
  }

  List<
      NavigationDestination> _getNavigationDestinations(
      bool showTooltips) {
    return [
      NavigationDestination(
        icon: const Icon(
            Icons.dashboard_outlined),
        selectedIcon: const Icon(Icons.dashboard),
        label: 'Dashboard',
      ),
      NavigationDestination(
        icon: const Icon(
            Icons.calendar_today_outlined),
        selectedIcon: const Icon(
            Icons.calendar_today),
        label: 'Schedule',
      ),
      NavigationDestination(
        icon: const Icon(
            Icons.check_circle_outline),
        selectedIcon: const Icon(
            Icons.check_circle),
        label: 'Attendance',
      ),
      NavigationDestination(
        icon: const Icon(
            Icons.assignment_outlined),
        selectedIcon: const Icon(
            Icons.assignment),
        label: 'Tasks',
      ),
      NavigationDestination(
        icon: const Icon(
            Icons.emoji_events_outlined),
        selectedIcon: const Icon(
            Icons.emoji_events),
        label: 'Rewards',
      ),
    ];
  }
}