// lib/core/theme/app_text_styles.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Typography system KOMET menggunakan Google Fonts (Nunito).
// Nunito dipilih karena rounded letterform — cocok untuk audiens pelajar SD-SMA.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Heading ───────────────────────────────────────────────────────────────
  static TextStyle get h1 => GoogleFonts.nunito(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
      );

  static TextStyle get h2 => GoogleFonts.nunito(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
      );

  static TextStyle get h3 => GoogleFonts.nunito(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      );

  // ── Body ──────────────────────────────────────────────────────────────────
  static TextStyle get bodyLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  static TextStyle get bodyMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.5,
      );

  static TextStyle get bodySmall => GoogleFonts.nunito(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
        height: 1.4,
      );

  // ── Label / Button ────────────────────────────────────────────────────────
  static TextStyle get labelLarge => GoogleFonts.nunito(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppColors.textOnPrimary,
        letterSpacing: 0.2,
      );

  static TextStyle get labelMedium => GoogleFonts.nunito(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  static TextStyle get labelSmall => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
        letterSpacing: 0.5,
      );

  // ── Caption / Helper ──────────────────────────────────────────────────────
  static TextStyle get caption => GoogleFonts.nunito(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondary,
      );

  // ── Editor Khusus ─────────────────────────────────────────────────────────
  /// Label nama blok di canvas editor
  static TextStyle get blockLabel => GoogleFonts.nunito(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      );

  /// Konten teks dalam cerita (mode baca F-35)
  static TextStyle get storyText => GoogleFonts.nunito(
        fontSize: 17,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.8,
      );

  /// Label tombol pilihan di mode baca (F-36)
  static TextStyle get choiceButton => GoogleFonts.nunito(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textOnPrimary,
      );

  // ── Code/Kode Kelas ───────────────────────────────────────────────────────
  static TextStyle get kodeKelas => GoogleFonts.sourceCodePro(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
        letterSpacing: 6,
      );
}
