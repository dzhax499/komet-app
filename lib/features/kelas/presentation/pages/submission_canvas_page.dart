import 'package:flutter/material.dart';

class SubmissionCanvasPage extends StatelessWidget {
  final String assignmentId;
  final String assignmentTitle;
  final String deadline;

  const SubmissionCanvasPage({
    super.key,
    required this.assignmentId,
    required this.assignmentTitle,
    required this.deadline,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(assignmentTitle),
        backgroundColor: const Color(0xFF1F410F),
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Kanvas akan segera hadir...'),
      ),
    );
  }
}
