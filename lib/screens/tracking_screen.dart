import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../models/tracking_record.dart';
import '../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class TrackingScreen extends StatefulWidget {
  final List<Subject> subjects;
  final List<AttendanceRecord> attendanceRecords;
  final VoidCallback onAttendanceMarked;

  const TrackingScreen({
    Key? key,
    required this.subjects,
    required this.attendanceRecords,
    required this.onAttendanceMarked,
  }) : super(key: key);

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final Map<String, bool> _selectedSubjects = {};
  final _supabase = Supabase.instance.client;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery
        .of(context)
        .padding
        .bottom + kBottomNavigationBarHeight;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.green.shade50,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, 20 + bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildMarkAttendanceCard(),
              const SizedBox(height: 24),
              _buildRecentAttendanceSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment
            .spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment
                .start,
            children: [
              const Text(
                'Attendance Tracking',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.attendanceRecords
                    .length} total records',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.blue.shade400,
                  Colors.green.shade400
                ],
              ),
              borderRadius: BorderRadius.circular(
                  12),
            ),
            child: Text(
              '${DateTime
                  .now()
                  .day}/${DateTime
                  .now()
                  .month}/${DateTime
                  .now()
                  .year}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarkAttendanceCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment
            .start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(
                      12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.green.shade400
                      ],
                    ),
                    borderRadius: BorderRadius
                        .circular(12),
                  ),
                  child: const Icon(
                    Icons
                        .check_circle_outline_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Mark Attendance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          widget.subjects.isEmpty
              ? _buildEmptySubjectsState()
              : Column(
            children: [
              ...widget.subjects.map((subject) =>
                  _buildSubjectTile(subject)),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.green.shade400
                      ],
                    ),
                    borderRadius: BorderRadius
                        .circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(
                            0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting
                        ? null
                        : _submitAttendance,
                    icon: _isSubmitting
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<
                            Color>(Colors.white),
                      ),
                    )
                        : const Icon(
                        Icons.check_rounded,
                        size: 22),
                    label: Text(
                      _isSubmitting
                          ? 'Submitting...'
                          : 'Submit Attendance',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight
                            .bold,
                      ),
                    ),
                    style: ElevatedButton
                        .styleFrom(
                      backgroundColor: Colors
                          .transparent,
                      foregroundColor: Colors
                          .white,
                      shadowColor: Colors
                          .transparent,
                      minimumSize: const Size
                          .fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius
                            .circular(12),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTile(Subject subject) {
    final isSelected = _selectedSubjects[subject
        .id] ?? false;
    final percentage = _calculateAttendancePercentage(
        subject.id);

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSubjects[subject.id] =
          !isSelected;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? subject.color
              .withOpacity(0.1) : Colors.grey
              .shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? subject.color
                : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    subject.color,
                    subject.color.withOpacity(
                        0.7),
                  ],
                ),
                borderRadius: BorderRadius
                    .circular(12),
                boxShadow: [
                  BoxShadow(
                    color: subject.color
                        .withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  subject.name.isNotEmpty
                      ? subject.name[0]
                      .toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets
                            .symmetric(
                            horizontal: 8,
                            vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPercentageColor(
                              double.parse(
                                  percentage)),
                          borderRadius: BorderRadius
                              .circular(6),
                        ),
                        child: Text(
                          '$percentage%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight
                                .bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'attendance',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                              .shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected
                    ? subject.color
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? subject
                      .color : Colors.grey
                      .shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius
                    .circular(8),
              ),
              child: isSelected
                  ? const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 20,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySubjectsState() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book_outlined,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No subjects available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add subjects first to mark attendance',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAttendanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment
          .start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(
                16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                    0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.history_rounded,
                  color: Color(0xFF2D3748)),
              SizedBox(width: 8),
              Text(
                'Recent Attendance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        widget.attendanceRecords.isEmpty
            ? _buildEmptyRecordsState()
            : Column(
          children: widget.attendanceRecords.take(
              15).map((record) {
            final subject = widget.subjects
                .firstWhere(
                  (s) => s.id == record.subjectId,
              orElse: () => Subject.fallback(),
            );
            return _buildAttendanceRecord(
                record, subject);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyRecordsState() {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_rounded,
                size: 60,
                color: Colors.green.shade300,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No attendance records yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mark attendance to see records here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecord(
      AttendanceRecord record, Subject subject) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: record.present ? Colors.green
              .shade100 : Colors.red.shade100,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets
            .symmetric(
            horizontal: 16, vertical: 12),
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                subject.color,
                subject.color.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(
                12),
            boxShadow: [
              BoxShadow(
                color: subject.color.withOpacity(
                    0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              subject.name.isNotEmpty ? subject
                  .name[0].toUpperCase() : '?',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Text(
          subject.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF2D3748),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment
                .start,
            children: [
              Row(
                children: [
                  Icon(Icons
                      .calendar_today_rounded,
                      size: 14,
                      color: Colors.grey
                          .shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${record.date.day}/${record
                        .date.month}/${record.date
                        .year}',
                    style: TextStyle(fontSize: 13,
                        color: Colors.grey
                            .shade700),
                  ),
                ],
              ),
              if (record.checkInTime != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: Colors.grey
                            .shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Check-in: ${record
                          .checkInTime!
                          .hour}:${record
                          .checkInTime!.minute
                          .toString().padLeft(
                          2, '0')}',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey
                              .shade700),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (record.late)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius
                      .circular(8),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: Colors.orange.shade700,
                  size: 20,
                ),
              ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: record.present ? Colors
                    .green.shade50 : Colors.red
                    .shade50,
                borderRadius: BorderRadius
                    .circular(8),
              ),
              child: Icon(
                record.present ? Icons
                    .check_circle_rounded : Icons
                    .cancel_rounded,
                color: record.present ? Colors
                    .green.shade700 : Colors.red
                    .shade700,
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75)
      return Colors.green.shade600;
    if (percentage >= 50)
      return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _calculateAttendancePercentage(
      String subjectId) {
    final subjectRecords = widget
        .attendanceRecords
        .where((record) =>
    record.subjectId == subjectId)
        .toList();

    if (subjectRecords.isEmpty) return '0.0';

    final presentCount = subjectRecords
        .where((record) => record.present)
        .length;
    final percentage = (presentCount /
        subjectRecords.length) * 100;

    return percentage.toStringAsFixed(1);
  }

  Future<void> _submitAttendance() async {
    final selectedSubjectIds = _selectedSubjects
        .entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedSubjectIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
              'Please select at least one subject'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
                10),
          ),
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final now = DateTime.now();

      // CHECK: Has attendance already been submitted today?
      final hasAttendanceToday = await SupabaseService
          .hasAttendanceForToday();

      if (hasAttendanceToday) {
        if (mounted) {
          ScaffoldMessenger
              .of(context)
              .showSnackBar(
            SnackBar(
              content: const Text(
                  'You have already submitted attendance today'),
              backgroundColor: Colors.orange
                  .shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius
                    .circular(10),
              ),
            ),
          );
        }
        return;
      }

      // Only submit attendance for the FIRST selected subject
      final firstSubjectId = selectedSubjectIds
          .first;

      final newRecord = AttendanceRecord(
        id: 'att_${DateTime
            .now()
            .millisecondsSinceEpoch}',
        date: now,
        subjectId: firstSubjectId,
        present: true,
        late: false,
        checkInTime: now,
      );

      // Use SupabaseService to add the record
      final result = await SupabaseService
          .addAttendanceRecord(newRecord);

      if (result == null) {
        if (mounted) {
          ScaffoldMessenger
              .of(context)
              .showSnackBar(
            SnackBar(
              content: const Text(
                  'Attendance already submitted today'),
              backgroundColor: Colors.orange
                  .shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius
                    .circular(10),
              ),
            ),
          );
        }
        return;
      }

      // Add to local list for immediate UI update
      widget.attendanceRecords.insert(0, result);

      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          SnackBar(
            content: const Text(
                'Attendance marked successfully'),
            backgroundColor: Colors.green
                .shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10),
            ),
          ),
        );

        setState(() {
          _selectedSubjects.clear();
        });

        widget.onAttendanceMarked();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger
            .of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
                'Error saving attendance: ${e
                    .toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                  10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }
}