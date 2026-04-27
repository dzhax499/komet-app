import 'package:flutter/material.dart';

class AssignmentCard extends StatelessWidget {
  final String title;
  final String deadline;
  final bool isStudent;
  final VoidCallback? onTap;

  const AssignmentCard({
    super.key,
    required this.title,
    required this.deadline,
    this.isStudent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 8,
      ),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF19320C), // Dark green
            Color(0xFF6F8226), // Olive green
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.assignment,
              color: Color(0xFF4C661D),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Deadline : $deadline',
                  style: const TextStyle(
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
                    child: CustomPaint(
                      painter: _PlayIconPainter(),
                    ),
                  ),
                ),
              ),
            ),
        ],
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
