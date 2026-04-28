// lib/features/auth/presentation/pages/splash_page.dart
//
// Splash Screen dengan Get Started Flow
//
// Purpose:
//   1. Display app logo dan loading indicator
//   2. Check authentication status
//   3. On first launch: show Get Started screen
//   4. On subsequent launches: go directly to login/dashboard
//
// Design Reference:
//   komet_auth_screens.html (splash & get-started sections)
//
// Dependencies:
//   - AuthBloc (for checking auth status)
//   - GetIt/service_locator (for accessing prefs)
//
// Created: 2024-04-22

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    // Wait untuk splash animation
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Check if user has seen Get Started before
    final prefs = await SharedPreferences.getInstance();
    final hasSeenGetStarted = prefs.getBool('has_seen_get_started') ?? false;

    if (!hasSeenGetStarted) {
      // First time user - show Get Started
      if (mounted) {
        context.go(KometRoutes.getStarted);
      }
    } else {
      // Returning user - check auth status
      final authState = context.read<AuthBloc>().state;
      if (mounted) {
        if (authState is AuthAuthenticated) {
          // User already logged in
          if (authState.user.role == 'guru') {
            context.go(KometRoutes.dashboardGuru);
          } else {
            context.go(KometRoutes.dashboardSiswa);
          }
        } else {
          // User not logged in - go to login
          context.go(KometRoutes.login);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A3C0A),
              Color(0xFF758837),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Center Logo & Title
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo (SVG representation in Icon)
                  Container(
                    width: 180,
                    height: 180,
                    margin: const EdgeInsets.only(bottom: 18),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.auto_stories,
                        size: 180,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Text(
                    'KOMET',
                    style: GoogleFonts.permanentMarker(
                      fontSize: 40,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'SPACE EXPLORATION & INNOVATION',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.45),
                      letterSpacing: 2.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Loader
            Positioned(
              bottom: 48,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 3,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.transparent,
                        valueColor: const AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'loading...',
                    style: GoogleFonts.nunito(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.3),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
