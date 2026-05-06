import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/submission_model.dart';

class SubmissionCard extends StatelessWidget {
  final SubmissionModel submission;
  final String studentName;
  final String assignmentTitle;
  final VoidCallback? onTap;
  final VoidCallback? onCancel;

  const SubmissionCard({
    super.key,
    required this.submission,
    required this.studentName,
    required this.assignmentTitle,
    this.onTap,
    this.onCancel,
  });

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isReviewed = submission.status == SubmissionStatus.reviewed;
    final hasNeedsRevision = submission.status == SubmissionStatus.needsRevision;
    final hasCancel = onCancel != null;
    
    final hasBottomLayer = isReviewed || hasNeedsRevision || hasCancel;

    Color bottomColor = Colors.transparent;
    Widget? bottomTextWidget;

    if (isReviewed) {
      bottomColor = const Color(0xFF1A3C0A);
      bottomTextWidget = Text(
        'Completed | ${submission.nilai ?? 0} | ${_formatDate(submission.updatedAt)}',
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (hasNeedsRevision) {
      bottomColor = const Color(0xFFD4941A);
      bottomTextWidget = Text(
        'Needs Revision | ${_formatDate(submission.updatedAt)}',
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      );
    } else if (hasCancel) {
      bottomColor = const Color(0xFFF12929);
      bottomTextWidget = Text(
        'Cancel',
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    Widget card = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 4,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 100,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF1A3C0A),
                  Color(0xFF758837),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 4,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    studentName.isNotEmpty
                        ? studentName[0].toUpperCase()
                        : '?',
                    style: GoogleFonts.nunito(
                      color: Colors.blueGrey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        studentName,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isReviewed
                            ? 'Completed'
                            : (hasCancel && !hasNeedsRevision ? 'Waiting for review...' : 'Review'),
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Color(0xFF1A3C0A),
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 4,
            ),
            child: Center(
              child: Text(
                'Task : $assignmentTitle',
                style: GoogleFonts.nunito(
                  color: Colors.black87,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (hasBottomLayer) {
      card = Container(
        decoration: BoxDecoration(
          color: bottomColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            card,
            if (hasCancel && !isReviewed && !hasNeedsRevision)
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  color: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Center(child: bottomTextWidget),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Center(child: bottomTextWidget),
              ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap ?? () {
        context.pushNamed('reviewDetail', extra: {
          'submission': submission,
          'assignmentTitle': assignmentTitle,
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Column(
          children: [
            card,
            if ((isReviewed || hasNeedsRevision) &&
                (submission.komentarUmum?.isNotEmpty ?? false)) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Text(
                  submission.komentarUmum!,
                  style: GoogleFonts.nunito(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
