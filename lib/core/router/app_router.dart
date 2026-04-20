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

// ── Placeholder screens untuk route milik PIC lain ──────────────────────────
// Akan diganti oleh implementasi real saat ready.

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
      builder: (context, state) => const _SplashScreen(),
    ),

    // ── Auth (PIC A) ──────────────────────────────────────────────
    GoRoute(
      path: KometRoutes.login,
      name: 'login',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Login',
        pic: 'PIC A (Wyandhanu)',
      ),
    ),
    GoRoute(
      path: KometRoutes.registerSiswa,
      name: 'registerSiswa',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Register Siswa',
        pic: 'PIC A (Wyandhanu)',
      ),
    ),
    GoRoute(
      path: KometRoutes.registerGuru,
      name: 'registerGuru',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Register Guru',
        pic: 'PIC A (Wyandhanu)',
      ),
    ),

    // ── Dashboard (PIC A) ─────────────────────────────────────────
    GoRoute(
      path: KometRoutes.dashboardGuru,
      name: 'dashboardGuru',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Dashboard Guru',
        pic: 'PIC A (Wyandhanu)',
      ),
    ),
    GoRoute(
      path: KometRoutes.dashboardSiswa,
      name: 'dashboardSiswa',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Dashboard Siswa',
        pic: 'PIC A (Wyandhanu)',
      ),
    ),

    // ── Kelas (PIC A) ─────────────────────────────────────────────
    GoRoute(
      path: KometRoutes.kelasList,
      name: 'kelasList',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Daftar Kelas',
        pic: 'PIC A (Wyandhanu)',
      ),
    ),
    GoRoute(
      path: KometRoutes.kelasDetail,
      name: 'kelasDetail',
      builder: (context, state) {
        final kelasId = state.pathParameters['kelasId']!;
        return _PlaceholderScreen(
          title: 'Detail Kelas: $kelasId',
          pic: 'PIC A (Wyandhanu)',
        );
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

    // ── Review (PIC A) ────────────────────────────────────────────
    GoRoute(
      path: KometRoutes.reviewDetail,
      name: 'reviewDetail',
      builder: (context, state) => const _PlaceholderScreen(
        title: 'Review & Penilaian',
        pic: 'PIC A (Wyandhanu)',
      ),
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

// ── Splash Screen (sementara, milik PIC D) ──────────────────────────────────

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    // TODO PIC A: Ganti dengan logika cek sesi login (F-04, Hive KometSettingsKeys)
    // Contoh: bool isLoggedIn = sl<HiveService>().get(KometSettingsKeys.isLoggedIn);
    // if (isLoggedIn) context.go(KometRoutes.dashboardGuru / dashboardSiswa)
    // else context.go(KometRoutes.login)
    context.go(KometRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // TODO PIC C: Ganti dengan logo KOMET final
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.auto_stories, size: 52, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'KOMET',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Media Pembelajaran Kreativitas Digital',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
