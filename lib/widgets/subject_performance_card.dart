import 'package:flutter/material.dart';
import '../models/subject.dart';

class SubjectPerformanceCard extends StatelessWidget {
  final Subject subject;

  const SubjectPerformanceCard({
    Key? key,
    required this.subject,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final attendancePercentage = subject.attendanceRate;
    final isComplete = attendancePercentage >= 100.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: subject.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.book, color: subject.color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      subject.code,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              // Attendance Percentage Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getPercentageColor(attendancePercentage).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getPercentageColor(attendancePercentage).withOpacity(0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isComplete ? Icons.check_circle : Icons.trending_up,
                      color: _getPercentageColor(attendancePercentage),
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${attendancePercentage.toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: _getPercentageColor(attendancePercentage),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subject.instructor.isEmpty ? 'No instructor' : subject.instructor,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),
              Icon(Icons.credit_card, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                '${subject.credits} credits',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
          if (subject.totalClasses != null && subject.totalClasses! > 0) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.check_circle, size: 16, color: Colors.green.shade600),
                const SizedBox(width: 4),
                Text(
                  'Attendance: ${subject.attendedClasses}/${subject.totalClasses}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Color _getPercentageColor(double percentage) {
    if (percentage >= 100.0) {
      return Colors.green.shade700;
    } else if (percentage >= 75.0) {
      return Colors.blue.shade700;
    } else if (percentage >= 50.0) {
      return Colors.orange.shade700;
    } else {
      return Colors.red.shade700;
    }
  }
}