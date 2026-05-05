import 'package:flutter/material.dart';
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF86B3C0), Color(0xFFE3E2E0)],
          ),
        ),
        child: Column(
          children: [
            _buildCustomHeader(context),
            Expanded(
              child: _selectedTabIndex == 0 
                  ? _buildAssignmentList() 
                  : _buildSubmissionList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedTabIndex == 0
          ? FloatingActionButton(
              onPressed: _showCreateAssignmentDialog,
              backgroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: const Icon(Icons.add, color: Colors.black, size: 28),
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
            deadline: DateTime.tryParse(deadline) ?? DateTime.now().add(const Duration(days: 7)),
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task berhasil dibuat!')));
          _assignmentBloc.add(GetAssignmentsByClassEvent(widget.kelasId));
        }
      },
      child: BlocBuilder<AssignmentBloc, AssignmentState>(
        builder: (context, state) {
          if (state is AssignmentLoading) return const Center(child: CircularProgressIndicator());
          if (state is AssignmentSuccess) {
            if (state.assignments.isEmpty) return const Center(child: Text("Belum ada task di kelas ini."));
            return ListView.builder(
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              itemCount: state.assignments.length,
              itemBuilder: (context, index) {
                final assignment = state.assignments[index];
                return AssignmentCard(
                  title: assignment.judul,
                  deadline: assignment.deadline.toString().split(' ')[0],
                  isStudent: false,
                );
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSubmissionList() {
    return BlocBuilder<SubmissionBloc, SubmissionState>(
      builder: (context, state) {
        if (state is SubmissionLoading) return const Center(child: CircularProgressIndicator());
        if (state is SubmissionSuccess) {
          final submissions = state.submissions.where((s) => s.status != SubmissionStatus.draft).toList();
          if (submissions.isEmpty) return const Center(child: Text("Belum ada pengumpulan tugas."));
          
          return ListView.builder(
            padding: const EdgeInsets.only(top: 20, bottom: 100),
            itemCount: submissions.length,
            itemBuilder: (context, index) {
              final sub = submissions[index];
              final assignmentState = context.read<AssignmentBloc>().state;
              String taskTitle = "Unknown Task";
              if (assignmentState is AssignmentSuccess) {
                try {
                  taskTitle = assignmentState.assignments.firstWhere((a) => a.id == sub.assignmentId).judul;
                } catch (_) {}
              }

              return SubmissionCard(
                submission: sub,
                studentName: "Student ${sub.siswaId.substring(0, 4)}",
                assignmentTitle: taskTitle,
                onTap: () {
                  context.pushNamed('reviewDetail', extra: {
                    'submission': sub,
                    'assignmentTitle': taskTitle,
                  }).then((_) {
                    _submissionBloc.add(GetSubmissionsByClassEvent(widget.kelasId));
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
          padding: const EdgeInsets.only(top: 40, left: 24, right: 24, bottom: 0),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF6B7E25), Color(0xFF1F410F)],
            ),
            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.school_outlined, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text('Teacher Hub', style: GoogleFonts.nunito(color: Colors.white, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              Text(className, style: GoogleFonts.nunito(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text('Class Code : ', style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(classCode, style: GoogleFonts.nunito(color: const Color(0xFF6CB5B8), fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 16),
              _buildTabs(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabs() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _tabItem('Task', 0),
        _tabItem('Submission', 1),
      ],
    );
  }

  Widget _tabItem(String title, int index) {
    bool active = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.nunito(color: active ? Colors.white : Colors.white70, fontSize: 16, fontWeight: active ? FontWeight.w500 : FontWeight.w400)),
          const SizedBox(height: 8),
          Container(height: 4, width: index == 0 ? 50 : 90, decoration: BoxDecoration(color: active ? Colors.white : Colors.transparent, borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)))),
        ],
      ),
    );
  }
}
