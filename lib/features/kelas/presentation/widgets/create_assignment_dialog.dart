import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withValues(alpha: 0.4),
                Colors.white.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Create Task',
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              _buildGlassInput(
                controller: _assignmentController,
                hint: 'Task ...',
                icon: Icons.assignment_outlined,
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now().add(const Duration(days: 1)),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _deadlineController.text =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    });
                  }
                },
                child: AbsorbPointer(
                  child: _buildGlassInput(
                    controller: _deadlineController,
                    hint: 'Deadline ...',
                    icon: Icons.calendar_today_outlined,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _buildGlassButton(
                label: 'Create',
                onTap: () {
                  if (_assignmentController.text.isNotEmpty) {
                    widget.onCreated(
                      _assignmentController.text,
                      _deadlineController.text,
                    );
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: TextField(
        controller: controller,
        style: GoogleFonts.nunito(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildGlassButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDFBEE), Color(0xFF7AB3C4)],
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}
