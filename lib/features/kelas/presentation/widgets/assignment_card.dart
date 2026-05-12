import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

class AssignmentCard extends StatelessWidget {
  final String title;
  final String deadline;
  final bool isStudent;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const AssignmentCard({
    super.key,
    required this.title,
    required this.deadline,
    this.isStudent = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Slidable(
          key: ValueKey(title + deadline),
          // Swipe Right to reveal Edit
          startActionPane: onEdit != null
              ? ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    CustomSlidableAction(
                      onPressed: (context) => onEdit?.call(),
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.edit_rounded,
                        color: Color(0xFF1A3C0A),
                        size: 32,
                      ),
                    ),
                  ],
                )
              : null,
          // Swipe Left to reveal Delete
          endActionPane: onDelete != null
              ? ActionPane(
                  motion: const DrawerMotion(),
                  extentRatio: 0.25,
                  children: [
                    CustomSlidableAction(
                      onPressed: (context) => onDelete?.call(),
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.delete_rounded,
                        color: Colors.redAccent,
                        size: 32,
                      ),
                    ),
                  ],
                )
              : null,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF1A3C0A), // Dark green
                  Color(0xFF758837), // Olive green
                ],
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: ShaderMask(
                    shaderCallback: (bounds) => const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF1A3C0A), // Dark green
                        Color(0xFF82903C), // Olive green
                      ],
                    ).createShader(bounds),
                    child: const Icon(
                      MingCuteIcons.mgc_task_2_fill,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Deadline : $deadline',
                        style: GoogleFonts.nunito(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isStudent)
                  GestureDetector(
                    onTap: onTap,
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CustomPaint(painter: _PlayIconPainter()),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1F410F)
      ..style = PaintingStyle.fill;

    // Garis vertikal
    final barRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, 3, size.height),
      const Radius.circular(1.5),
    );
    canvas.drawRRect(barRect, paint);

    // Segitiga play dengan ujung sedikit membulat (strokeJoin = round)
    // Gap 3px dari garis (dari x=3 sampai x=6)
    final triangleStartX = 6.0;

    final path = Path();
    path.moveTo(triangleStartX + 1, 1);
    path.lineTo(size.width - 1, size.height / 2);
    path.lineTo(triangleStartX + 1, size.height - 1);
    path.close();

    final trianglePaint = Paint()
      ..color = const Color(0xFF1F410F)
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 2.0;

    canvas.drawPath(path, trianglePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

