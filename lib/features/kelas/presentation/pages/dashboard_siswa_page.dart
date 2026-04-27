import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/kelas_bloc.dart';
import '../widgets/join_kelas_dialog.dart';
import '../../../submission/presentation/bloc/submission_bloc.dart';
import '../../../submission/presentation/bloc/submission_event.dart';
import '../../../submission/presentation/bloc/submission_state.dart';
import '../../../../core/models/submission_model.dart';

class DashboardSiswaPage extends StatelessWidget {
  const DashboardSiswaPage({super.key});

  // Palet warna sesuai tema KOMET
  static const Color _moonstoneBlue = Color(0xFF6FA9BB);
  static const Color _mustardGreen = Color(0xFF687D31);
  static const Color _lightGray = Color(0xFFD5D3CC);
  static const Color _deepSpaceSparkle = Color(0xFF406768);
  static const Color _phthaloGreen = Color(0xFF19350C);

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return MultiBlocProvider(
      providers: [
        BlocProvider<KelasBloc>(
          create: (context) =>
              sl<KelasBloc>()..add(KelasFetchSiswaRequested(user.id)),
        ),
        BlocProvider<SubmissionBloc>(
          create: (context) =>
              sl<SubmissionBloc>()..add(GetSubmissionsByStudentEvent(user.id)),
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            // Background Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_moonstoneBlue, _lightGray],
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    // Header
                    Row(
                      children: [
                        const Icon(Icons.auto_stories_outlined,
                            color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Student Hub',
                          style: GoogleFonts.outfit(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.white,
                          ),
                        ),
                        const Spacer(),
                        // Tombol Logout
                        IconButton(
                          icon: const Icon(Icons.logout,
                              color: Colors.white, size: 20),
                          onPressed: () {
                            context
                                .read<AuthBloc>()
                                .add(AuthLogoutRequested());
                            context.go('/login');
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Welcome back,',
                        style: GoogleFonts.outfit(
                            fontSize: 15, color: Colors.white)),
                    Text(
                      user.nama,
                      style: GoogleFonts.outfit(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),

                    // Stat Cards — diambil dari data BLoC
                    BlocBuilder<KelasBloc, KelasState>(
                      builder: (context, kelasState) {
                        return BlocBuilder<SubmissionBloc, SubmissionState>(
                          builder: (context, submissionState) {
                            int activeClass = 0;
                            int totalAssignments = 0;
                            
                            if (kelasState is KelasLoaded) {
                              activeClass = kelasState.kelasList.length;
                              for (var k in kelasState.kelasList) {
                                totalAssignments += k.assignmentIds.length;
                              }
                            }

                            int completedTasks = 0;
                            if (submissionState is SubmissionSuccess) {
                              completedTasks = submissionState.submissions
                                  .where((s) => s.status != SubmissionStatus.draft)
                                  .length;
                            }

                            return IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildStatCard(_moonstoneBlue, Icons.bookmark,
                                      '$activeClass', 'Active Class'),
                                  const VerticalDivider(
                                      color: Colors.white,
                                      thickness: 1.2,
                                      width: 2),
                                  _buildStatCard(_mustardGreen,
                                      Icons.assignment_rounded, '$totalAssignments', 'Task'),
                                  const VerticalDivider(
                                      color: Colors.white,
                                      thickness: 1.2,
                                      width: 2),
                                  _buildStatCard(_deepSpaceSparkle,
                                      Icons.checklist_rounded, '$completedTasks', 'Completed'),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    // Section My Class & Tombol Join Class
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Class',
                          style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                        Builder(
                          builder: (innerContext) => GestureDetector(
                            onTap: () {
                              showDialog(
                                context: innerContext,
                                builder: (dialogContext) => JoinKelasDialog(
                                  onJoin: (kode) {
                                    innerContext.read<KelasBloc>().add(
                                          KelasJoinRequested(
                                            kodeKelas: kode,
                                            siswaId: user.id,
                                          ),
                                        );
                                  },
                                ),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                'Join Class',
                                style: GoogleFonts.outfit(
                                  color: Colors.black,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Daftar Kelas dari BLoC
                    Expanded(
                      child: BlocConsumer<KelasBloc, KelasState>(
                        listener: (context, state) {
                          if (state is KelasActionSuccess) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          } else if (state is KelasError) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },
                        builder: (context, state) {
                          if (state is KelasLoading) {
                            return const Center(
                              child: CircularProgressIndicator(
                                  color: Colors.white),
                            );
                          } else if (state is KelasLoaded) {
                            if (state.kelasList.isEmpty) {
                              return _buildEmptyState();
                            }
                            return ListView.separated(
                              itemCount: state.kelasList.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final kelas = state.kelasList[index];
                                return BlocBuilder<SubmissionBloc, SubmissionState>(
                                  builder: (context, submissionState) {
                                    int classTasks = kelas.assignmentIds.length;
                                    int classCompleted = 0;

                                    if (submissionState is SubmissionSuccess) {
                                      classCompleted = submissionState.submissions
                                          .where((s) => s.status != SubmissionStatus.draft && kelas.assignmentIds.contains(s.assignmentId))
                                          .length;
                                    }

                                    return GestureDetector(
                                      onTap: () {
                                        context.pushNamed('kelasDetail',
                                            pathParameters: {
                                              'kelasId': kelas.id
                                            });
                                      },
                                      child: _buildUltraSlimClassCard(
                                        _phthaloGreen,
                                        _mustardGreen,
                                        kelas.nama,
                                        kelas.kodeKelas,
                                        classTasks,
                                        classCompleted,
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          } else if (state is KelasError) {
                            return Center(
                              child: Text(state.message,
                                  style: const TextStyle(color: Colors.white)),
                            );
                          }
                          return _buildEmptyState();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.group_outlined, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            'Belum ada kelas',
            style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white70),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan "Join Class" untuk bergabung\nmenggunakan kode dari gurumu.',
            style: GoogleFonts.inter(color: Colors.white60, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      Color color, IconData icon, String value, String label) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.outfit(
                fontSize: 24,
                fontWeight: FontWeight.w500,
                color: Colors.white),
          ),
          Text(
            label,
            style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.white,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }

  Widget _buildUltraSlimClassCard(
    Color darkGreen,
    Color lightGreen,
    String className,
    String classCode,
    int tasks,
    int completed,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [lightGreen, darkGreen],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: Text(
              className.length >= 2
                  ? className.substring(0, 2).toUpperCase()
                  : className.toUpperCase(),
              style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCompactBadge(Icons.assignment, '$tasks Task'),
                    const Icon(Icons.circle, size: 12, color: Colors.white),
                  ],
                ),
                const SizedBox(height: 8),
                const Divider(color: Colors.white54, thickness: 1, height: 1),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCompactBadge(Icons.checklist_rounded, '$completed Completed'),
                    const Icon(Icons.circle, size: 12, color: Colors.white),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _phthaloGreen,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w400),
          ),
        ],
      ),
    );
  }
}
