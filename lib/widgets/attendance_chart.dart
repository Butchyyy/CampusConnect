import 'package:flutter/material.dart';
import 'dart:math';
import '../models/tracking_record.dart';

class AttendanceChart extends StatelessWidget {
  final List<AttendanceRecord> attendanceRecords;

  const AttendanceChart({
    Key? key,
    required this.attendanceRecords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final last7Days = List.generate(
      7,
          (i) => DateTime.now().subtract(Duration(days: 6 - i)),
    );

    final attendanceByDay = last7Days.map((day) {
      return attendanceRecords.where((r) =>
      r.date.year == day.year &&
          r.date.month == day.month &&
          r.date.day == day.day &&
          r.present
      ).length;
    }).toList();

    final maxAttendance = attendanceByDay.isEmpty
        ? 1
        : attendanceByDay.reduce(max).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final height = maxAttendance > 0
                    ? (attendanceByDay[index] / maxAttendance * 120)
                    : 20.0;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      '${attendanceByDay[index]}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 30,
                      height: height,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade400,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getDayAbbr(last7Days[index].weekday),
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayAbbr(int day) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[day - 1];
  }
}