import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/assignment.dart';
import '../models/subject.dart';
import 'add_assignment_screen.dart';

class AssignmentsScreen extends StatefulWidget {
  final List<Assignment> assignments;
  final List<Subject> subjects;
  final Function(Assignment)? onAssignmentAdded;
  final Function(Assignment)? onAssignmentUpdated;
  final Function(String)? onAssignmentDeleted;

  const AssignmentsScreen({
    Key? key,
    required this.assignments,
    required this.subjects,
    this.onAssignmentAdded,
    this.onAssignmentUpdated,
    this.onAssignmentDeleted,
  }) : super(key: key);

  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> {
  String _filter = 'all'; // all, pending, completed

  List<Assignment> get _filteredAssignments {
    List<Assignment> filtered;

    switch (_filter) {
      case 'pending':
        filtered = widget.assignments.where((a) => !a.completed).toList();
        break;
      case 'completed':
        filtered = widget.assignments.where((a) => a.completed).toList();
        break;
      default:
        filtered = widget.assignments;
    }

    // Sort: overdue first, then by due date
    filtered.sort((a, b) {
      if (a.completed != b.completed) {
        return a.completed ? 1 : -1;
      }
      if (a.isOverdue != b.isOverdue) {
        return a.isOverdue ? -1 : 1;
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight;

    final overdueCount = widget.assignments.where((a) => a.isOverdue && !a.completed).length;
    final dueTodayCount = widget.assignments.where((a) => a.isDueToday && !a.completed).length;
    final dueTomorrowCount = widget.assignments.where((a) => a.isDueTomorrow && !a.completed).length;

    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.pink.shade50,
            ],
          ),
        ),
        child: Column(
          children: [
            // Header with padding
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 20),
                  if (overdueCount > 0 || dueTodayCount > 0 || dueTomorrowCount > 0)
                    _buildQuickStats(overdueCount, dueTodayCount, dueTomorrowCount),
                  if (overdueCount > 0 || dueTodayCount > 0 || dueTomorrowCount > 0)
                    const SizedBox(height: 20),
                  _buildFilterTabs(),
                ],
              ),
            ),

