import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
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
import 'submission_canvas_page.dart';

class KelasDetailPage extends StatefulWidget {
  final String kelasId;

  const KelasDetailPage({super.key, required this.kelasId});

  @override
  State<KelasDetailPage> createState() => _KelasDetailPageState();
}

class _KelasDetailPageState extends State<KelasDetailPage> {
  int _selectedTabIndex = 0;
  late AssignmentBloc _assignmentBloc;
  late KelasBloc _kelasBloc;
  late SubmissionBloc _submissionBloc;

  @override
  void initState() {
    super.initState();
    _assignmentBloc = sl<AssignmentBloc>();
    _kelasBloc = sl<KelasBloc>();
    _submissionBloc = sl<SubmissionBloc>();

    _assignmentBloc.add(GetAssignmentsByClassEvent(widget.kelasId));
    _kelasBloc.add(KelasFetchDetailRequested(widget.kelasId));
    _submissionBloc.add(GetSubmissionsByClassEvent(widget.kelasId));
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final bool isGuru = authState is AuthAuthenticated && authState.user.role == 'guru';

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _assignmentBloc),
        BlocProvider.value(value: _kelasBloc),
        BlocProvider.value(value: _submissionBloc),
      ],
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF86B3C0),
                Color(0xFFE3E2E0),
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: Column(
            children: [
              _buildCustomHeader(context, isGuru),
              Expanded(
                child: _selectedTabIndex == 0
                    ? BlocListener<AssignmentBloc, AssignmentState>(
                        listener: (context, state) {
                          if (state is AssignmentCreatedSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Task berhasil dibuat!'),
                              ),
                            );
                            _assignmentBloc.add(
                              GetAssignmentsByClassEvent(widget.kelasId),
                            );
                          } else if (state is AssignmentFailure) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Gagal: ${state.message}'),
                              ),
                            );
                          }
                        },
                        child: BlocBuilder<AssignmentBloc, AssignmentState>(
                          builder: (context, state) {
                            if (state is AssignmentLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            } else if (state is AssignmentSuccess) {
                              if (state.assignments.isEmpty) {
                                return const Center(
                                  child: Text("Belum ada task di kelas ini."),
                                );
                              }
                              return ListView.builder(
                                padding: const EdgeInsets.only(
                                  top: 20,
                                  bottom: 100,
                                ),
                                itemCount: state.assignments.length,
                                itemBuilder: (context, index) {
                                  final assignment = state.assignments[index];
                                  return AssignmentCard(
                                    title: assignment.judul,
                                    deadline: assignment.deadline
                                        .toString()
                                        .split(' ')[0],
                                    isStudent: !isGuru,
                                    onTap: !isGuru
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    SubmissionCanvasPage(
                                                  assignmentId: assignment.id,
                                                  assignmentTitle:
                                                      assignment.judul,
                                                  deadline: assignment.deadline
                                                      .toString()
                                                      .split(' ')[0],
                                                ),
                                              ),
                                            );
                                          }
                                        : null,
                                  );
                                },
                              );
                            } else if (state is AssignmentFailure) {
                              return Center(
                                child: Text("Error: ${state.message}"),
                              );
                            }
                            return const SizedBox.shrink();
                          },
                        ),
                      )
                    : BlocBuilder<SubmissionBloc, SubmissionState>(
                        builder: (context, subState) {
                          if (subState is SubmissionLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (subState is SubmissionSuccess) {
                            if (subState.submissions.isEmpty) {
                              return const Center(
                                child: Text("Belum ada pengumpulan tugas."),
                              );
                            }
                            return ListView.builder(
                              padding: const EdgeInsets.only(
                                top: 20,
                                bottom: 100,
                              ),
                              itemCount: subState.submissions.length,
                              itemBuilder: (context, index) {
                                final sub = subState.submissions[index];
                                return SubmissionCard(
                                  submission: sub,
                                  studentName:
                                      "Student ${sub.siswaId.substring(0, 4)}",
                                  assignmentTitle: "Checking task...",
                                );
                              },
                            );
                          } else if (subState is SubmissionFailure) {
                            return Center(
                              child: Text("Error: ${subState.message}"),
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
              ),
            ],
          ),
        ),
        floatingActionButton: (_selectedTabIndex == 0 && isGuru)
            ? FloatingActionButton(
                onPressed: () {
                  final authState = context.read<AuthBloc>().state;
                  if (authState is! AuthAuthenticated) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anda harus login untuk membuat tugas'),
                      ),
                    );
                    return;
                  }

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
                          deadline: DateTime.tryParse(deadline) ??
                              DateTime.now().add(const Duration(days: 7)),
                          nilaiMaksimal: 100,
                          status: AssignmentStatus.aktif,
                          dibuatPada: DateTime.now(),
                        );

                        _assignmentBloc.add(
                          CreateAssignmentEvent(newAssignment),
                        );
                      },
                    ),
                  );
                },
                backgroundColor: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                  size: 28,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildCustomHeader(BuildContext context, bool isGuru) {
    return BlocBuilder<KelasBloc, KelasState>(
      builder: (context, state) {
        String className = 'Loading...';
        String classCode = '......';

        if (state is KelasDetailLoaded) {
          className = state.kelas.nama;
          classCode = state.kelas.kodeKelas;
        }

        return Container(
          clipBehavior: Clip.antiAlias,
          padding: const EdgeInsets.only(
            top: 40,
            left: 24,
            right: 24,
            bottom: 0,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF6B7E25),
                Color(0xFF1F410F),
              ],
            ),
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(24),
              bottomRight: Radius.circular(24),
            ),
            border: const Border(
              bottom: BorderSide(
                color: Colors.white,
                width: 2,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    isGuru ? Icons.school_outlined : Icons.auto_stories_outlined,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isGuru ? 'Teacher Hub' : 'Student Hub',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (isGuru) ...[
                Text(
                  className,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Text(
                      'Class Code : ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      classCode,
                      style: const TextStyle(
                        color: Color(0xFF6CB5B8),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      className.length >= 2
                          ? className.substring(0, 2).toUpperCase()
                          : className.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 16),
                    BlocBuilder<AssignmentBloc, AssignmentState>(
                      builder: (context, assignState) {
                        int tasks = 0;
                        if (assignState is AssignmentSuccess) {
                          tasks = assignState.assignments.length;
                        }
                        return _buildCompactBadge(Icons.assignment, '$tasks Task');
                      },
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('|', style: TextStyle(color: Colors.white54)),
                    ),
                    BlocBuilder<SubmissionBloc, SubmissionState>(
                      builder: (context, subState) {
                        int completed = 0;
                        if (subState is SubmissionSuccess) {
                          final authState = context.read<AuthBloc>().state;
                          final userId = authState is AuthAuthenticated
                              ? authState.user.id
                              : '';
                          completed = subState.submissions
                              .where((s) => s.siswaId == userId && s.status != SubmissionStatus.draft)
                              .length;
                        }
                        return _buildCompactBadge(Icons.image_outlined, '$completed Completed');
                      },
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 0;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          'Task',
                          style: TextStyle(
                            color: _selectedTabIndex == 0
                                ? Colors.white
                                : Colors.white70,
                            fontSize: 16,
                            fontWeight: _selectedTabIndex == 0
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 4,
                          width: 50,
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 0
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTabIndex = 1;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          'Submission',
                          style: TextStyle(
                            color: _selectedTabIndex == 1
                                ? Colors.white
                                : Colors.white70,
                            fontSize: 16,
                            fontWeight: _selectedTabIndex == 1
                                ? FontWeight.w500
                                : FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 4,
                          width: 90,
                          decoration: BoxDecoration(
                            color: _selectedTabIndex == 1
                                ? Colors.white
                                : Colors.transparent,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF19350C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}