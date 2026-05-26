import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:ming_cute_icons/ming_cute_icons.dart';

class DashboardGuruPage extends StatefulWidget {
  const DashboardGuruPage({super.key});

  @override
  State<DashboardGuruPage> createState() => _DashboardGuruPageState();
}

class _DashboardGuruPageState extends State<DashboardGuruPage> {
  bool _isProfileMenuOpen = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _currentPage = 1;
  final int _itemsPerPage = 5;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final isSmallScreen = screenSize.width < 360;

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
              create: (context) =>
                  sl<KelasBloc>()..add(KelasFetchGuruRequested(user.id)),
            ),
            BlocProvider<SubmissionBloc>(
              create: (context) => sl<SubmissionBloc>(),
            ),
          ],
          child: Builder(
            builder: (innerContext) {
              return GestureDetector(
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
                        colors: [Color(0xFF86B3C0), Color(0xFFE3E2E0)],
                        stops: [0.0, 1.0],
                      ),
                    ),
                    child: SafeArea(
                      child: RefreshIndicator(
                        onRefresh: () async {
                          innerContext.read<KelasBloc>().add(
                            KelasFetchGuruRequested(user.id),
                          );
                        },
                        child: ListView(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 16.0 : 24.0,
                            vertical: 20.0,
                          ),
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          children: [
                            _buildHeader(innerContext, user, isSmallScreen),
                            const SizedBox(height: 24),
                            Text(
                              'Welcome back,',
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 18 : 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.nama,
                              style: GoogleFonts.nunito(
                                color: Colors.white,
                                fontSize: isSmallScreen ? 22 : 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildSummarySection(isSmallScreen),
                            const SizedBox(height: 32),
                            _buildKelasSection(
                              innerContext,
                              user,
                              isSmallScreen,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user, bool isSmall) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              height: isSmall ? 24 : 28,
            ),
            const SizedBox(width: 8),
            Text(
              'Teacher Hub',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
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
              onTap: () =>
                  setState(() => _isProfileMenuOpen = !_isProfileMenuOpen),
              child: _buildProfileAvatar(user, size: isSmall ? 48 : 52),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummarySection(bool isSmall) {
    return BlocBuilder<KelasBloc, KelasState>(
      buildWhen: (previous, current) =>
          current is KelasLoading ||
          current is KelasLoaded ||
          current is KelasError,
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildSummaryCard(
                  icon: Icons.class_,
                  number: activeClassCount,
                  label: 'Active Class',
                  color: const Color(0xFF81B4C6),
                  isSmall: isSmall,
                ),
              ),
              const SizedBox(width: 8),
              VerticalDivider(
                color: Colors.white.withValues(alpha: 0.9),
                thickness: 1,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryCard(
                  icon: MingCuteIcons.mgc_task_2_fill,
                  number: totalAssignments,
                  label: 'Task',
                  color: const Color(0xFF84953D),
                  isSmall: isSmall,
                ),
              ),
              const SizedBox(width: 8),
              VerticalDivider(
                color: Colors.white.withValues(alpha: 0.9),
                thickness: 1,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: BlocBuilder<SubmissionBloc, SubmissionState>(
                  builder: (context, subState) {
                    String reviewCount = '0';
                    if (subState is SubmissionReviewCountLoaded) {
                      reviewCount = subState.count.toString();
                    }
                    return _buildSummaryCard(
                      icon: Symbols.inbox,
                      number: reviewCount,
                      label: 'Review',
                      color: const Color(0xFF4C7573),
                      isSmall: isSmall,
                      fill: 1.0,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKelasSection(
    BuildContext context,
    UserModel user,
    bool isSmall,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'My Class',
              style: GoogleFonts.nunito(
                color: Colors.white,
                fontSize: isSmall ? 20 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  barrierColor: Colors.black.withValues(alpha: 0.2),
                  builder: (dialogContext) => CreateKelasDialog(
                    onCreated: (nama) {
                      context.read<KelasBloc>().add(
                        KelasCreateRequested(nama: nama, guruId: user.id),
                      );
                    },
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '+ Create Class',
                  style: GoogleFonts.nunito(
                    color: Colors.black87,
                    fontSize: isSmall ? 12 : 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocListener<KelasBloc, KelasState>(
          listener: (context, state) {
            if (state is KelasActionSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is KelasError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          child: BlocBuilder<KelasBloc, KelasState>(
            buildWhen: (previous, current) =>
                current is KelasLoading ||
                current is KelasLoaded ||
                current is KelasError,
            builder: (context, state) {
              if (state is KelasLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is KelasLoaded) {
                if (state.kelasList.isEmpty) {
                  return Center(
                    child: Text(
                      "You don't have any class yet",
                      style: GoogleFonts.nunito(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                // Filter and Paginate
                final filteredList = state.kelasList.where((k) {
                  return k.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                         k.kodeKelas.toLowerCase().contains(_searchQuery.toLowerCase());
                }).toList();

                int totalPages = (filteredList.length / _itemsPerPage).ceil();
                if (totalPages == 0) totalPages = 1;
                if (_currentPage > totalPages) _currentPage = totalPages;

                int startIndex = (_currentPage - 1) * _itemsPerPage;
                int endIndex = startIndex + _itemsPerPage;
                if (endIndex > filteredList.length) endIndex = filteredList.length;

                final paginatedList = filteredList.sublist(startIndex, endIndex);

                return Column(
                  children: [
                    // Search Bar
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
                        decoration: InputDecoration(
                          isDense: true,
                          hintText: 'Search....',
                          hintStyle: GoogleFonts.nunito(color: Colors.white, fontSize: 14),
                          border: InputBorder.none,
                          suffixIcon: _searchQuery.isNotEmpty
                               ? GestureDetector(
                                   onTap: () {
                                     _searchController.clear();
                                     setState(() {
                                       _searchQuery = '';
                                       _currentPage = 1;
                                     });
                                   },
                                   child: const Icon(Icons.close, color: Colors.white, size: 20),
                                 )
                               : null,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                            _currentPage = 1; // reset to first page on search
                          });
                        },
                      ),
                    ),
                    if (filteredList.isEmpty)
                      Center(
                        child: Text(
                          "No class found",
                          style: GoogleFonts.nunito(color: Colors.white70, fontSize: 16),
                        ),
                      )
                    else ...[
                      ...paginatedList.map(
                        (kelas) => KelasCard(
                          kelas: kelas,
                          onTap: () {
                            context.pushNamed(
                              'kelasDetail',
                              pathParameters: {'kelasId': kelas.id},
                            );
                          },
                          onEdit: () async {
                            final result = await context.pushNamed(
                              'manageKelas',
                              pathParameters: {'kelasId': kelas.id},
                            );
                            if (result == true) {
                              if (context.mounted) {
                                context.read<KelasBloc>().add(
                                  KelasFetchGuruRequested(user.id),
                                );
                              }
                            }
                          },
                        ),
                      ),
                      // Pagination Controls
                      if (totalPages > 1)
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.chevron_left, color: Colors.white),
                                onPressed: _currentPage > 1
                                    ? () => setState(() => _currentPage--)
                                    : null,
                              ),
                              Text(
                                'Page $_currentPage of $totalPages',
                                style: GoogleFonts.nunito(color: Colors.white),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right, color: Colors.white),
                                onPressed: _currentPage < totalPages
                                    ? () => setState(() => _currentPage++)
                                    : null,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ],
                );
              }

              if (state is KelasError) {
                return Center(
                  child: Text(
                    state.message,
                    style: GoogleFonts.nunito(color: Colors.red),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String number,
    required String label,
    required Color color,
    required bool isSmall,
    double fill = 0.0,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: isSmall ? 20 : 24, fill: fill),
          const SizedBox(height: 8),
          Text(
            number,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: isSmall ? 24 : 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.nunito(
              color: Colors.white,
              fontSize: isSmall ? 10 : 12,
              fontWeight: FontWeight.w400,
            ),
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

  Widget _buildPillButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.nunito(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
