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
    final bottomPad = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;
    final screenWidth = MediaQuery.of(context).size.width;

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
              screenWidth < 360 ? 12 : 16,
              16,
              screenWidth < 360 ? 12 : 16,
              16 + bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(screenWidth),
              SizedBox(height: screenWidth < 360 ? 16 : 20),
              _buildMarkAttendanceCard(screenWidth),
              SizedBox(height: screenWidth < 360 ? 16 : 20),
              _buildRecentAttendanceSection(screenWidth),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    final isSmall = screenWidth < 360;
    final isMedium = screenWidth < 400;

    return Container(
      padding: EdgeInsets.all(isSmall ? 12 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'Attendance Tracking',
                  style: TextStyle(
                    fontSize: isSmall ? 18 : isMedium ? 22 : 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ),
              if (screenWidth >= 360)
                const SizedBox(width: 8),
            ],
          ),
          SizedBox(height: isSmall ? 4 : 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${widget.attendanceRecords.length} total records',
                style: TextStyle(
                  fontSize: isSmall ? 11 : 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: isSmall ? 8 : 12,
                    vertical: isSmall ? 4 : 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400,
                      Colors.green.shade400
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 10 : 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMarkAttendanceCard(double screenWidth) {
    final isSmall = screenWidth < 360;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(isSmall ? 12 : 16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isSmall ? 8 : 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.green.shade400
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.check_circle_outline_rounded,
                    color: Colors.white,
                    size: isSmall ? 18 : 20,
                  ),
                ),
                SizedBox(width: isSmall ? 8 : 12),
                Text(
                  'Mark Attendance',
                  style: TextStyle(
                    fontSize: isSmall ? 16 : 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2D3748),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          widget.subjects.isEmpty
              ? _buildEmptySubjectsState(screenWidth)
              : Column(
            children: [
              ...widget.subjects.map((subject) =>
                  _buildSubjectTile(subject, screenWidth)),
              Padding(
                padding: EdgeInsets.all(isSmall ? 12 : 16),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.green.shade400
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submitAttendance,
                    icon: _isSubmitting
                        ? SizedBox(
                      width: isSmall ? 18 : 20,
                      height: isSmall ? 18 : 20,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Icon(Icons.check_rounded, size: isSmall ? 18 : 20),
                    label: Text(
                      _isSubmitting ? 'Submitting...' : 'Submit Attendance',
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.transparent,
                      minimumSize: Size.fromHeight(isSmall ? 44 : 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
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

  Widget _buildSubjectTile(Subject subject, double screenWidth) {
    final isSelected = _selectedSubjects[subject.id] ?? false;
    final percentage = _calculateAttendancePercentage(subject.id);
    final isSmall = screenWidth < 360;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedSubjects[subject.id] = !isSelected;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: isSmall ? 8 : 12,
            vertical: isSmall ? 4 : 6),
        padding: EdgeInsets.all(isSmall ? 10 : 12),
        decoration: BoxDecoration(
          color: isSelected ? subject.color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? subject.color : Colors.grey.shade200,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: isSmall ? 44 : 48,
              height: isSmall ? 44 : 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    subject.color,
                    subject.color.withOpacity(0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: subject.color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  subject.name.isNotEmpty ? subject.name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 18 : 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(width: isSmall ? 10 : 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmall ? 13 : 14,
                      color: const Color(0xFF2D3748),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: isSmall ? 6 : 8,
                            vertical: 2),
                        decoration: BoxDecoration(
                          color: _getPercentageColor(double.parse(percentage)),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$percentage%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isSmall ? 10 : 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'attendance',
                          style: TextStyle(
                            fontSize: isSmall ? 10 : 11,
                            color: Colors.grey.shade600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: isSmall ? 24 : 26,
              height: isSmall ? 24 : 26,
              decoration: BoxDecoration(
                color: isSelected ? subject.color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? subject.color : Colors.grey.shade400,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: isSelected
                  ? Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: isSmall ? 16 : 18,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySubjectsState(double screenWidth) {
    final isSmall = screenWidth < 360;

    return Padding(
      padding: EdgeInsets.all(isSmall ? 24 : 32),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(isSmall ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.book_outlined,
                size: isSmall ? 44 : 52,
                color: Colors.grey.shade400,
              ),
            ),
            SizedBox(height: isSmall ? 12 : 16),
            Text(
              'No subjects available',
              style: TextStyle(
                fontSize: isSmall ? 14 : 15,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: isSmall ? 4 : 8),
            Text(
              'Add subjects first to mark attendance',
              style: TextStyle(
                fontSize: isSmall ? 11 : 12,
                color: Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAttendanceSection(double screenWidth) {
    final isSmall = screenWidth < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: isSmall ? 12 : 16,
              vertical: isSmall ? 10 : 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Icons.history_rounded,
                  color: const Color(0xFF2D3748),
                  size: isSmall ? 18 : 20),
              SizedBox(width: isSmall ? 6 : 8),
              Text(
                'Recent Attendance',
                style: TextStyle(
                  fontSize: isSmall ? 16 : 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmall ? 10 : 12),
        widget.attendanceRecords.isEmpty
            ? _buildEmptyRecordsState(screenWidth)
            : Column(
          children: widget.attendanceRecords.take(15).map((record) {
            final subject = widget.subjects.firstWhere(
                  (s) => s.id == record.subjectId,
              orElse: () => Subject.fallback(),
            );
            return _buildAttendanceRecord(record, subject, screenWidth);
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildEmptyRecordsState(double screenWidth) {
    final isSmall = screenWidth < 360;

    return Container(
      padding: EdgeInsets.all(isSmall ? 24 : 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
              padding: EdgeInsets.all(isSmall ? 16 : 20),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_available_rounded,
                size: isSmall ? 44 : 52,
                color: Colors.green.shade300,
              ),
            ),
            SizedBox(height: isSmall ? 12 : 16),
            Text(
              'No attendance records yet',
              style: TextStyle(
                fontSize: isSmall ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2D3748),
              ),
            ),
            SizedBox(height: isSmall ? 4 : 8),
            Text(
              'Mark attendance to see records here',
              style: TextStyle(
                fontSize: isSmall ? 11 : 12,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceRecord(AttendanceRecord record, Subject subject, double screenWidth) {
    final isSmall = screenWidth < 360;

    return Container(
      margin: EdgeInsets.only(bottom: isSmall ? 8 : 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: record.present ? Colors.green.shade100 : Colors.red.shade100,
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
        contentPadding: EdgeInsets.symmetric(
            horizontal: isSmall ? 10 : 12,
            vertical: isSmall ? 6 : 8),
        leading: Container(
          width: isSmall ? 44 : 48,
          height: isSmall ? 44 : 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                subject.color,
                subject.color.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: subject.color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              subject.name.isNotEmpty ? subject.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmall ? 18 : 20,
                color: Colors.white,
              ),
            ),
          ),
        ),
        title: Text(
          subject.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: isSmall ? 13 : 14,
            color: const Color(0xFF2D3748),
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: isSmall ? 11 : 12,
                      color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    '${record.date.day}/${record.date.month}/${record.date.year}',
                    style: TextStyle(
                        fontSize: isSmall ? 11 : 12,
                        color: Colors.grey.shade700),
                  ),
                ],
              ),
              if (record.checkInTime != null) ...[
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: isSmall ? 11 : 12,
                        color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      'Check-in: ${record.checkInTime!.hour}:${record.checkInTime!.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                          fontSize: isSmall ? 10 : 11,
                          color: Colors.grey.shade700),
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
                padding: EdgeInsets.all(isSmall ? 4 : 6),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(
                  Icons.access_time_rounded,
                  color: Colors.orange.shade700,
                  size: isSmall ? 16 : 18,
                ),
              ),
            SizedBox(width: isSmall ? 4 : 6),
            Container(
              padding: EdgeInsets.all(isSmall ? 4 : 6),
              decoration: BoxDecoration(
                color: record.present ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                record.present ? Icons.check_circle_rounded : Icons.cancel_rounded,
                color: record.present ? Colors.green.shade700 : Colors.red.shade700,
                size: isSmall ? 18 : 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 75) return Colors.green.shade600;
    if (percentage >= 50) return Colors.orange.shade600;
    return Colors.red.shade600;
  }

  String _calculateAttendancePercentage(String subjectId) {
    final subjectRecords = widget.attendanceRecords
        .where((record) => record.subjectId == subjectId)
        .toList();

    if (subjectRecords.isEmpty) return '0.0';

    final presentCount = subjectRecords
        .where((record) => record.present)
        .length;
    final percentage = (presentCount / subjectRecords.length) * 100;

    return percentage.toStringAsFixed(1);
  }

  Future<void> _submitAttendance() async {
    final selectedSubjectIds = _selectedSubjects.entries
        .where((entry) => entry.value)
        .map((entry) => entry.key)
        .toList();

    if (selectedSubjectIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select at least one subject'),
          backgroundColor: Colors.orange.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
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
      int successCount = 0;
      int alreadyMarkedCount = 0;
      List<AttendanceRecord> newRecords = [];

      for (final subjectId in selectedSubjectIds) {
        final newRecord = AttendanceRecord(
          id: 'att_${DateTime.now().millisecondsSinceEpoch}_$subjectId',
          date: now,
          subjectId: subjectId,
          present: true,
          late: false,
          checkInTime: now,
        );

        final result = await SupabaseService.addAttendanceRecord(newRecord);

        if (result != null) {
          newRecords.add(result);
          successCount++;
        } else {
          alreadyMarkedCount++;
        }

        await Future.delayed(const Duration(milliseconds: 10));
      }

      if (successCount == 0 && alreadyMarkedCount > 0) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  alreadyMarkedCount == 1
                      ? 'Attendance already submitted for this subject today'
                      : 'Attendance already submitted for all selected subjects today'),
              backgroundColor: Colors.orange.shade700,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
        return;
      }

      for (final record in newRecords.reversed) {
        widget.attendanceRecords.insert(0, record);
      }

      if (mounted) {
        String message = '';
        if (successCount > 0 && alreadyMarkedCount > 0) {
          message = 'Attendance marked for $successCount subject${successCount > 1 ? 's' : ''}. $alreadyMarkedCount already marked today.';
        } else if (successCount > 0) {
          message = successCount == 1
              ? 'Attendance marked successfully'
              : 'Attendance marked for $successCount subjects';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving attendance: ${e.toString()}'),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
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