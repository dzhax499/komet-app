import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/models/user_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../submission/presentation/bloc/submission_bloc.dart';
import '../../../submission/presentation/bloc/submission_event.dart';
import '../../../submission/presentation/bloc/submission_state.dart';
import '../bloc/kelas_bloc.dart';
import '../widgets/create_kelas_dialog.dart';
import '../widgets/kelas_card.dart';

class DashboardGuruPage extends StatefulWidget {
  const DashboardGuruPage({super.key});

  @override
  State<DashboardGuruPage> createState() => _DashboardGuruPageState();
}

class _DashboardGuruPageState extends State<DashboardGuruPage> {
  bool _isProfileMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = state.user;

        return MultiBlocProvider(
          providers: [
            BlocProvider<KelasBloc>(
              create: (context) => sl<KelasBloc>()
                ..add(
                  KelasFetchGuruRequested(user.id),
                ),
            ),
            BlocProvider<SubmissionBloc>(
              create: (context) => sl<SubmissionBloc>(),
            ),
          ],
          child: GestureDetector(
            onTap: () {
              if (_isProfileMenuOpen) {
                setState(() => _isProfileMenuOpen = false);
              }
            },
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
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 20.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Row(
                              children: [
                                Icon(
                                  Icons.school_outlined,
                                  color: Colors.white,
                                  size: 28,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Teacher Hub',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                            
                            // Profile Avatar and Menu (Image 1)
                            Row(
                              children: [
                                if (_isProfileMenuOpen)
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      _buildPillButton(
                                        label: 'Profile',
                                        color: const Color(0xFF82903C),
                                        onTap: () => context.pushNamed('profileGuru'),
                                      ),
                                      const SizedBox(height: 4),
                                      _buildPillButton(
                                        label: 'Logout',
                                        color: const Color(0xFF650002),
                                        onTap: () {
                                          context.read<AuthBloc>().add(AuthLogoutRequested());
                                          context.go(KometRoutes.login);
                                        },
                                      ),
                                    ],
                                  ),
                                const SizedBox(width: 12),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _isProfileMenuOpen = !_isProfileMenuOpen;
                                    });
                                  },
                                  child: _buildProfileAvatar(user, size: 52),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Welcome back,',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.nama,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),
                        BlocBuilder<KelasBloc, KelasState>(
                          builder: (context, state) {
                            String activeClassCount = '0';
                            String totalAssignments = '0';

                            if (state is KelasLoaded) {
                              activeClassCount = state.kelasList.length.toString();
                              int total = 0;
                              List<String> allAssignmentIds = [];
                              for (var k in state.kelasList) {
                                total += k.assignmentIds.length;
                                allAssignmentIds.addAll(k.assignmentIds);
                              }
                              totalAssignments = total.toString();

                              if (allAssignmentIds.isNotEmpty) {
                                context.read<SubmissionBloc>().add(
                                      GetReviewCountEvent(allAssignmentIds),
                                    );
                              }
                            }

                            return IntrinsicHeight(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  _buildSummaryCard(
                                    icon: Icons.class_,
                                    number: activeClassCount == '0'
                                        ? ''
                                        : activeClassCount,
                                    label: 'Active Class',
                                    color: const Color(0xFF81B4C6),
                                    verticalMargin: 12.0,
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Container(
                                      width: 1,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSummaryCard(
                                    icon: Icons.assignment,
                                    number: totalAssignments == '0'
                                        ? ''
                                        : totalAssignments,
                                    label: 'Task',
                                    color: const Color(0xFF82903C),
                                    verticalMargin: 0.0,
                                  ),
                                  const SizedBox(width: 8),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12.0,
                                    ),
                                    child: Container(
                                      width: 1,
                                      color: Colors.white.withValues(alpha: 0.9),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSummaryCard(
                                    icon: Icons.video_label,
                                    number: reviewCount(context),
                                    label: 'Review',
                                    color: const Color(0xFF507877),
                                    verticalMargin: 12.0,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                        Builder(
                          builder: (blocContext) {
                            return Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'My Class',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    showDialog(
                                      context: blocContext,
                                      barrierColor:
                                          Colors.black.withValues(alpha: 0.2),
                                      builder: (context) => CreateKelasDialog(
                                        onCreated: (nama) {
                                          blocContext.read<KelasBloc>().add(
                                                KelasCreateRequested(
                                                  nama: nama,
                                                  guruId: user.id,
                                                ),
                                              );
                                        },
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Row(
                                      children: [
                                        Icon(
                                          Icons.add,
                                          size: 16,
                                          color: Colors.black87,
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          'Create Class',
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: BlocBuilder<KelasBloc, KelasState>(
                            builder: (context, state) {
                              if (state is KelasLoading) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                  ),
                                );
                              } else if (state is KelasLoaded) {
                                if (state.kelasList.isEmpty) {
                                  return _buildEmptyState();
                                }
                                return ListView.builder(
                                  itemCount: state.kelasList.length,
                                  itemBuilder: (context, index) {
                                    final kelas = state.kelasList[index];
                                    return KelasCard(
                                      kelas: kelas,
                                      onTap: () async {
                                        await context.pushNamed(
                                          'kelasDetail',
                                          pathParameters: {'kelasId': kelas.id},
                                        );
                                        if (context.mounted) {
                                          final user = (context.read<AuthBloc>().state
                                                  as AuthAuthenticated)
                                              .user;
                                          context.read<KelasBloc>().add(
                                                KelasFetchGuruRequested(user.id),
                                              );
                                        }
                                      },
                                    );
                                  },
                                );
                              } else if (state is KelasError) {
                                return Center(
                                  child: Text(
                                    state.message,
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                );
                              }
                              return const SizedBox();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String reviewCount(BuildContext context) {
    final subState = context.watch<SubmissionBloc>().state;
    if (subState is SubmissionReviewCountLoaded) {
      return subState.count == 0 ? '' : subState.count.toString();
    }
    return '';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.school_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada kelas',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai dengan membuat kelas baru',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String number,
    required String label,
    required Color color,
    double verticalMargin = 0.0,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: verticalMargin),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 2),
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
      ),
    );
  }

  Widget _buildPillButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 1.5),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(UserModel user, {required double size}) {
    ImageProvider? imageProvider;
    if (user.photoUrl != null) {
      if (user.photoUrl!.startsWith('http')) {
        imageProvider = NetworkImage(user.photoUrl!);
      } else {
        imageProvider = FileImage(File(user.photoUrl!));
      }
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        image: imageProvider != null
            ? DecorationImage(
                image: imageProvider,
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: imageProvider == null
          ? const Icon(
              Icons.person,
              color: Colors.white,
              size: 28,
            )
          : null,
    );
  }
}