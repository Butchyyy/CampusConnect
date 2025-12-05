import 'package:flutter/material.dart';
import '../models/subject.dart';
import '../services/supabase_service.dart';
import '../services/firebase_auth_service.dart';

class AddSubjectScreen extends StatefulWidget {
  final Function(Subject) onSubjectAdded;

  const AddSubjectScreen({
    Key? key,
    required this.onSubjectAdded,
  }) : super(key: key);

  @override
  State<AddSubjectScreen> createState() => _AddSubjectScreenState();
}

class _AddSubjectScreenState extends State<AddSubjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _instructorController = TextEditingController();
  final _creditsController = TextEditingController();

  Color _selectedColor = Colors.blue.shade200;
  bool _isSubmitting = false;

  final List<Color> _availableColors = [
    Colors.blue.shade200,
    Colors.purple.shade200,
    Colors.green.shade200,
    Colors.orange.shade200,
    Colors.red.shade200,
    Colors.pink.shade200,
    Colors.teal.shade200,
    Colors.amber.shade200,
    Colors.indigo.shade200,
    Colors.cyan.shade200,
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _instructorController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text('Add New Subject'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subject Information',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Subject Name
                      TextFormField(
                        controller: _nameController,
                        enabled: !_isSubmitting,
                        decoration: InputDecoration(
                          labelText: 'Subject Name',
                          hintText: 'e.g., Mathematics',
                          prefixIcon: const Icon(Icons.book),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter subject name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Subject Code
                      TextFormField(
                        controller: _codeController,
                        enabled: !_isSubmitting,
                        textCapitalization: TextCapitalization.characters,
                        decoration: InputDecoration(
                          labelText: 'Subject Code',
                          hintText: 'e.g., MATH101',
                          prefixIcon: const Icon(Icons.code),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter subject code';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Instructor Name
                      TextFormField(
                        controller: _instructorController,
                        enabled: !_isSubmitting,
                        textCapitalization: TextCapitalization.words,
                        decoration: InputDecoration(
                          labelText: 'Instructor Name',
                          hintText: 'e.g., Prof. Smith',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter instructor name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Credits
                      TextFormField(
                        controller: _creditsController,
                        enabled: !_isSubmitting,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Credits',
                          hintText: 'e.g., 3',
                          prefixIcon: const Icon(Icons.grade),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter credits';
                          }
                          final credits = int.tryParse(value.trim());
                          if (credits == null || credits <= 0) {
                            return 'Please enter valid credits';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Color Selection
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Choose Color',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: _availableColors.map((color) {
                          final isSelected = _selectedColor == color;
                          return GestureDetector(
                            onTap: _isSubmitting
                                ? null
                                : () {
                              setState(() {
                                _selectedColor = color;
                              });
                            },
                            child: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.black
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ]
                                    : null,
                              ),
                              child: isSelected
                                  ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              )
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isSubmitting ? null : _submitForm,
                  icon: _isSubmitting
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Icon(Icons.add_circle, size: 24),
                  label: Text(
                    _isSubmitting ? 'Adding Subject...' : 'Add Subject',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    _isSubmitting ? Colors.grey : Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      // 🔥 CRITICAL: Prevent double submission
      if (_isSubmitting) {
        print('⚠️ Already submitting, ignoring duplicate call');
        return;
      }

      setState(() => _isSubmitting = true);

      try {
        print('🔵 Checking authentication...');
        final currentUser = FirebaseAuthService.currentUser;

        if (currentUser == null) {
          print('❌ No user logged in!');
          throw Exception('Please sign in to add subjects');
        }

        print('✅ User authenticated: ${currentUser.email}');
        print('🔵 Creating subject object...');

        final newSubject = Subject(
          id: '', // Will be generated by Supabase
          name: _nameController.text.trim(),
          code: _codeController.text.trim().toUpperCase(),
          color: _selectedColor,
          instructor: _instructorController.text.trim(),
          credits: int.parse(_creditsController.text.trim()),
          totalClasses: 0,
          attendedClasses: 0,
        );

        // 🔥 CRITICAL: Don't save here - let HomeScreen handle it!
        print('🔵 Passing subject to callback (HomeScreen will save)...');

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text('Adding ${newSubject.name}...'),
                ),
              ],
            ),
            backgroundColor: Colors.blue.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            duration: const Duration(seconds: 1),
          ),
        );

        // Close the screen
        Navigator.pop(context);

        // Call the callback - HomeScreen will handle the save
        widget.onSubjectAdded(newSubject);
      } catch (e) {
        print('❌ Error in _submitForm: $e');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(e.toString().replaceAll('Exception: ', '')),
                  ),
                ],
              ),
              backgroundColor: Colors.red.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              duration: const Duration(seconds: 4),
            ),
          );

          setState(() => _isSubmitting = false);
        }
      }
    }
  }
}