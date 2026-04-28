// lib/core/router/app_router.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Konfigurasi routing terpusat menggunakan GoRouter.
// SEMUA route path didefinisikan di KometRoutes (core/utils/constants.dart).
//
// PIC lain: JANGAN mendefinisikan route baru di sini sendiri.
// Koordinasi dengan PIC D untuk menambahkan route baru.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_siswa_page.dart';
import '../../features/auth/presentation/pages/register_guru_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/get_started_page.dart';
import '../../features/kelas/presentation/pages/dashboard_guru_page.dart';
import '../../features/kelas/presentation/pages/dashboard_siswa_page.dart';
import '../../features/kelas/presentation/pages/kelas_detail_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/kelas/presentation/pages/review_submission_page.dart';
import '../models/submission_model.dart';

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final String pic;
  const _PlaceholderScreen({required this.title, required this.pic});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.construction, size: 64, color: Colors.amber),
            const SizedBox(height: 16),
            Text(title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Dikerjakan oleh $pic',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

// ── Router Instance ──────────────────────────────────────────────────────────

/// Instance GoRouter singleton. Gunakan via GetIt: sl<GoRouter>()
/// atau langsung di MaterialApp.router sebagai routerConfig.
final GoRouter appRouter = GoRouter(
  initialLocation: KometRoutes.splash,
  debugLogDiagnostics: true, // Matikan saat release
  routes: [
    // ── Splash / Initial ──────────────────────────────────────────
    GoRoute(
      path: KometRoutes.splash,
      name: 'splash',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: KometRoutes.getStarted,
      name: 'getStarted',
      builder: (context, state) => const GetStartedPage(),
    ),

    // ── Auth (PIC A) ──────────────────────────────────────────────
    GoRoute(
      path: KometRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: KometRoutes.registerSiswa,
      name: 'registerSiswa',
      builder: (context, state) => const RegisterSiswaPage(),
    ),
    GoRoute(
      path: KometRoutes.registerGuru,
      name: 'registerGuru',
      builder: (context, state) => const RegisterGuruPage(),
    ),

    // ── Dashboard ─────────────────────────────────────────────────
    GoRoute(
      path: KometRoutes.dashboardGuru,
      name: 'dashboardGuru',
      builder: (context, state) => const DashboardGuruPage(), // PIC B (Helga)
    ),
    GoRoute(
      path: KometRoutes.dashboardSiswa,
      name: 'dashboardSiswa',
      builder: (context, state) => const DashboardSiswaPage(), // PIC C (Nike)
    ),

    // ── Kelas (PIC B - Helga) ─────────────────────────────────────
    GoRoute(
      path: KometRoutes.kelasDetail,
      name: 'kelasDetail',
      builder: (context, state) {
        final kelasId = state.pathParameters['kelasId']!;
        return KelasDetailPage(kelasId: kelasId);
      },
    ),
    // ── Review Submission (PIC B - Helga) ──────────────────────────
    GoRoute(
      path: '/review-submission', 
      name: 'reviewDetail', 
      builder: (context, state) {
        final extra = state.extra as Map;
        final submission = extra['submission'] as SubmissionModel;
        final title = extra['assignmentTitle'] as String;
        return ReviewSubmissionPage(submission: submission, assignmentTitle: title);
      },
    ),
    // ── Assignment (PIC A) ────────────────────────────────────────
    GoRoute(
      path: KometRoutes.assignmentDetail,
      name: 'assignmentDetail',
      builder: (context, state) {
        final assignmentId = state.pathParameters['assignmentId']!;
        return _PlaceholderScreen(
          title: 'Assignment: $assignmentId',
          pic: 'PIC A (Wyandhanu)',
        );
      },
    ),

    // ── Editor Canvas (PIC D) ─────────────────────────────────────
    GoRoute(
      path: KometRoutes.editorCanvas,
      name: 'editorCanvas',
      builder: (context, state) {
        final submissionId = state.pathParameters['submissionId']!;
        // Importnya akan ditambahkan setelah editor_canvas selesai
        return _PlaceholderScreen(
          title: 'Editor Cerita: $submissionId',
          pic: 'PIC D (Dzakir)',
        );
      },
    ),
    GoRoute(
      path: KometRoutes.storyMap,
      name: 'storyMap',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Peta Alur Cerita',
        pic: 'PIC D (Dzakir)',
      ),
    ),

    // ── Submission (PIC B & C) ────────────────────────────────────
    GoRoute(
      path: KometRoutes.submissionDetail,
      name: 'submissionDetail',
      builder: (context, state) {
        final submissionId = state.pathParameters['submissionId']!;
        return _PlaceholderScreen(
          title: 'Submission: $submissionId',
          pic: 'PIC B (Helga) & PIC C (Nike)',
        );
      },
    ),


    // ── Notifikasi (PIC A) ────────────────────────────────────────
    GoRoute(
      path: KometRoutes.notifications,
      name: 'notifications',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Notifikasi',
        pic: 'PIC A (Wyandhanu)',
      ),
    ),
  ],

  // ── Error Handler ─────────────────────────────────────────────
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text('Halaman tidak ditemukan: ${state.uri}'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.go(KometRoutes.splash),
            child: const Text('Kembali ke Awal'),
          ),
        ],
      ),
    ),
  ),
);

