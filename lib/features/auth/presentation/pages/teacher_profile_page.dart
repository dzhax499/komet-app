import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/user_model.dart';
import '../bloc/auth_bloc.dart';
import '../../../kelas/presentation/bloc/kelas_bloc.dart';
import '../../../submission/presentation/bloc/submission_bloc.dart';
import '../../../submission/presentation/bloc/submission_event.dart';
import '../../../submission/presentation/bloc/submission_state.dart';

import 'dart:io';
import 'package:image_picker/image_picker.dart';

enum ProfileViewState { view, editName, editPhoto }

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});

  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  ProfileViewState _viewState = ProfileViewState.view;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    String initialName = '';
    if (state is AuthAuthenticated) {
      initialName = state.user.nama;
    }
    _nameController = TextEditingController(text: initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: Text('Please login first')),
          );
        }

        final user = state.user;

        return Scaffold(
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
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                      child: _buildContent(user),
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

  Widget _buildHeader() {
    String title = 'Profile';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          const Icon(Icons.school_outlined, color: Colors.white, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(UserModel user) {
    switch (_viewState) {
      case ProfileViewState.view:
        return _buildProfileView(user);
      case ProfileViewState.editName:
        return _buildEditNameView(user);
      case ProfileViewState.editPhoto:
        return _buildEditPhotoView(user);
    }
  }

  Widget _buildProfileView(UserModel user) {
    return Column(
      children: [
        _buildAvatar(user, size: 140),
        const SizedBox(height: 24),
        const Text(
          'Welcome back,',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        Text(
          user.nama,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => setState(() => _viewState = ProfileViewState.editName),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          ),
          child: const Text('Edit Profile'),
        ),
        const SizedBox(height: 40),
        _buildStatsSection(),
      ],
    );
  }

  Widget _buildEditNameView(UserModel user) {
    return Column(
      children: [
        _buildAvatar(user, size: 140, showEditIcon: true, onEdit: () {
          setState(() => _viewState = ProfileViewState.editPhoto);
        }),
        const SizedBox(height: 40),
        TextField(
          controller: _nameController,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: 'Input Name ...',
            hintStyle: const TextStyle(color: Colors.white70),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.2),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            context.read<AuthBloc>().add(AuthUpdateProfileRequested(nama: _nameController.text));
            setState(() => _viewState = ProfileViewState.view);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Widget _buildEditPhotoView(UserModel user) {
    return Column(
      children: [
        _buildAvatar(user, size: 140),
        const SizedBox(height: 40),
        _buildActionButton('Take Photo', () => _pickImage(ImageSource.camera)),
        const SizedBox(height: 12),
        _buildActionButton('Choose From Gallery', () => _pickImage(ImageSource.gallery)),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () => setState(() => _viewState = ProfileViewState.view),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.black87,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final XFile? pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (pickedFile != null) {
        if (mounted) {
          context.read<AuthBloc>().add(AuthUpdateProfileRequested(photoUrl: pickedFile.path));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil gambar: $e')),
        );
      }
    }
  }

  Widget _buildActionButton(String label, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF82903C),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(label),
      ),
    );
  }

  Widget _buildAvatar(UserModel user, {required double size, bool showEditIcon = false, VoidCallback? onEdit}) {
    ImageProvider? imageProvider;
    if (user.photoUrl != null) {
      if (user.photoUrl!.startsWith('http')) {
        imageProvider = NetworkImage(user.photoUrl!);
      } else {
        imageProvider = FileImage(File(user.photoUrl!));
      }
    }

    return Stack(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            color: Colors.white.withValues(alpha: 0.2),
            image: imageProvider != null
                ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                : null,
          ),
          child: imageProvider == null
              ? Icon(Icons.person, color: Colors.white, size: size * 0.5)
              : null,
        ),
        if (showEditIcon)
          Positioned(
            bottom: 0,
            right: 0,
            child: InkWell(
              onTap: onEdit,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: const Icon(Icons.edit, size: 16, color: Colors.black87),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return BlocBuilder<KelasBloc, KelasState>(
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
            context.read<SubmissionBloc>().add(GetReviewCountEvent(allAssignmentIds));
          }
        }

        return IntrinsicHeight(
          child: Row(
            children: [
              _buildSummaryCard(icon: Icons.class_, number: activeClassCount, label: 'Active Class', color: const Color(0xFF81B4C6)),
              _buildDivider(),
              _buildSummaryCard(icon: Icons.assignment, number: totalAssignments, label: 'Task', color: const Color(0xFF82903C)),
              _buildDivider(),
              BlocBuilder<SubmissionBloc, SubmissionState>(
                builder: (context, subState) {
                  String reviewCount = '0';
                  if (subState is SubmissionReviewCountLoaded) {
                    reviewCount = subState.count.toString();
                  }
                  return _buildSummaryCard(icon: Icons.video_label, number: reviewCount, label: 'Review', color: const Color(0xFF507877));
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Container(width: 1, color: Colors.white),
    );
  }

  Widget _buildSummaryCard({required IconData icon, required String number, required String label, required Color color}) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            Text(number, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
