import 'dart:ui';
import 'package:flutter/material.dart';

class CreateAssignmentDialog extends StatefulWidget {
  final Function(String assignmentName, String deadline) onCreated;

  const CreateAssignmentDialog({super.key, required this.onCreated});

  @override
  State<CreateAssignmentDialog> createState() => _CreateAssignmentDialogState();
}

class _CreateAssignmentDialogState extends State<CreateAssignmentDialog> {
  final _assignmentController = TextEditingController();
  final _deadlineController = TextEditingController();

  @override
  void dispose() {
    _assignmentController.dispose();
    _deadlineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackdropFilter(
      filter: ImageFilter.blur(
        sigmaX: 8,
        sigmaY: 8,
      ),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 32,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.2),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 30,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Create Task',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildTransparentInput(
                controller: _assignmentController,
                hint: 'Task ...',
                icon: Icons.assignment,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(
                      const Duration(days: 1),
                    ),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2101),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: Color(0xFF6B7E25),
                            onPrimary: Colors.white,
                            onSurface: Colors.black87,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _deadlineController.text =
                          pickedDate.toString().split(' ')[0];
                    });
                  }
                },
                child: AbsorbPointer(
                  child: _buildTransparentInput(
                    controller: _deadlineController,
                    hint: 'Deadline ...',
                    icon: Icons.calendar_today,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildCreateButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransparentInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.8),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          color: Colors.white,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: Colors.white70,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildCreateButton(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFE8F6F8),
            Color(0xFF90BAC8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (_assignmentController.text.isNotEmpty) {
              widget.onCreated(
                _assignmentController.text,
                _deadlineController.text,
              );
              Navigator.pop(context);
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              vertical: 14,
            ),
            child: Center(
              child: Text(
                'Create',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
