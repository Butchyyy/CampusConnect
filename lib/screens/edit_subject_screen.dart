import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/supabase_service.dart';

class EditSubjectScreen extends StatefulWidget {
  final Subject subject;

  const EditSubjectScreen({Key? key, required this.subject}) : super(key: key);

  @override
  State<EditSubjectScreen> createState() => _EditSubjectScreenState();
}

class _EditSubjectScreenState extends State<EditSubjectScreen> {
  late TextEditingController _nameController;
  late TextEditingController _codeController;
  late TextEditingController _instructorController;
  late int _credits;
  late Color _selectedColor;

  final List<Color> _availableColors = [
    Colors.purple.shade200,
    Colors.amber.shade200,
    Colors.green.shade200,
    Colors.orange.shade200,
    Colors.blue.shade200,
    Colors.red.shade200,
    Colors.teal.shade200,
    Colors.pink.shade200,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.subject.name);
    _codeController = TextEditingController(text: widget.subject.code);
    _instructorController = TextEditingController(text: widget.subject.instructor);
    _credits = widget.subject.credits;
    _selectedColor = widget.subject.color;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _instructorController.dispose();
    super.dispose();
  }

  void _saveSubject() {
    if (_nameController.text.trim().isEmpty || _codeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final updatedSubject = widget.subject.copyWith(
      name: _nameController.text.trim(),
      code: _codeController.text.trim(),
      instructor: _instructorController.text.trim(),
      credits: _credits,
      color: _selectedColor,
    );

    Navigator.pop(context, updatedSubject);
  }

  Future<void> _deleteSubject() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subject'),
        content: Text('Are you sure you want to delete "${widget.subject.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleting subject...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Delete from database
      final success = await SupabaseService.deleteSubject(widget.subject.id);

      if (mounted) {
        if (success) {
          // Wait a moment to ensure database deletion is complete
          await Future.delayed(const Duration(milliseconds: 500));

          // Pop with a special map containing deletion info
          // This tells the dashboard that a subject was deleted
          Navigator.pop(context, {
            'action': 'delete',
            'subjectId': widget.subject.id,
          });

        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to delete subject')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Subject'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteSubject,
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveSubject,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Subject Name *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _codeController,
              decoration: const InputDecoration(
                labelText: 'Subject Code *',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _instructorController,
              decoration: const InputDecoration(
                labelText: 'Instructor',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Credits',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [1, 2, 3, 4, 5].map((credit) {
                return ChoiceChip(
                  label: Text('$credit'),
                  selected: _credits == credit,
                  onSelected: (selected) {
                    if (selected) setState(() => _credits = credit);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            const Text(
              'Color',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                final isSelected = _selectedColor.value == color.value;
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? Colors.black : Colors.transparent,
                        width: 3,
                      ),
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}