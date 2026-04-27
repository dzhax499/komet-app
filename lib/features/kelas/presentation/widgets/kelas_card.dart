import 'package:flutter/material.dart';
import '../../../../core/models/kelas_model.dart';

class KelasCard extends StatelessWidget {
  final KelasModel kelas;
  final VoidCallback onTap;

  const KelasCard({
    super.key,
    required this.kelas,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String initial = kelas.nama.isNotEmpty
        ? kelas.nama
            .substring(0, kelas.nama.length > 2 ? 2 : kelas.nama.length)
            .toUpperCase()
        : "C";

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6B7E25),
              Color(0xFF1F410F),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Inisial Bulatan
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
                // Kode Kelas Tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C7573),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    'Code: ${kelas.kodeKelas}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Info Bar (Students, Tasks, Mails)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoTag(
                  Icons.people,
                  kelas.siswaIds.isEmpty
                      ? 'Students'
                      : '${kelas.siswaIds.length} Students',
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white54,
                ),
                _buildInfoTag(
                  Icons.assignment,
                  kelas.assignmentIds.isEmpty
                      ? 'Tasks'
                      : '${kelas.assignmentIds.length} Tasks',
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: Colors.white54,
                ),
                _buildInfoTag(
                  Icons.mail,
                  'Mails',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3810),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
