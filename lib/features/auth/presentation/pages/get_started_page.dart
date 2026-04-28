// lib/features/auth/presentation/pages/get_started_page.dart
//
// Get Started Page (First-Time User Only)
//
// Purpose:
//   - Introduced on app first launch
//   - Never shown again (checked via SharedPrefs)
//   - Leads to Login page
//
// Design Reference:
//   komet_auth_screens.html (splash/get-started section)
//
// Dependencies:
//   - SharedPreferences (to mark as seen)
//   - GoRouter (for navigation)
//
// Created: 2024-04-22

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';

class GetStartedPage extends StatelessWidget {
  const GetStartedPage({super.key});

  Future<void> _markAsSeenAndNavigate(BuildContext context) async {
    // Mark that user has seen Get Started
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_get_started', true);

    // Navigate to login
    if (context.mounted) {
      context.go(KometRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
            ],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(),
              
              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 150,
              ),
              const SizedBox(height: 6),
              
              // Subtitle
              Text(
                'SPACE EXPLORATION & INNOVATION',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 64),
              
              // Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _markAsSeenAndNavigate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primaryDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.outfit(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 18),
              
              // Small text
              Text(
                'Start your learning journey today',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.35),
                  letterSpacing: 0.5,
                ),
              ),
              
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}