            // Assignment list
            Expanded(
              child: widget.assignments.isEmpty
                  ? _buildEmptyState()
                  : _filteredAssignments.isEmpty
                  ? _buildEmptyFilterState()
                  : ListView.builder(
                padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomPad),
                itemCount: _filteredAssignments.length,
                itemBuilder: (context, index) {
                  return _buildAssignmentCard(_filteredAssignments[index]);
                },
              ),
            ),
          ],
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assignments',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${widget.assignments.length} total tasks',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.pink.shade400],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: widget.subjects.isEmpty ? null : () => _addAssignment(),
              icon: const Icon(Icons.add_rounded, size: 20),
              label: const Text('Add'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(int overdueCount, int dueTodayCount, int dueTomorrowCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange.shade700, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Quick Stats',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              if (overdueCount > 0)
                _buildStatChip(
                  '🔴 $overdueCount Overdue',
                  Colors.red.shade600,
                ),
              if (dueTodayCount > 0)
                _buildStatChip(
                  '🟡 $dueTodayCount Due Today',
                  Colors.orange.shade600,
                ),
              if (dueTomorrowCount > 0)
                _buildStatChip(
                  '🔵 $dueTomorrowCount Tomorrow',
                  Colors.blue.shade600,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1.5),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Expanded(child: _buildFilterChip('All', 'all')),
          Expanded(child: _buildFilterChip('Pending', 'pending')),
          Expanded(child: _buildFilterChip('Completed', 'completed')),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return GestureDetector(
      onTap: () => setState(() => _filter = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
            colors: [Colors.purple.shade400, Colors.pink.shade400],
          )
              : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.purple.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 60,
                color: Colors.purple.shade300,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No assignments yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.subjects.isEmpty
                  ? 'Add subjects first'
                  : 'Tap "Add" to create an assignment',
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

  Widget _buildEmptyFilterState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_list_off_rounded,
                size: 60,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No ${_filter == 'pending' ? 'pending' : 'completed'} assignments',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try selecting a different filter',
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

  Widget _buildAssignmentCard(Assignment assignment) {
    final subject = widget.subjects.firstWhere(
          (s) => s.id == assignment.subjectId,
      orElse: () => Subject.fallback(),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: assignment.isOverdue && !assignment.completed
              ? Colors.red.shade200
              : Colors.grey.shade200,
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
        contentPadding: const EdgeInsets.all(16),
        leading: GestureDetector(
          onTap: () {
            if (widget.onAssignmentUpdated != null) {
              widget.onAssignmentUpdated!(
                assignment.copyWith(
                  completed: !assignment.completed,
                  completedDate: !assignment.completed ? DateTime.now() : null,
                ),
              );
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: assignment.completed
                  ? LinearGradient(
                colors: [Colors.green.shade400, Colors.green.shade600],
              )
                  : LinearGradient(
                colors: [Colors.grey.shade200, Colors.grey.shade300],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: assignment.completed ? Colors.green.shade700 : Colors.grey.shade400,
                width: 2,
              ),
              boxShadow: assignment.completed
                  ? [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
                  : null,
            ),
            child: assignment.completed
                ? const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 28,
            )
                : null,
          ),
        ),
        title: Text(
          assignment.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: assignment.completed ? TextDecoration.lineThrough : null,
            color: assignment.completed ? Colors.grey.shade500 : const Color(0xFF2D3748),
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: subject.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: subject.color.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      subject.code,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: subject.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: assignment.priorityColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: assignment.priorityColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      assignment.priorityLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: assignment.priorityColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14,
                    color: assignment.isOverdue && !assignment.completed
                        ? Colors.red.shade700
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatDueDate(assignment),
                      style: TextStyle(
                        fontSize: 13,
                        color: assignment.isOverdue && !assignment.completed
                            ? Colors.red.shade700
                            : Colors.grey.shade700,
                        fontWeight: assignment.isOverdue && !assignment.completed
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
              if (assignment.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  assignment.description,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
        trailing: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: PopupMenuButton(
            icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade700),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit_rounded, size: 20),
                    SizedBox(width: 12),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Delete', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit') {
                _editAssignment(assignment);
              } else if (value == 'delete') {
                _deleteAssignment(assignment);
              }
            },
          ),
        ),
      ),
    );
  }

  String _formatDueDate(Assignment assignment) {
    if (assignment.isOverdue && !assignment.completed) {
      return 'Overdue - ${DateFormat('MMM d, y').format(assignment.dueDate)}';
    } else if (assignment.isDueToday) {
      return 'Due today at ${DateFormat('HH:mm').format(assignment.dueDate)}';
    } else if (assignment.isDueTomorrow) {
      return 'Due tomorrow at ${DateFormat('HH:mm').format(assignment.dueDate)}';
    } else if (assignment.daysUntilDue <= 7) {
      return 'Due in ${assignment.daysUntilDue} days - ${DateFormat('MMM d').format(assignment.dueDate)}';
    } else {
      return 'Due ${DateFormat('MMM d, y').format(assignment.dueDate)}';
    }
  }

  void _addAssignment() async {
    final newAssignment = await Navigator.push<Assignment>(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssignmentScreen(subjects: widget.subjects),
      ),
    );

    if (newAssignment != null && widget.onAssignmentAdded != null && mounted) {
      widget.onAssignmentAdded!(newAssignment);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Assignment added successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _editAssignment(Assignment assignment) async {
    final updatedAssignment = await Navigator.push<Assignment>(
      context,
      MaterialPageRoute(
        builder: (context) => AddAssignmentScreen(
          subjects: widget.subjects,
          assignment: assignment,
        ),
      ),
    );

    if (updatedAssignment != null && widget.onAssignmentUpdated != null && mounted) {
      widget.onAssignmentUpdated!(updatedAssignment);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Assignment updated successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  void _deleteAssignment(Assignment assignment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Assignment',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text('Are you sure you want to delete "${assignment.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && widget.onAssignmentDeleted != null && mounted) {
      widget.onAssignmentDeleted!(assignment.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Assignment deleted successfully'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}