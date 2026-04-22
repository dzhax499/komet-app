// lib/core/theme/app_colors.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Palet warna resmi KOMET (Green-Mint Theme).
// Jangan gunakan warna literal di widget — selalu pakai token di sini.

import 'package:flutter/material.dart';

/// Sistem warna KOMET — Tema Hijau Alam & Kreativitas Digital.
class AppColors {
  AppColors._();

  // ── Brand Colors (Green Palette) ──────────────────────────────────────────
  /// Hijau Gelap — Primary Dark
  static const Color primaryDark = Color(0xFF1A3D1F);

  /// Hijau Medium — Primary
  static const Color primary = Color(0xFF2D5A34);

  /// Hijau Terang — Primary Light
  static const Color primaryLight = Color(0xFF3D7A45);

  /// Mint Green — Secondary / Card Background
  static const Color secondary = Color(0xFFCCE4DE);
  static const Color secondaryLight = Color(0xFFD4E8E0);

  // ── Surface / Background ──────────────────────────────────────────────────
  /// Background utama aplikasi (Light Greenish Gray)
  static const Color background = Color(0xFFEEF2EE);

  /// Warna surface untuk card, dialog
  static const Color surface = Colors.white;

  /// Warna border/divider halus
  static const Color outline = Color(0xFFC8DAC8);

  // ── Canvas Editor ─────────────────────────────────────────────────────────
  static const Color canvasBackground = Color(0xFFF5F8F5);
  static const Color canvasGrid = Color(0xFFE8F0E8);

  // ── Block Categories ──────────────────────────────────────────────────────
  static const Color blockKonten = Color(0xFF2D5A34);
  static const Color blockAlur = Color(0xFF3D7A45);
  static const Color blockVariabel = Color(0xFF7A9A7E);

  // ── Semantic ──────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF2D5A34);
  static const Color error = Color(0xFFCC3333);
  static const Color warning = Color(0xFFF5C842);
  static const Color info = Color(0xFF3D7A45);

  // ── Text ──────────────────────────────────────────────────────────────────
  /// Text Dark Greenish
  static const Color textPrimary = Color(0xFF1A2E1C);
  static const Color textSecondary = Color(0xFF5A7A5E);
  static const Color textDisabled = Color(0xFF8AAA8E);
  static const Color textOnPrimary = Colors.white;
}
