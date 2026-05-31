import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/models/assignment_model.dart';
import '../../../assignment/presentation/bloc/assignment_bloc.dart';
import '../../../assignment/presentation/bloc/assignment_event.dart';
import '../../../assignment/presentation/bloc/assignment_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/kelas_bloc.dart';
import '../../../submission/presentation/bloc/submission_bloc.dart';
import '../../../submission/presentation/bloc/submission_event.dart';
import '../../../submission/presentation/bloc/submission_state.dart';
import '../../../../core/models/submission_model.dart';
import '../widgets/submission_card.dart';
import '../widgets/assignment_card.dart';
import '../widgets/create_assignment_dialog.dart';

class KelasDetailGuruPage extends StatefulWidget {
  final String kelasId;

  const KelasDetailGuruPage({super.key, required this.kelasId});

  @override
  State<KelasDetailGuruPage> createState() => _KelasDetailGuruPageState();
}

class _KelasDetailGuruPageState extends State<KelasDetailGuruPage> {
  int _selectedTabIndex = 0;
  late AssignmentBloc _assignmentBloc;
  late KelasBloc _kelasBloc;
  late SubmissionBloc _submissionBloc;

  @override
  void initState() {
    super.initState();
    _assignmentBloc = context.read<AssignmentBloc>();
    _kelasBloc = context.read<KelasBloc>();
    _submissionBloc = context.read<SubmissionBloc>();

    _assignmentBloc.add(GetAssignmentsByClassEvent(widget.kelasId));
    _kelasBloc.add(KelasFetchDetailRequested(widget.kelasId));
    _submissionBloc.add(GetSubmissionsByClassEvent(widget.kelasId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFC7D5D8,
      ), // Light blue background like image
      body: Column(
        children: [
          _buildCustomHeader(context),
          Expanded(
            child: _selectedTabIndex == 0
                ? _buildAssignmentList()
                : _buildSubmissionList(),
          ),
        ],
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? Container(
              margin: const EdgeInsets.only(bottom: 20, right: 10),
              child: FloatingActionButton(
                onPressed: _showCreateAssignmentDialog,
                backgroundColor: Colors.white,
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.add, color: Colors.black, size: 32),
              ),
            )
          : null,
    );
  }

  void _showCreateAssignmentDialog() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return;

