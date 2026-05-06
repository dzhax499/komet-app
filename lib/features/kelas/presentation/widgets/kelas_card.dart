import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../../../../core/models/kelas_model.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import 'package:google_fonts/google_fonts.dart';

class KelasCard extends StatelessWidget {
  final KelasModel kelas;
  final VoidCallback onTap;
  final VoidCallback? onEdit;

  const KelasCard({
    super.key,
    required this.kelas,
    required this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    String initial = kelas.nama.isNotEmpty
        ? kelas.nama
              .substring(0, kelas.nama.length > 2 ? 2 : kelas.nama.length)
              .toUpperCase()
        : "C";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Slidable(
          key: ValueKey(kelas.id),
          startActionPane: ActionPane(
            motion: const DrawerMotion(),
            extentRatio: 0.2,
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
          ),
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B7E25), Color(0xFF1F410F)],
                ),
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
                            style: GoogleFonts.nunito(
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
                          style: GoogleFonts.nunito(
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
                        '${kelas.siswaIds.length} Student',
                      ),
                      Container(width: 1, height: 24, color: Colors.white54),
                      _buildInfoTag(
                        MingCuteIcons.mgc_task_2_fill,
                        '${kelas.assignmentIds.length} Task',
                      ),
                      Container(width: 1, height: 24, color: Colors.white54),
                      _buildInfoTag(Icons.mail, '0 Mail'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3810),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.nunito(
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

