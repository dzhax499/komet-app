import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/project_bloc.dart';

class DashboardGuestPage extends StatelessWidget {
  const DashboardGuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    const guestOwnerId = 'guest_user_id'; // Default ID for guest

    return BlocProvider(
      create: (context) => sl<ProjectBloc>()..add(FetchProjects(guestOwnerId)),
      child: Builder(
        builder: (context) {
          return Scaffold(
        backgroundColor: const Color(0xFF86B3C0), // Matching the provided image background
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  children: [
                    const Icon(Icons.account_circle_outlined, color: Colors.white, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      'Guest',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Project Section Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Project',
                      style: GoogleFonts.nunito(
                        fontSize: 24,
                        color: Colors.white,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showCreateProjectDialog(context, guestOwnerId),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF333333),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: Text(
                        'Create Project',
                        style: GoogleFonts.nunito(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Project List
              Expanded(
                child: BlocConsumer<ProjectBloc, ProjectState>(
                  listener: (context, state) {
                    if (state is ProjectError) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
                      );
                    } else if (state is ProjectActionSuccess) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.message), backgroundColor: AppColors.success),
                      );
                    } else if (state is ProjectCreatedSuccess) {
                       context.push('/canvas-workspace/${state.projectId}');
                    }
                  },
                  builder: (context, state) {
                    if (state is ProjectLoading) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    } else if (state is ProjectLoaded) {
                      if (state.projects.isEmpty) {
                        return Center(
                          child: Text(
                            'Belum ada project.',
                            style: GoogleFonts.nunito(color: Colors.white70),
                          ),
                        );
                      }
                      
                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        itemCount: state.projects.length,
                        itemBuilder: (context, index) {
                          final project = state.projects[index];
                          final isSynced = project.lastSyncedAt != null;
                          
                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF4A6B22), // Matching the dark green in image
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20), bottom: Radius.circular(0)), // The bottom corners curve in the actual app
                                  ),
                                  child: Row(
                                    children: [
                                      // Avatar Placeholder
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.white24,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: Colors.white, width: 2),
                                        ),
                                        child: ClipOval(
                                          // Placeholder for user image, we can just use an icon or default asset
                                          child: Icon(Icons.person, color: Colors.white, size: 40),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          project.title,
                                          style: GoogleFonts.nunito(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: IconButton(
                                          icon: const Icon(Icons.play_arrow, color: Color(0xFF4A6B22), size: 30),
                                          onPressed: () {
                                            context.push('/canvas-workspace/${project.id}');
                                          },
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  alignment: Alignment.center,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        isSynced ? 'Project Synced' : 'Local Project Saved',
                                        style: GoogleFonts.nunito(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      if (!isSynced) ...[
                                        const SizedBox(width: 8),
                                        IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: const BoxConstraints(),
                                          icon: const Icon(Icons.sync, size: 20, color: Colors.blue),
                                          onPressed: () {
                                            context.read<ProjectBloc>().add(SyncProject(project.id));
                                          },
                                        )
                                      ]
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }
    ),
    );
  }

  void _showCreateProjectDialog(BuildContext parentContext, String ownerId) {
    final titleController = TextEditingController();
    
    // We capture the bloc to dispatch to it from dialog
    final projectBloc = parentContext.read<ProjectBloc>();

    showGeneralDialog(
      context: parentContext,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.2), // Adjust gradient top color to match "glass"
                    const Color(0xFF4A6B22).withValues(alpha: 0.8), // Dark green at bottom
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.0),
                boxShadow: [
                   BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 5)),
                ]
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Create Project',
                    style: GoogleFonts.nunito(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, 
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.nunito(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Class ...',
                      hintStyle: GoogleFonts.nunito(color: Colors.white),
                      prefixIcon: const Icon(Icons.book, color: Colors.white),
                      filled: true,
                      fillColor: Colors.black.withValues(alpha: 0.4),
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(50),
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Container(
                      width: 200,
                      height: 45,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white,
                            Color(0xFF86B3C0), // matching button gradient based on image
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.2), offset: const Offset(0, 3), blurRadius: 5)
                        ]
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.trim().isNotEmpty) {
                            projectBloc.add(CreateProject(titleController.text.trim(), ownerId));
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                        ),
                        child: Text(
                          'Create',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
