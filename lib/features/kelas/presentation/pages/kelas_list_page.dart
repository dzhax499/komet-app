import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/kelas_model.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/kelas_bloc.dart';
import '../widgets/create_kelas_dialog.dart';
import '../widgets/join_kelas_dialog.dart';

class KelasListPage extends StatefulWidget {
  const KelasListPage({super.key});

  @override
  State<KelasListPage> createState() => _KelasListPageState();
}

class _KelasListPageState extends State<KelasListPage> {
  @override
  void initState() {
    super.initState();
    _fetchKelas();
  }

  void _fetchKelas() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      if (authState.user.role == 'guru') {
        context.read<KelasBloc>().add(KelasFetchGuruRequested(authState.user.id));
      } else {
        context.read<KelasBloc>().add(KelasFetchSiswaRequested(authState.user.id));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const Scaffold();
    final user = authState.user;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context, user),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: BlocConsumer<KelasBloc, KelasState>(
              listener: (context, state) {
                if (state is KelasError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.red),
                  );
                } else if (state is KelasActionSuccess) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message), backgroundColor: Colors.green),
                  );
                }
              },
              builder: (context, state) {
                if (state is KelasLoading) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (state is KelasLoaded) {
                  if (state.kelasList.isEmpty) {
                    return SliverFillRemaining(
                      child: _buildEmptyState(context, user),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildKelasCard(context, state.kelasList[index], user),
                      childCount: state.kelasList.length,
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox());
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showActionDialog(context, user),
        backgroundColor: AppColors.primary,
        icon: Icon(user.role == 'guru' ? Icons.add : Icons.group_add, color: Colors.white),
        label: Text(
          user.role == 'guru' ? 'Buat Kelas' : 'Gabung Kelas',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, UserModel user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          'Daftar Kelas',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 20,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.primary.withOpacity(0.05),
                Colors.white,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKelasCard(BuildContext context, KelasModel kelas, UserModel user) {
    return Container(
      margin: const EdgeInsets.bottom(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.pushNamed('kelasDetail', pathParameters: {'kelasId': kelas.id}),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Icon(Icons.class_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kelas.nama,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.people_outline, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${kelas.siswaIds.length} Siswa',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                          ),
                          const SizedBox(width: 12),
                          Icon(Icons.assignment_outlined, size: 14, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${kelas.assignmentIds.length} Tugas',
                            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, UserModel user) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.class_outlined, size: 64, color: Colors.grey[400]),
          ),
          const SizedBox(height: 24),
          Text(
            'Belum ada kelas',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user.role == 'guru'
                ? 'Mulai buat kelas pertamamu untuk berinteraksi dengan siswa.'
                : 'Minta kode kelas dari gurumu untuk bergabung.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  void _showActionDialog(BuildContext context, UserModel user) {
    if (user.role == 'guru') {
      showDialog(
        context: context,
        builder: (context) => CreateKelasDialog(
          onCreated: (nama) {
            context.read<KelasBloc>().add(KelasCreateRequested(nama: nama, guruId: user.id));
          },
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => JoinKelasDialog(
          onJoin: (kode) {
            context.read<KelasBloc>().add(KelasJoinRequested(kodeKelas: kode, siswaId: user.id));
          },
        ),
      );
    }
  }
}
