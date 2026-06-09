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

import 'package:uuid/uuid.dart';
import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/di/service_locator.dart';
import 'dart:convert';

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
              child: BlocListener<SubmissionBloc, SubmissionState>(
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentList(Set<String> submittedAssignmentIds) {
    return BlocBuilder<AssignmentBloc, AssignmentState>(
      builder: (context, state) {
        List<AssignmentModel> displayAssignments = [];
        if (state is AssignmentSuccess) {
          displayAssignments = state.assignments.where((a) => !submittedAssignmentIds.contains(a.id)).toList();
        } else {
          // Fallback to local data while loading
          final localAssignments = sl<HiveService>().assignmentBoxInstance.values.where((a) => a.kelasId == widget.kelasId).toList();
          displayAssignments = localAssignments.where((a) => !submittedAssignmentIds.contains(a.id)).toList();
        }

        if (displayAssignments.isEmpty && state is AssignmentLoading) {
           return const Center(child: CircularProgressIndicator());
        }
        if (displayAssignments.isEmpty) return const Center(child: Text("No tasks yet in this class."));
        
        return ListView.builder(
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
                _showWorkOptionsDialog(context, assignment, studentId);
              },
            );
          },
        );
      },
    );
  }

  void _showWorkOptionsDialog(BuildContext context, AssignmentModel assignment, String studentId) {
    final submissionState = context.read<SubmissionBloc>().state;
    String? existingId;
    if (submissionState is SubmissionSuccess) {
      try {
        final existing = submissionState.submissions.firstWhere(
          (s) => s.assignmentId == assignment.id && s.siswaId == studentId
        );
        existingId = existing.id;
      } catch (_) {}
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Pilih Metode Pengerjaan', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.add_circle_outline, color: Colors.blue),
                title: Text('Kerjakan dari Awal', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                subtitle: Text('Buat cerita kosong baru', style: GoogleFonts.nunito(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _openEditor(assignment, studentId);
                },
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download_outlined, color: Colors.green),
                title: Text('Gunakan Draf Guest (Offline)', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                subtitle: Text('Pilih dari karya yang dibuat tanpa login', style: GoogleFonts.nunito(fontSize: 12)),
                onTap: () {
                  Navigator.pop(context);
                  _showGuestDraftsDialog(context, assignment, studentId, existingId);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showGuestDraftsDialog(BuildContext context, AssignmentModel assignment, String studentId, String? existingId) {
    final allSubs = sl<HiveService>().submissionBoxInstance.values.toList();
    final guestSubs = allSubs.where((p) => p.siswaId == 'guest').toList();
    guestSubs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pilih Draf Guest', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: guestSubs.isEmpty
                ? Center(child: Text('Tidak ada draf guest.', style: GoogleFonts.nunito()))
                : ListView.builder(
                    itemCount: guestSubs.length,
                    itemBuilder: (context, index) {
                      final draft = guestSubs[index];
                      String draftTitle = 'Karya Guest';
                      try {
                        if (draft.storyDataJson.isNotEmpty) {
                          final data = jsonDecode(draft.storyDataJson);
                          if (data['title'] != null && data['title'].toString().isNotEmpty) {
                            draftTitle = data['title'];
                          }
                        }
                      } catch (_) {}

                      return Card(
                        child: ListTile(
                          title: Text(draftTitle, style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
                          subtitle: Text('Diubah: ${draft.updatedAt.day}/${draft.updatedAt.month}/${draft.updatedAt.year}', style: GoogleFonts.nunito(fontSize: 12)),
                          onTap: () {
                            Navigator.pop(context);
                            _claimGuestDraft(draft, assignment, studentId, existingId);
                          },
                        ),
                      );
                    },
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
          ],
        );
      },
    );
  }

  void _claimGuestDraft(SubmissionModel guestDraft, AssignmentModel assignment, String studentId, String? existingId) {
    // Clone draft and change assignmentId and siswaId, use existingId if available
    final claimedSub = guestDraft.copyWith(
      id: existingId ?? const Uuid().v4(),
      assignmentId: assignment.id,
      siswaId: studentId,
      status: SubmissionStatus.draft,
      updatedAt: DateTime.now(),
    );
    
    // Langsung sinkronisasikan/save secara online menggunakan BLoC
    _submissionBloc.add(SubmitTaskEvent(claimedSub));
    
    // Langsung buka editor dan kirimkan data guest yang sudah diklaim
    _openEditor(assignment, studentId, initialSubmission: claimedSub);
  }

  void _openEditor(AssignmentModel assignment, String studentId, {SubmissionModel? initialSubmission}) {
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
            initialSubmission: initialSubmission,
          ),
        ),
      ),
    ).then((_) {
      _submissionBloc.add(GetSubmissionsByClassEvent(widget.kelasId));
    });
  }

  Widget _buildSubmissionList(SubmissionState submissionState, String userId) {
    List<SubmissionModel> displaySubmissions = [];
    if (submissionState is SubmissionSuccess) {
      displaySubmissions = submissionState.submissions
          .where((s) => s.siswaId == userId && 
              (s.status == SubmissionStatus.submitted || 
               s.status == SubmissionStatus.reviewed || 
               s.status == SubmissionStatus.needsRevision)).toList();
    } else {
      final localSubs = sl<HiveService>().submissionBoxInstance.values.toList();
      displaySubmissions = localSubs
          .where((s) => s.siswaId == userId && 
              (s.status == SubmissionStatus.submitted || 
               s.status == SubmissionStatus.reviewed || 
               s.status == SubmissionStatus.needsRevision)).toList();
    }

    if (displaySubmissions.isEmpty && submissionState is SubmissionLoading) {
      return const Center(child: CircularProgressIndicator());
    }
      if (displaySubmissions.isEmpty) return const Center(child: Text("No submissions yet."));
      
      return ListView.builder(
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

          final authState2 = context.read<AuthBloc>().state;
          final studentName = authState2 is AuthAuthenticated ? authState2.user.nama : 'Student';
          final studentPhotoUrl = authState2 is AuthAuthenticated ? authState2.user.photoUrl : null;

          return SubmissionCard(
            submission: sub,
            studentName: studentName,
            studentPhotoUrl: studentPhotoUrl,
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
                      initialSubmission: sub,
                      isReviewMode: sub.status == SubmissionStatus.reviewed || sub.status == SubmissionStatus.submitted,
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
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Text(className, style: GoogleFonts.nunito(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
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
