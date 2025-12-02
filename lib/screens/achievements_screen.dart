import 'package:flutter/material.dart';
import 'dart:math';
import '../models/subject.dart';
import '../models/achievement.dart';
import '../models/tracking_record.dart';

class AchievementsScreen extends StatelessWidget {
  final int attendanceStreak;
  final List<Subject> subjects;
  final List<AttendanceRecord>? attendanceRecords;

  const AchievementsScreen({
    Key? key,
    required this.attendanceStreak,
    required this.subjects,
    this.attendanceRecords,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final achievements = _getAchievements();
    final unlockedCount = achievements.where((a) => a.unlocked).length;
    final bottomPad = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.orange.shade50.withValues(alpha: 0.3),
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievements',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Track your learning journey',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade400, Colors.orange.shade500],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.shade300.withValues(alpha: 0.5),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events, color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Text(
                          '$unlockedCount/${achievements.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Streak Card - Enhanced
              _buildStreakCard(),

              const SizedBox(height: 32),

              // Stats Overview
              _buildStatsOverview(unlockedCount, achievements.length),

              const SizedBox(height: 24),

              // Achievements Grid
              const Text(
                'Your Achievements',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 16),

              Column(
                children: achievements.map((achievement) =>
                    _buildAchievementCard(achievement)
                ).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            Colors.orange.shade400,
            Colors.deepOrange.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade300.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.local_fire_department,
                    size: 56,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '$attendanceStreak',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -2,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Days',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Current Streak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  attendanceStreak > 0
                      ? 'Keep it going! 🎯'
                      : 'Start your streak today!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview(int unlocked, int total) {
    final percentage = (unlocked / total * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              icon: Icons.emoji_events,
              label: 'Unlocked',
              value: '$unlocked',
              color: Colors.amber,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.trending_up,
              label: 'Progress',
              value: '$percentage%',
              color: Colors.green,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStatItem(
              icon: Icons.stars,
              label: 'Remaining',
              value: '${total - unlocked}',
              color: Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color:  Color(700),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: achievement.unlocked
            ? LinearGradient(
          colors: [
            Colors.amber.shade50,
            Colors.orange.shade50.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        )
            : LinearGradient(
          colors: [Colors.white, Colors.grey.shade50],
        ),
        border: Border.all(
          color: achievement.unlocked
              ? Colors.amber.shade300
              : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: achievement.unlocked
            ? [
          BoxShadow(
            color: Colors.amber.shade200.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ]
            : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                gradient: achievement.unlocked
                    ? LinearGradient(
                  colors: [Colors.amber.shade400, Colors.orange.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
                    : LinearGradient(
                  colors: [Colors.grey.shade300, Colors.grey.shade400],
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: achievement.unlocked
                    ? [
                  BoxShadow(
                    color: Colors.amber.shade300.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Icon(
                achievement.icon,
                color: Colors.white,
                size: 36,
              ),
            ),
            const SizedBox(width: 16),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: achievement.unlocked ? Colors.black87 : Colors.grey.shade700,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: achievement.unlocked ? Colors.grey.shade600 : Colors.grey.shade500,
                      fontSize: 14,
                      height: 1.3,
                    ),
                  ),
                  if (!achievement.unlocked) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: achievement.progress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.amber.shade600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${achievement.currentValue} / ${achievement.requiredValue}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 12),

            // Status Badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: achievement.unlocked
                    ? LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade600],
                )
                    : null,
                color: achievement.unlocked ? null : Colors.grey.shade200,
                boxShadow: achievement.unlocked
                    ? [
                  BoxShadow(
                    color: Colors.green.shade300.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
                    : null,
              ),
              child: Icon(
                achievement.unlocked ? Icons.check_circle : Icons.lock_outline,
                color: achievement.unlocked ? Colors.white : Colors.grey.shade400,
                size: achievement.unlocked ? 26 : 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Achievement> _getAchievements() {
    final avgAttendance = subjects.isEmpty
        ? 0.0
        : subjects.map((s) => s.attendanceRate).reduce((a, b) => a + b) / subjects.length;

    final totalAttendance = attendanceRecords?.length ?? 0;
    final onTimeCount = attendanceRecords?.where((r) => r.present && !r.late).length ?? 0;
    final lateCount = attendanceRecords?.where((r) => r.late).length ?? 0;
    final presentCount = attendanceRecords?.where((r) => r.present).length ?? 0;

    return [
      Achievement(
        id: '1',
        title: 'First Day',
        description: 'Attend your first class',
        icon: Icons.celebration,
        unlocked: totalAttendance >= 1,
        requiredValue: 1,
        currentValue: min(totalAttendance, 1),
      ),
      Achievement(
        id: '2',
        title: 'Getting Started',
        description: 'Attend 5 classes',
        icon: Icons.trending_up,
        unlocked: totalAttendance >= 5,
        requiredValue: 5,
        currentValue: min(totalAttendance, 5),
      ),
      Achievement(
        id: '3',
        title: 'Perfect Week',
        description: '7-day attendance streak',
        icon: Icons.star,
        unlocked: attendanceStreak >= 7,
        requiredValue: 7,
        currentValue: min(attendanceStreak, 7),
      ),
      Achievement(
        id: '4',
        title: 'Early Bird',
        description: 'Arrive on time 10 times',
        icon: Icons.wb_sunny,
        unlocked: onTimeCount >= 10,
        requiredValue: 10,
        currentValue: min(onTimeCount, 10),
      ),
      Achievement(
        id: '5',
        title: 'Committed Learner',
        description: 'Attend 25 classes',
        icon: Icons.book,
        unlocked: totalAttendance >= 25,
        requiredValue: 25,
        currentValue: min(totalAttendance, 25),
      ),
      Achievement(
        id: '6',
        title: 'Two Week Warrior',
        description: '14-day attendance streak',
        icon: Icons.military_tech,
        unlocked: attendanceStreak >= 14,
        requiredValue: 14,
        currentValue: min(attendanceStreak, 14),
      ),
      Achievement(
        id: '7',
        title: 'Dedicated Student',
        description: '30-day attendance streak',
        icon: Icons.local_fire_department,
        unlocked: attendanceStreak >= 30,
        requiredValue: 30,
        currentValue: min(attendanceStreak, 30),
      ),
      Achievement(
        id: '8',
        title: 'Half Century',
        description: 'Attend 50 classes',
        icon: Icons.emoji_events,
        unlocked: totalAttendance >= 50,
        requiredValue: 50,
        currentValue: min(totalAttendance, 50),
      ),
      Achievement(
        id: '9',
        title: 'Subject Master',
        description: '95% attendance in all subjects',
        icon: Icons.school,
        unlocked: subjects.isNotEmpty && avgAttendance >= 95,
        requiredValue: 100,
        currentValue: avgAttendance.toInt(),
      ),
      Achievement(
        id: '10',
        title: 'Consistency King',
        description: '60-day attendance streak',
        icon: Icons.calendar_today,
        unlocked: attendanceStreak >= 60,
        requiredValue: 60,
        currentValue: min(attendanceStreak, 60),
      ),
      Achievement(
        id: '11',
        title: 'Punctuality Pro',
        description: 'Never late for 20 classes',
        icon: Icons.timer,
        unlocked: onTimeCount >= 20 && lateCount == 0,
        requiredValue: 20,
        currentValue: min(onTimeCount, 20),
      ),
      Achievement(
        id: '12',
        title: 'Century Club',
        description: 'Attend 100 classes',
        icon: Icons.workspace_premium,
        unlocked: totalAttendance >= 100,
        requiredValue: 100,
        currentValue: min(totalAttendance, 100),
      ),
      Achievement(
        id: '13',
        title: 'Semester Champion',
        description: '90-day attendance streak',
        icon: Icons.diamond,
        unlocked: attendanceStreak >= 90,
        requiredValue: 90,
        currentValue: min(attendanceStreak, 90),
      ),
      Achievement(
        id: '14',
        title: 'Perfect Attendance',
        description: '100% attendance with 30+ classes',
        icon: Icons.stars,
        unlocked: totalAttendance >= 30 && presentCount == totalAttendance,
        requiredValue: 30,
        currentValue: min(totalAttendance, 30),
      ),
      Achievement(
        id: '15',
        title: 'Time Master',
        description: 'Arrive on time for 50 classes',
        icon: Icons.access_time,
        unlocked: onTimeCount >= 50,
        requiredValue: 50,
        currentValue: min(onTimeCount, 50),
      ),
    ];
  }
}