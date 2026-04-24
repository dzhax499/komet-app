
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/kelas_bloc.dart';
import '../widgets/create_kelas_dialog.dart'; 

class DashboardGuruPage extends StatelessWidget {
  const DashboardGuruPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return BlocProvider(
      create: (context) => sl<KelasBloc>()..add(KelasFetchGuruRequested(user.id)),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF86B3C0), // Light blue-grey top
                Color(0xFFE3E2E0), // Light grey bottom
              ],
              stops: [0.0, 1.0],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school_outlined, color: Colors.white, size: 28),
                          const SizedBox(width: 8),
                          const Text(
                            'Teacher Hub',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.white),
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                          context.go(KometRoutes.login);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Welcome Text
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

                  // Summary Cards
                  BlocBuilder<KelasBloc, KelasState>(
                    builder: (context, state) {
                      String activeClassCount = '0';
                      if (state is KelasLoaded) {
                        activeClassCount = state.kelasList.length.toString();
                      }

                      return IntrinsicHeight(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildSummaryCard(
                              icon: Icons.class_,
                              number: activeClassCount, 
                              label: 'Active Class',
                              color: const Color(0xFF81B4C6),
                              verticalMargin: 12.0,
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Container(width: 1, color: Colors.white.withValues(alpha: 0.9)),
                            ),
                            const SizedBox(width: 8),
                            _buildSummaryCard(
                              icon: Icons.assignment,
                              number: '0', 
                              label: 'Task',
                              color: const Color(0xFF82903C),
                              verticalMargin: 0.0,
                            ),
                            const SizedBox(width: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Container(width: 1, color: Colors.white.withValues(alpha: 0.9)),
                            ),
                            const SizedBox(width: 8),
                            _buildSummaryCard(
                              icon: Icons.video_label,
                              number: '0', 
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

                  // My Class Header
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
                              // PANGGIL WIDGET DIALOG BARU DI SINI
                              showDialog(
                                context: blocContext,
                                barrierColor: Colors.black.withValues(alpha: 0.2),
                                builder: (context) => CreateKelasDialog(
                                  onCreated: (nama) {
                                    blocContext.read<KelasBloc>().add(
                                      KelasCreateRequested(nama: nama, guruId: user.id)
                                    );
                                  },
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.add, size: 16, color: Colors.black87),
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
                    }
                  ),
                  const SizedBox(height: 16),

                  // Class Card List
                  Expanded(
                    child: BlocBuilder<KelasBloc, KelasState>(
                      builder: (context, state) {
                        if (state is KelasLoading) {
                          return const Center(child: CircularProgressIndicator(color: Colors.white));
                        } else if (state is KelasLoaded) {
                          if (state.kelasList.isEmpty) {
                            return _buildEmptyState();
                          }
                          return ListView.builder(
                            itemCount: state.kelasList.length,
                            itemBuilder: (context, index) {
                              final kelas = state.kelasList[index];
                              return _buildClassCard(context, kelas);
                            },
                          );
                        } else if (state is KelasError) {
                          return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
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
    );
  }

  Widget _buildClassCard(BuildContext context, dynamic kelas) {
    String initial = kelas.nama.isNotEmpty 
        ? kelas.nama.substring(0, kelas.nama.length > 2 ? 2 : kelas.nama.length).toUpperCase() 
        : "C";

    return GestureDetector(
      onTap: () {
        context.pushNamed('kelasDetail', pathParameters: {'kelasId': kelas.id});
      },
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
            const SizedBox(height: 12),
            Text(
              kelas.nama,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildClassInfoTag(Icons.people, 'Students'),
                Container(width: 1, height: 24, color: Colors.white54),
                _buildClassInfoTag(Icons.assignment, 'Tasks'),
                Container(width: 1, height: 24, color: Colors.white54),
                _buildClassInfoTag(Icons.mail, 'Mails'),
              ],
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
          Icon(Icons.school_outlined, size: 80, color: Colors.white.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'Belum ada kelas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai dengan membuat kelas baru',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
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
            Icon(icon, color: Colors.white, size: 24),
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

  Widget _buildClassInfoTag(IconData icon, String label) {
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