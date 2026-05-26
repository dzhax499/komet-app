import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
import 'submission_canvas_page.dart';

class KelasDetailSiswaPage extends StatefulWidget {
  final String kelasId;

  const KelasDetailSiswaPage({super.key, required this.kelasId});

  @override
  State<KelasDetailSiswaPage> createState() => _KelasDetailSiswaPageState();
}

class _KelasDetailSiswaPageState extends State<KelasDetailSiswaPage> {
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
    final authState = context.read<AuthBloc>().state;
    final String userId = authState is AuthAuthenticated ? authState.user.id : '';

    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF86B3C0), Color(0xFFE3E2E0)],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: () async {
            _assignmentBloc.add(GetAssignmentsByClassEvent(widget.kelasId));
            _submissionBloc.add(GetSubmissionsByClassEvent(widget.kelasId));
            _kelasBloc.add(KelasFetchDetailRequested(widget.kelasId));
            await Future.delayed(const Duration(seconds: 1));
          },
          color: const Color(0xFF6FA9BB),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _buildCustomHeader(context),
                BlocListener<SubmissionBloc, SubmissionState>(
                  listener: (context, state) {
                    if (state is SubmissionSaved) {
                      _submissionBloc.add(GetSubmissionsByClassEvent(widget.kelasId));
                    }
                  },
                  child: BlocBuilder<SubmissionBloc, SubmissionState>(
                    builder: (context, submissionState) {
                      var submittedAssignmentIds = <String>{};
                      if (submissionState is SubmissionSuccess) {
                        final userSubmissions = submissionState.submissions.where((s) => s.siswaId == userId);
                        submittedAssignmentIds = userSubmissions
                            .where((s) => s.status == SubmissionStatus.submitted || s.status == SubmissionStatus.reviewed || s.status == SubmissionStatus.needsRevision)
                            .map((s) => s.assignmentId)
                            .toSet();
                      }

                      return _selectedTabIndex == 0
                          ? _buildAssignmentList(submittedAssignmentIds)
                          : _buildSubmissionList(submissionState, userId);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAssignmentList(Set<String> submittedAssignmentIds) {
    return BlocBuilder<AssignmentBloc, AssignmentState>(
      builder: (context, state) {
        if (state is AssignmentLoading) return const Center(child: CircularProgressIndicator());
        if (state is AssignmentSuccess) {
          final List<AssignmentModel> displayAssignments = 
              state.assignments.where((a) => !submittedAssignmentIds.contains(a.id)).toList();

          if (displayAssignments.isEmpty) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.5,
              alignment: Alignment.center,
              child: const Text("Belum ada task di kelas ini.", style: TextStyle(color: Colors.black54)),
            );
          }
          
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.only(top: 20, bottom: 100),
            itemCount: displayAssignments.length,
            itemBuilder: (context, index) {
              final assignment = displayAssignments[index];
              return AssignmentCard(
                title: assignment.judul,
                deadline: assignment.deadline.toString().split(' ')[0],
                isStudent: true,
                onTap: () {
                  final authState = context.read<AuthBloc>().state;
                  final studentId = authState is AuthAuthenticated ? authState.user.id : '';
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: _submissionBloc,
                        child: SubmissionCanvasPage(
                          assignmentId: assignment.id,
                          assignmentTitle: assignment.judul,
                          deadline: assignment.deadline.toString().split(' ')[0],
                          studentId: studentId,
                        ),
                      ),
                    ),
                  ).then((_) {
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

  Widget _buildSubmissionList(SubmissionState submissionState, String userId) {
    if (submissionState is SubmissionLoading) return const Center(child: CircularProgressIndicator());
    if (submissionState is SubmissionSuccess) {
      final List<SubmissionModel> displaySubmissions = submissionState.submissions
          .where((s) => s.siswaId == userId && 
              (s.status == SubmissionStatus.submitted || 
               s.status == SubmissionStatus.reviewed || 
               s.status == SubmissionStatus.needsRevision)).toList();

      if (displaySubmissions.isEmpty) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          alignment: Alignment.center,
          child: const Text("Belum ada pengumpulan tugas.", style: TextStyle(color: Colors.black54)),
        );
      }
      
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.only(top: 20, bottom: 100),
        itemCount: displaySubmissions.length,
        itemBuilder: (context, index) {
          final sub = displaySubmissions[index];
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: _submissionBloc,
                    child: SubmissionCanvasPage(
                      assignmentId: sub.assignmentId,
                      assignmentTitle: taskTitle,
                      deadline: "",
                      studentId: userId,
                      isReviewMode: sub.status == SubmissionStatus.reviewed,
                    ),
                  ),
                ),
              ).then((_) {
                _submissionBloc.add(GetSubmissionsByClassEvent(widget.kelasId));
              });
            },
            onCancel: sub.status == SubmissionStatus.submitted ? () {
              final cancelledSub = sub.copyWith(status: SubmissionStatus.draft);
              context.read<SubmissionBloc>().add(SubmitTaskEvent(cancelledSub));
            } : null,
          );
        },
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildCustomHeader(BuildContext context) {
    return BlocBuilder<KelasBloc, KelasState>(
      builder: (context, state) {
        String className = 'Loading...';
        if (state is KelasDetailLoaded) {
          className = state.kelas.nama;
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
                  Image.asset(
                    'assets/images/logo.png',
                    height: 20,
                    width: 20,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 8),
                  Text('Student Hub', style: GoogleFonts.nunito(color: Colors.white, fontSize: 16)),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 28),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      className,
                      style: GoogleFonts.nunito(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildStudentStats(),
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

  Widget _buildStudentStats() {
    return BlocBuilder<SubmissionBloc, SubmissionState>(
      builder: (context, subState) {
        final authState = context.read<AuthBloc>().state;
        final userId = authState is AuthAuthenticated ? authState.user.id : '';
        int completed = 0;
        Set<String> submittedIds = {};
        
        if (subState is SubmissionSuccess) {
          final userSubmissions = subState.submissions.where((s) => s.siswaId == userId);
          completed = userSubmissions.where((s) => s.status == SubmissionStatus.submitted || s.status == SubmissionStatus.reviewed || s.status == SubmissionStatus.needsRevision).length;
          submittedIds = userSubmissions.where((s) => s.status == SubmissionStatus.submitted || s.status == SubmissionStatus.reviewed || s.status == SubmissionStatus.needsRevision).map((s) => s.assignmentId).toSet();
        }

        return Row(
          children: [
            BlocBuilder<AssignmentBloc, AssignmentState>(
              builder: (context, assignState) {
                int tasks = 0;
                if (assignState is AssignmentSuccess) {
                  tasks = assignState.assignments.where((a) => !submittedIds.contains(a.id)).length;
                }
                return _buildCompactBadge(Icons.assignment, '$tasks Task');
              },
            ),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('|', style: TextStyle(color: Colors.white54))),
            _buildCompactBadge(Icons.image_outlined, '$completed Completed'),
          ],
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

  Widget _buildCompactBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: const Color(0xFF19350C), borderRadius: BorderRadius.circular(12)),
      child: Row(children: [Icon(icon, color: Colors.white, size: 12), const SizedBox(width: 6), Text(text, style: const TextStyle(color: Colors.white, fontSize: 11))]),
    );
  }
}
