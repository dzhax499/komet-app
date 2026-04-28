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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF1A3C0A),
              Color(0xFF758837),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const Spacer(flex: 3),
              
              // Logo & Title Stack (Overlapping for manual adjustment)
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    width: 280,
                    height: 280,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.auto_stories,
                      size: 280,
                      color: Colors.white,
                    ),
                  ),
                  
                  // Title (Positioned to overlap logo)
                  Positioned(
                    bottom: 10, // User can adjust this value to control overlap
                    child: Text(
                      'KOMET',
                      style: GoogleFonts.permanentMarker(
                        fontSize: 44,
                        color: Colors.white,
                        letterSpacing: 2,
                        // Added subtle shadow for better legibility when overlapping
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              
              const Spacer(flex: 2),
              
              // Button
              Center(
                child: SizedBox(
                  width: 220,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () => _markAsSeenAndNavigate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: GoogleFonts.nunito(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 18),
              
              // Subtitle (Moved below button)
              Text(
                'SPACE EXPLORATION & INNOVATION',
                style: GoogleFonts.nunito(
                  fontSize: 10,
                  color: Colors.white.withValues(alpha: 0.45),
                  letterSpacing: 2.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
              
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
