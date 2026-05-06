import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/submission_model.dart';
import '../../../../core/models/assignment_model.dart';
import '../../../assignment/presentation/bloc/assignment_bloc.dart';
import '../../../assignment/presentation/bloc/assignment_event.dart';
import '../../../assignment/presentation/bloc/assignment_state.dart';
import '../../../submission/presentation/bloc/submission_bloc.dart';
import '../../../submission/presentation/bloc/submission_event.dart';
import '../../../submission/presentation/bloc/submission_state.dart';
import '../bloc/kelas_bloc.dart';
import '../widgets/komet_action_dialog.dart';

class StudentDetailPage extends StatefulWidget {
  final UserModel student;
  final String kelasId;

  const StudentDetailPage({
    super.key,
    required this.student,
    required this.kelasId,
  });

  @override
  State<StudentDetailPage> createState() => _StudentDetailPageState();
}

class _StudentDetailPageState extends State<StudentDetailPage> {
  late SubmissionBloc _submissionBloc;
  late AssignmentBloc _assignmentBloc;

  @override
  void initState() {
    super.initState();
    _submissionBloc = sl<SubmissionBloc>();
    _assignmentBloc = sl<AssignmentBloc>();
    _submissionBloc.add(GetSubmissionsByStudentEvent(widget.student.id));
    _assignmentBloc.add(GetAssignmentsByClassEvent(widget.kelasId));
  }

  @override
  void dispose() {
    _submissionBloc.close();
    _assignmentBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _submissionBloc),
        BlocProvider.value(value: _assignmentBloc),
      ],
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF86B3C0), Color(0xFFE3E2E0)],
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context),
                _buildStudentCard(context),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Text(
                    'History',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(child: _buildSubmissionHistory()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Teacher Hub',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              _buildProfileAvatarFromContext(context, size: 56),
            ],
          ),
          const SizedBox(height: 8),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.reply, color: Colors.white, size: 36),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatarFromContext(BuildContext context, {required double size}) {
    // Ambil dari AuthBloc jika ada — untuk header avatar guru
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF507877),
      ),
      child: const Icon(Icons.person, color: Colors.white, size: 28),
    );
  }

  Widget _buildStudentCard(BuildContext context) {
    final student = widget.student;
    ImageProvider? imageProvider;
    if (student.photoUrl != null && student.photoUrl!.isNotEmpty) {
      if (student.photoUrl!.startsWith('http')) {
        imageProvider = NetworkImage(student.photoUrl!);
      } else {
        imageProvider = FileImage(File(student.photoUrl!));
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF507877),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1A3C0A),
                image: imageProvider != null
                    ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                    : null,
              ),
              child: imageProvider == null
                  ? const Icon(Icons.person, color: Colors.white, size: 30)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                student.nama,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => _showRemoveStudentDialog(context, student),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Remove',
                style: GoogleFonts.nunito(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmissionHistory() {
    return BlocBuilder<SubmissionBloc, SubmissionState>(
      bloc: _submissionBloc,
      builder: (context, submissionState) {
        return BlocBuilder<AssignmentBloc, AssignmentState>(
          bloc: _assignmentBloc,
          builder: (context, assignmentState) {
            if (submissionState is SubmissionLoading) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }

            List<SubmissionModel> submissions = [];
            if (submissionState is SubmissionSuccess) {
              submissions = submissionState.submissions
                  .where((s) =>
                      s.siswaId == widget.student.id &&
                      s.status != SubmissionStatus.draft)
                  .toList();
            }

            if (submissions.isEmpty) {
              return Center(
                child: Text(
                  'Belum ada riwayat pengumpulan.',
                  style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            Map<String, AssignmentModel> assignmentMap = {};
            if (assignmentState is AssignmentSuccess) {
              for (final a in assignmentState.assignments) {
                assignmentMap[a.id] = a;
              }
            }

            return ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: submissions.length,
              itemBuilder: (context, index) {
                final sub = submissions[index];
                final assignment = assignmentMap[sub.assignmentId];
                final taskTitle = assignment?.judul ?? 'Unknown Task';
                final blockCount =
                    sub.storyDataJson.split('<block').length - 1;
                return _buildHistoryCard(sub, taskTitle, blockCount);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildHistoryCard(
    SubmissionModel sub,
    String taskTitle,
    int blockCount,
  ) {
    String submitTime = '-';
    if (sub.submittedAt != null) {
      final dt = sub.submittedAt!;
      final d = dt.day.toString().padLeft(2, '0');
      final m = dt.month.toString().padLeft(2, '0');
      final y = dt.year;
      final h = dt.hour.toString().padLeft(2, '0');
      final min = dt.minute.toString().padLeft(2, '0');
      submitTime = '$d/$m/$y $h:$min';
    }

    final student = widget.student;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF758837),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Student header row 
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A3C0A), Color(0xFF758837)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF507877),
                    border: Border.all(color: Colors.white38, width: 1),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${student.nama}'s Story",
                      style: GoogleFonts.nunito(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      student.email,
                      style: GoogleFonts.nunito(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Info table
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Table(
              border: const TableBorder(
                horizontalInside: BorderSide(color: Colors.white24, width: 0.8),
                verticalInside: BorderSide(color: Colors.white24, width: 0.8),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1.2),
                1: FlexColumnWidth(2),
              },
              children: [
                _buildTableRow('Task', taskTitle),
                _buildTableRow('Blok', '$blockCount'),
                _buildTableRow('Submit', submitTime),
                _buildTableRow(
                  'Value',
                  sub.nilai != null ? '${sub.nilai}' : '-',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  void _showRemoveStudentDialog(BuildContext context, UserModel student) {
    showDialog(
      context: context,
      builder: (ctx) => KometActionDialog(
        title: 'Remove Student',
        content:
            'Apakah Anda yakin ingin menghapus ${student.nama} dari kelas ini?',
        confirmLabel: 'Remove',
        isDestructive: true,
        onConfirm: () {
          context.read<KelasBloc>().add(
            KelasRemoveStudentRequested(
              kelasId: widget.kelasId,
              siswaId: student.id,
            ),
          );
          Navigator.pop(context);
        },
      ),
    );
  }
}

