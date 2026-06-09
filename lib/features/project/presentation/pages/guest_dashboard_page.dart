import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/submission_model.dart';
import '../../../kelas/presentation/pages/submission_canvas_page.dart';
import '../../../submission/presentation/bloc/submission_bloc.dart';

class GuestDashboardPage extends StatefulWidget {
  const GuestDashboardPage({super.key});

  @override
  State<GuestDashboardPage> createState() => _GuestDashboardPageState();
}

class _GuestDashboardPageState extends State<GuestDashboardPage> {
  // KOMET palette (same as DashboardSiswaPage)
  static const Color _moonstoneBlue = Color(0xFF6FA9BB);
  static const Color _mustardGreen = Color(0xFF687D31);
  static const Color _lightGray = Color(0xFFD5D3CC);
  static const Color _phthaloGreen = Color(0xFF19350C);

  List<SubmissionModel> _guestProjects = [];

  @override
  void initState() {
    super.initState();
    _loadGuestProjects();
  }

  void _loadGuestProjects() {
    final allSubs = sl<HiveService>().submissionBoxInstance.values.toList();
    final guestSubs = allSubs.where((p) => p.siswaId == 'guest').toList();
    guestSubs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    setState(() {
      _guestProjects = guestSubs;
    });
  }

  String _extractTitle(SubmissionModel project) {
    try {
      if (project.storyDataJson.isNotEmpty) {
        final data = jsonDecode(project.storyDataJson);
        if (data['title'] != null && data['title'].toString().isNotEmpty) {
          return data['title'];
        }
      }
    } catch (_) {}
    return 'Untitled Story';
  }

  void _createNewProject() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) {
        final titleController = TextEditingController();
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('New Story', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: titleController,
                    style: GoogleFonts.nunito(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Enter story name...',
                      hintStyle: GoogleFonts.nunito(color: Colors.white54),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha: 0.1),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Create button
                  GestureDetector(
                    onTap: () {
                      final title = titleController.text.trim().isEmpty
                          ? 'Untitled Story'
                          : titleController.text.trim();
                      Navigator.pop(context);
                      _navigateToEditor(title: title);
                    },
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFD4E9EC),
                            const Color(0xFF90C2C8).withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      alignment: Alignment.center,
                      child: Text('Create', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: _phthaloGreen)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Cancel', style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToEditor({required String title, SubmissionModel? initialSubmission}) {
    final assignmentId = initialSubmission?.assignmentId ?? const Uuid().v4();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: sl<SubmissionBloc>(),
          child: SubmissionCanvasPage(
            assignmentId: assignmentId,
            assignmentTitle: title,
            deadline: '',
            studentId: 'guest',
            initialSubmission: initialSubmission,
          ),
        ),
      ),
    ).then((_) {
      _loadGuestProjects();
    });
  }

  void _deleteProject(SubmissionModel project) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (ctx) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Delete Story', style: GoogleFonts.nunito(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete "${_extractTitle(project)}"?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(ctx);
                    sl<HiveService>().submissionBoxInstance.delete(project.id);
                    _loadGuestProjects();
                  },
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [const Color(0xFFE5B5B1), const Color(0xFFC77A75).withValues(alpha: 0.8)]),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: Text('Delete', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: _phthaloGreen)),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => Navigator.pop(ctx),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [const Color(0xFFD4E9EC), const Color(0xFF90C2C8).withValues(alpha: 0.8)]),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    alignment: Alignment.center,
                    child: Text('Cancel', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w600, color: _phthaloGreen)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient (matching DashboardSiswaPage)
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset('assets/images/logo.png', height: 18, width: 18, fit: BoxFit.contain),
                          const SizedBox(width: 8),
                          Text('Guest Mode', style: GoogleFonts.nunito(fontSize: 16, fontWeight: FontWeight.w400, color: Colors.white)),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.go(KometRoutes.login),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.login, size: 14, color: Colors.black87),
                              const SizedBox(width: 6),
                              Text('Login', style: GoogleFonts.nunito(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text('Welcome,', style: GoogleFonts.nunito(fontSize: 15, color: Colors.white)),
                  Text('Guest Creator', style: GoogleFonts.nunito(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),

                  // Stat Cards
                  IntrinsicHeight(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard(_moonstoneBlue, Icons.auto_stories, '${_guestProjects.length}', 'Stories'),
                        const VerticalDivider(color: Colors.white, thickness: 1.2, width: 2),
                        _buildStatCard(_mustardGreen, Icons.save_alt, '${_guestProjects.length}', 'Saved'),
                        const VerticalDivider(color: Colors.white, thickness: 1.2, width: 2),
                        _buildStatCard(const Color(0xFF406768), Icons.cloud_off, 'Local', 'Storage'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Section Title + Create Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('My Stories', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.w400, color: Colors.white)),
                      GestureDetector(
                        onTap: _createNewProject,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.add, size: 14, color: Colors.black87),
                              const SizedBox(width: 4),
                              Text('New Story', style: GoogleFonts.nunito(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Project List
                  Expanded(
                    child: _guestProjects.isEmpty
                        ? _buildEmptyState()
                        : _buildProjectList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_outlined, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text('No stories yet', style: GoogleFonts.nunito(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)),
          const SizedBox(height: 8),
          Text(
            'Tap "New Story" to start creating.\nYour work is saved locally and can be\nsubmitted after login!',
            style: GoogleFonts.nunito(color: Colors.white60, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return ListView.separated(
      itemCount: _guestProjects.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final project = _guestProjects[index];
        final title = _extractTitle(project);
        final date = '${project.updatedAt.day}/${project.updatedAt.month}/${project.updatedAt.year}';

        return GestureDetector(
          onTap: () => _navigateToEditor(title: title, initialSubmission: project),
          onLongPress: () => _deleteProject(project),
          child: Container(
            width: double.infinity,
            height: 108,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [_mustardGreen, _phthaloGreen],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(28),
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
                    title.length >= 2 ? title.substring(0, 2).toUpperCase() : title.toUpperCase(),
                    style: GoogleFonts.nunito(fontSize: 28, fontWeight: FontWeight.w400, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(title, style: GoogleFonts.nunito(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      const Divider(color: Colors.white54, thickness: 1, height: 1),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildCompactBadge(Icons.calendar_today, date),
                          const SizedBox(width: 8),
                          _buildCompactBadge(Icons.save, 'Local'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white54),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(Color color, IconData icon, String value, String label) {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.nunito(fontSize: 24, fontWeight: FontWeight.w500, color: Colors.white)),
          Text(label, style: GoogleFonts.nunito(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }

  Widget _buildCompactBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _phthaloGreen, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 12),
          const SizedBox(width: 6),
          Text(text, style: GoogleFonts.nunito(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w400)),
        ],
      ),
    );
  }
}