    final teacherId = authState.user.id;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (context) => CreateAssignmentDialog(
        onCreated: (assignmentName, deadline) {
          final newAssignment = AssignmentModel(
            id: '',
            judul: assignmentName,
            deskripsi: '',
            kelasId: widget.kelasId,
            guruId: teacherId,
            deadline:
                DateTime.tryParse(deadline) ??
                DateTime.now().add(const Duration(days: 7)),
            nilaiMaksimal: 100,
            status: AssignmentStatus.aktif,
            dibuatPada: DateTime.now(),
          );
          _assignmentBloc.add(CreateAssignmentEvent(newAssignment));
        },
      ),
    );
  }

  Widget _buildAssignmentList() {
    return BlocListener<AssignmentBloc, AssignmentState>(
      listener: (context, state) {
        if (state is AssignmentCreatedSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task berhasil dibuat!')),
          );
          _assignmentBloc.add(GetAssignmentsByClassEvent(widget.kelasId));
        } else if (state is AssignmentDeletedSuccess ||
            state is AssignmentUpdatedSuccess) {
          _assignmentBloc.add(GetAssignmentsByClassEvent(widget.kelasId));
        }
      },
      child: BlocBuilder<AssignmentBloc, AssignmentState>(
        builder: (context, state) {
          if (state is AssignmentLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is AssignmentSuccess) {
            if (state.assignments.isEmpty) {
              return const Center(child: Text("Belum ada task di kelas ini."));
            }
            return ListView.builder(
              padding: const EdgeInsets.only(top: 20, bottom: 120),
              itemCount: state.assignments.length,
              itemBuilder: (context, index) {
                final assignment = state.assignments[index];
                return AssignmentCard(
                  title: assignment.judul,
                  deadline:
                      "${assignment.deadline.day}/${assignment.deadline.month}/${assignment.deadline.year}",
                  isStudent: false,
                  onEdit: () => _showEditAssignmentDialog(assignment),
                  onDelete: () => _showDeleteConfirmationDialog(assignment),
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showEditAssignmentDialog(AssignmentModel assignment) {
    final titleController = TextEditingController(text: assignment.judul);
    final d = assignment.deadline;
    final y = d.year;
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    final dateController = TextEditingController(text: "$y-$m-$day");

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
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
                  'Edit Task',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                _buildGlassInput(
                  controller: titleController,
                  hint: 'Task ...',
                  icon: Icons.assignment_outlined,
                ),
                const SizedBox(height: 16),
                _buildGlassInput(
                  controller: dateController,
                  hint: 'Deadline ...',
                  icon: Icons.calendar_today_outlined,
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: assignment.deadline,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      dateController.text =
                          "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                    }
                  },
                ),
                const SizedBox(height: 32),
                _buildGlassButton(
                  label: 'Save',
                  onTap: () {
                    final updated = assignment.copyWith(
                      judul: titleController.text,
                      deadline:
                          DateTime.tryParse(dateController.text) ??
                          assignment.deadline,
                    );
                    _assignmentBloc.add(UpdateAssignmentEvent(updated));
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(AssignmentModel assignment) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.3),
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withValues(alpha: 0.2),
                  Colors.white.withValues(alpha: 0.05),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 40,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Delete Task',
                  style: GoogleFonts.nunito(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 32),
                _buildGlassButton(
                  label: 'Delete',
                  colorGradient: const [Color(0xFFFDFBEE), Color(0xFFC47A7B)],
                  onTap: () {
                    _assignmentBloc.add(DeleteAssignmentEvent(assignment.id));
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
                _buildGlassButton(
                  label: 'Cancel',
                  colorGradient: const [Color(0xFFFDFBEE), Color(0xFF7AB3C4)],
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.8)),
      ),
      child: TextField(
        controller: controller,
        onTap: onTap,
        readOnly: onTap != null,
        style: GoogleFonts.nunito(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: GoogleFonts.nunito(color: Colors.white70),
          prefixIcon: Icon(icon, color: Colors.white, size: 20),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
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
    Color? color,
    List<Color>? colorGradient,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          gradient: color == null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors:
                      colorGradient ??
                      [const Color(0xFFFDFBEE), const Color(0xFF7AB3C4)],
                )
              : null,
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

  Widget _buildSubmissionList() {
    return BlocBuilder<SubmissionBloc, SubmissionState>(
      builder: (context, state) {
        if (state is SubmissionLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (state is SubmissionSuccess) {
          final submissions = state.submissions
              .where((s) => s.status != SubmissionStatus.draft)
              .toList();
          if (submissions.isEmpty) {
            return const Center(child: Text("Belum ada pengumpulan tugas."));
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 20, bottom: 120),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];
              final assignmentState = context.read<AssignmentBloc>().state;
              String taskTitle = "Unknown Task";
              if (assignmentState is AssignmentSuccess) {
                try {
                  taskTitle = assignmentState.assignments
                      .firstWhere((a) => a.id == sub.assignmentId)
                      .judul;
                } catch (_) {}
              }

              return SubmissionCard(
                submission: sub,
                studentName: "Student ${sub.siswaId.substring(0, 4)}",
                assignmentTitle: taskTitle,
                onTap: () {
                  context
                      .pushNamed(
                        'reviewDetail',
                        extra: {
                          'submission': sub,
                          'assignmentTitle': taskTitle,
                        },
                      )
                      .then((_) {
                        _submissionBloc.add(
                          GetSubmissionsByClassEvent(widget.kelasId),
                        );
                      });
                },
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCustomHeader(BuildContext context) {
    return BlocBuilder<KelasBloc, KelasState>(
      builder: (context, state) {
        String className = 'Loading...';
        String classCode = '......';
        if (state is KelasDetailLoaded) {
          className = state.kelas.nama;
          classCode = state.kelas.kodeKelas;
        }

        return Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 6, // dynamically clear status bar
            left: 24,
            right: 24,
            bottom: 0,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A3C0A), Color(0xFF758837)],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            border: const Border(
              bottom: BorderSide(
                color: Colors.white,
                width: 4,
              ),
            ),
          ),
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
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                className,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Class Code : ',
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    classCode,
                    style: GoogleFonts.nunito(
                      color: const Color(0xFF6CB5B8),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildCopyButton(classCode),
                ],
              ),
              const SizedBox(height: 8),
              _buildTabs(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCopyButton(String code) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Code copied!'),
            duration: Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFDFBEE), Color(0xFF7AB3C4)],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 3,
              offset: const Offset(0, 1.5),
            ),
          ],
        ),
        child: Text(
          'Copy',
          style: GoogleFonts.nunito(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [_tabItem('Task', 0), _tabItem('Submission', 1)],
    );
  }

  Widget _tabItem(String title, int index) {
    bool active = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.nunito(
              color: active ? Colors.white : Colors.white70,
              fontSize: 20,
              fontWeight: active ? FontWeight.bold : FontWeight.w400,
            ),
          ),
          const SizedBox(height: 12),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 6,
            width: index == 0 ? 90 : 130,
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
