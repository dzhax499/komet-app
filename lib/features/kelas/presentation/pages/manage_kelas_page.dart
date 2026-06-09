import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:boxicons/boxicons.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/models/kelas_model.dart';
import '../../../../core/models/user_model.dart';
import '../widgets/edit_kelas_dialog.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/kelas_bloc.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';
import '../widgets/komet_action_dialog.dart';
import 'student_detail_page.dart';

class ManageKelasPage extends StatefulWidget {
  final String kelasId;

  const ManageKelasPage({super.key, required this.kelasId});

  @override
  State<ManageKelasPage> createState() => _ManageKelasPageState();
}

class _ManageKelasPageState extends State<ManageKelasPage> {
  late KelasBloc _kelasBloc;
  KelasModel? _kelas;
  List<UserModel>? _students;
  
  final TextEditingController _searchStudentController = TextEditingController();
  String _searchStudentQuery = '';
  int _currentStudentPage = 1;
  final int _studentsPerPage = 5;

  @override
  void initState() {
    super.initState();
    _kelasBloc = sl<KelasBloc>();
    _kelasBloc.add(KelasFetchDetailRequested(widget.kelasId));
    _kelasBloc.add(KelasFetchStudentsRequested(widget.kelasId));
  }

  @override
  void dispose() {
    _kelasBloc.close();
    _searchStudentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isSmallScreen = screenSize.width < 360;

    return BlocProvider.value(
      value: _kelasBloc,
      child: BlocListener<KelasBloc, KelasState>(
        listener: (context, state) {
          if (state is KelasDetailLoaded) {
            setState(() => _kelas = state.kelas);
          } else if (state is KelasStudentsLoaded) {
            setState(() {
              _students = state.students;
              if (_kelas != null) {
                _kelas = _kelas!.copyWith(
                  siswaIds: state.students.map((e) => e.id).toList(),
                );
              }
            });
          } else if (state is KelasActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green,
              ),
            );
            if (state.message.contains('Kelas berhasil dihapus')) {
              context.pop(true);
            } else {
              _kelasBloc.add(KelasFetchDetailRequested(widget.kelasId));
              _kelasBloc.add(KelasFetchStudentsRequested(widget.kelasId));
            }
          } else if (state is KelasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF86B3C0), Color(0xFFE3E2E0)],
                stops: [0.0, 1.0],
              ),
            ),
            child: SafeArea(
              child: (_kelas == null)
                  ? const Center(child: CircularProgressIndicator())
                  : CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: _buildHeader(context, isSmallScreen),
                        ),
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: _buildClassCard(context, isSmallScreen),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 16)),
                        _buildStudentListSliver(context, isSmallScreen),
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Column(
                            children: [
                              if (_students?.isEmpty ?? false)
                                Expanded(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(32.0),
                                      child: Text(
                                        "Belum ada siswa di kelas ini",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.nunito(
                                          color: Colors.white70,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                              else
                                const Spacer(),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 32,
                                ),
                                child: _buildRemoveClassButton(
                                  context,
                                  isSmallScreen,
                                ),
                              ),
                            ],
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

  Widget _buildHeader(BuildContext context, bool isSmall) {
    final authState = context.read<AuthBloc>().state;
    UserModel? user;
    if (authState is AuthAuthenticated) {
      user = authState.user;
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 16 : 24,
        vertical: 16,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Image.asset(
                      'assets/images/logo.png',
                      height: isSmall ? 24 : 28,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Teacher Hub',
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (user != null)
                _buildProfileAvatar(user, size: isSmall ? 48 : 64),
            ],
          ),
          const SizedBox(height: 8),
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.reply,
              color: Colors.white,
              size: isSmall ? 32 : 40,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileAvatar(UserModel user, {required double size}) {
    ImageProvider? imageProvider;
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
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
        image: imageProvider != null
            ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
            : null,
      ),
      child: imageProvider == null
          ? Icon(Icons.person, color: Colors.white, size: size * 0.5)
          : null,
    );
  }

  Widget _buildClassCard(BuildContext context, bool isSmall) {
    final kelas = _kelas!;
    String initial = kelas.nama.isNotEmpty
        ? kelas.nama
              .substring(0, kelas.nama.length > 2 ? 2 : kelas.nama.length)
              .toUpperCase()
        : "C";

    return Container(
      margin: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 24),
      padding: EdgeInsets.all(isSmall ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6B7E25), Color(0xFF1F410F)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: isSmall ? 36 : 44,
                    height: isSmall ? 36 : 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.nunito(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: isSmall ? 14 : 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showEditDialog(context, kelas),
                    child: Icon(
                      Boxicons.bxs_edit,
                      color: Colors.white,
                      size: isSmall ? 20 : 24,
                    ),
                  ),
                ],
              ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4C7573),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Code: ${kelas.kodeKelas}',
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.nunito(
                      color: Colors.white,
                      fontSize: isSmall ? 12 : 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildInfoTag(
                Icons.people,
                '${kelas.siswaIds.length} Student',
                isSmall,
              ),
              Container(width: 1.5, height: 28, color: Colors.white38),
              _buildInfoTag(
                MingCuteIcons.mgc_task_2_fill,
                '${kelas.assignmentIds.length} Task',
                isSmall,
              ),
              Container(width: 1.5, height: 28, color: Colors.white38),
              _buildInfoTag(Icons.mail, '0 Mail', isSmall),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, KelasModel kelas) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (dialogContext) => EditKelasDialog(
        kelas: kelas,
        onUpdated: (newNama) {
          final user =
              (context.read<AuthBloc>().state as AuthAuthenticated).user;
          _kelasBloc.add(
            KelasUpdateRequested(
              kelasId: kelas.id,
              newNama: newNama,
              guruId: user.id,
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoTag(IconData icon, String label, bool isSmall) {
    return Flexible(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 6 : 10,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1B3810),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: isSmall ? 12 : 14),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.nunito(
                  color: Colors.white,
                  fontSize: isSmall ? 10 : 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentListSliver(BuildContext context, bool isSmall) {
    if (_students == null) {
      return const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final students = _students!;

    // Filter and paginate
    final filteredStudents = students.where((s) {
      return s.nama.toLowerCase().contains(_searchStudentQuery.toLowerCase());
    }).toList();

    int totalPages = (filteredStudents.length / _studentsPerPage).ceil();
    if (totalPages == 0) totalPages = 1;
    if (_currentStudentPage > totalPages) _currentStudentPage = totalPages;

    int startIndex = (_currentStudentPage - 1) * _studentsPerPage;
    int endIndex = startIndex + _studentsPerPage;
    if (endIndex > filteredStudents.length) endIndex = filteredStudents.length;

    final paginatedStudents = filteredStudents.sublist(startIndex, endIndex);

    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 16 : 24),
        child: Column(
          children: [
            if (students.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white),
                ),
                child: TextField(
                  controller: _searchStudentController,
                  style: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'Search ..',
                    hintStyle: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
                    border: InputBorder.none,
                    suffixIcon: _searchStudentQuery.isNotEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          _searchStudentController.clear();
                                          setState(() {
                                            _searchStudentQuery = '';
                                            _currentStudentPage = 1;
                                          });
                                        },
                                        child: const Icon(Icons.close, color: Colors.white, size: 20),
                                      )
                                    : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchStudentQuery = value;
                      _currentStudentPage = 1;
                    });
                  },
                ),
              ),
            if (filteredStudents.isEmpty && students.isNotEmpty)
              Center(
                child: Text(
                  "No student found",
                  style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16),
                ),
              )
            else
              ...paginatedStudents.map((student) => Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF507877),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _buildProfileAvatar(student, size: isSmall ? 40 : 56),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        student.nama,
                        style: GoogleFonts.nunito(
                          color: Colors.white,
                          fontSize: isSmall ? 16 : 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider.value(
                            value: context.read<KelasBloc>(),
                            child: StudentDetailPage(
                              student: student,
                              kelasId: widget.kelasId,
                            ),
                          ),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 10 : 16,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Detail',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmall ? 11 : 13,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () => _showRemoveStudentDialog(context, student),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmall ? 10 : 16,
                          vertical: 6,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        'Remove',
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w600,
                          fontSize: isSmall ? 11 : 13,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            if (totalPages > 1)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.white),
                      onPressed: _currentStudentPage > 1
                          ? () => setState(() => _currentStudentPage--)
                          : null,
                    ),
                    Text(
                      'Page $_currentStudentPage of $totalPages',
                      style: GoogleFonts.nunito(color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.white),
                      onPressed: _currentStudentPage < totalPages
                          ? () => setState(() => _currentStudentPage++)
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showRemoveStudentDialog(BuildContext context, UserModel student) {
    showDialog(
      context: context,
      builder: (ctx) => KometActionDialog(
        title: 'Remove Student',
        content:
            'Apakah Anda yakin ingin menghapus ${student.nama} dari kelas ini?',
        confirmLabel: 'Remove',
        isDestructive: true,
        onConfirm: () {
          _kelasBloc.add(
            KelasRemoveStudentRequested(
              kelasId: widget.kelasId,
              siswaId: student.id,
            ),
          );
        },
      ),
    );
  }

  Widget _buildRemoveClassButton(BuildContext context, bool isSmall) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          width: isSmall ? 200 : 240,
          height: isSmall ? 56 : 64,
          child: ElevatedButton(
            onPressed: () => _showRemoveClassDialog(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 4,
            ),
            child: Text(
              'Remove Class',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: isSmall ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showRemoveClassDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => KometActionDialog(
        title: 'Remove Class',
        content:
            'Apakah Anda yakin ingin menghapus kelas ini? Semua data terkait kelas akan dihapus dan tidak dapat dikembalikan.',
        confirmLabel: 'Remove',
        isDestructive: true,
        onConfirm: () {
          final user =
              (context.read<AuthBloc>().state as AuthAuthenticated).user;
          _kelasBloc.add(
            KelasDeleteRequested(kelasId: widget.kelasId, guruId: user.id),
          );
        },
      ),
    );
  }
}
