import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/kelas_bloc.dart';

class DashboardGuruPage extends StatelessWidget {
  const DashboardGuruPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return BlocProvider(
      create: (context) => sl<KelasBloc>()..add(KelasFetchGuruRequested(user.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('KOMET Guru', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
                context.go(KometRoutes.login);
              },
            ),
          ],
        ),
        body: BlocBuilder<KelasBloc, KelasState>(
          builder: (context, state) {
            if (state is KelasLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is KelasLoaded) {
              if (state.kelasList.isEmpty) {
                return _buildEmptyState(context);
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.kelasList.length,
                itemBuilder: (context, index) {
                  final kelas = state.kelasList[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      title: Text(kelas.nama, style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: Text('Kode: ${kelas.kodeKelas}', style: GoogleFonts.inter(color: AppColors.primary, fontWeight: FontWeight.bold)),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        context.pushNamed('kelasDetail', pathParameters: {'kelasId': kelas.id});
                      },
                    ),
                  );
                },
              );
            } else if (state is KelasError) {
              return Center(child: Text(state.message));
            }
            return const SizedBox();
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showCreateClassDialog(context, user.id),
          label: const Text('Buat Kelas'),
          icon: const Icon(Icons.add),
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada kelas',
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai dengan membuat kelas baru',
            style: GoogleFonts.inter(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _showCreateClassDialog(BuildContext context, String guruId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Buat Kelas Baru'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Nama Kelas (misal: Kelas 5A)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<KelasBloc>().add(KelasCreateRequested(nama: controller.text, guruId: guruId));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Buat'),
          ),
        ],
      ),
    );
  }
}
