import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/kelas_bloc.dart';

class DashboardSiswaPage extends StatelessWidget {
  const DashboardSiswaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return BlocProvider(
      create: (context) => sl<KelasBloc>()..add(KelasFetchSiswaRequested(user.id)),
      child: Scaffold(
        appBar: AppBar(
          title: Text('KOMET Siswa', style: GoogleFonts.nunito(fontWeight: FontWeight.bold)),
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
                      leading: const CircleAvatar(child: Icon(Icons.class_)),
                      title: Text(kelas.nama, style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold)),
                      subtitle: const Text('Ketuk untuk melihat tugas'),
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
          onPressed: () => _showJoinClassDialog(context, user.id),
          label: const Text('Gabung Kelas'),
          icon: const Icon(Icons.group_add),
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
          Icon(Icons.group_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Belum ada kelas',
            style: GoogleFonts.nunito(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Gunakan kode kelas dari gurumu untuk bergabung',
            style: GoogleFonts.inter(color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showJoinClassDialog(BuildContext context, String siswaId) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Gabung Kelas'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Masukkan 6 Digit Kode Kelas'),
          maxLength: 6,
          textCapitalization: TextCapitalization.characters,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () {
              if (controller.text.length == 6) {
                context.read<KelasBloc>().add(KelasJoinRequested(kodeKelas: controller.text.toUpperCase(), siswaId: siswaId));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Gabung'),
          ),
        ],
      ),
    );
  }
}
