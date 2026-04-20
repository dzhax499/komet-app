// lib/core/theme/app_colors.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Palet warna resmi KOMET. PIC C (ui_design) bisa merujuk file ini.
// Jangan gunakan warna literal di widget — selalu pakai token di sini.

import 'package:flutter/material.dart';

/// Sistem warna KOMET — dark mode dengan aksen biru-ungu untuk edukasi.
class AppColors {
  AppColors._();

  // ── Primary ───────────────────────────────────────────────────────────────
  /// Biru gelap — warna utama brand KOMET
  static const Color primary = Color(0xFF4A6CF7);

  /// Biru terang untuk hover/highlight
  static const Color primaryLight = Color(0xFF7C9BFA);

  /// Biru sangat gelap untuk pressed state
  static const Color primaryDark = Color(0xFF2D4BD4);

  // ── Secondary ─────────────────────────────────────────────────────────────
  /// Ungu sebagai aksen kreatif
  static const Color secondary = Color(0xFF9B6DFF);

  /// Ungu terang
  static const Color secondaryLight = Color(0xFFBE9BFF);

  // ── Surface / Background ──────────────────────────────────────────────────
  /// Background utama aplikasi (dark)
  static const Color background = Color(0xFF0F1117);

  /// Warna surface untuk card, dialog, panel blok
  static const Color surface = Color(0xFF1A1D2E);

  /// Warna surface elevated (layer kedua)
  static const Color surfaceVariant = Color(0xFF242740);

  /// Warna border/divider halus
  static const Color outline = Color(0xFF2E3257);

  // ── Canvas Editor ─────────────────────────────────────────────────────────
  /// Background area canvas editor
  static const Color canvasBackground = Color(0xFF12141F);

  /// Warna grid canvas (dot pattern)
  static const Color canvasGrid = Color(0xFF1C1F33);

  /// Warna highlight drop zone aktif
  static const Color dropZoneActive = Color(0x334A6CF7);

  /// Border drop zone aktif
  static const Color dropZoneBorder = Color(0xFF4A6CF7);

  // ── Block Categories ──────────────────────────────────────────────────────
  /// Warna blok Konten (teks, gambar, karakter)
  static const Color blockKonten = Color(0xFF4A6CF7);

  /// Warna blok Alur (pindah halaman, pilihan, ending)
  static const Color blockAlur = Color(0xFF00C896);

  /// Warna blok Variabel (karakter nilai, kondisi)
  static const Color blockVariabel = Color(0xFFFF8C42);

  // ── Semantic ──────────────────────────────────────────────────────────────
  /// Sukses / sinkronisasi berhasil (F-56)
  static const Color success = Color(0xFF00C896);

  /// Error / deadline terlewat (F-12)
  static const Color error = Color(0xFFFF4D6D);

  /// Warning / deadline dekat (F-59)
  static const Color warning = Color(0xFFFFB020);

  /// Info / menunggu
  static const Color info = Color(0xFF4A6CF7);

  // ── Status Submission (F-41) ──────────────────────────────────────────────
  static const Color statusDraft = Color(0xFF6B7280);
  static const Color statusSubmitted = Color(0xFFFFB020);
  static const Color statusReviewed = Color(0xFF00C896);
  static const Color statusNeedsRevision = Color(0xFFFF4D6D);

  // ── Status Sinkronisasi (F-56) ────────────────────────────────────────────
  static const Color syncOk = Color(0xFF00C896);
  static const Color syncPending = Color(0xFFFFB020);
  static const Color syncLoading = Color(0xFF4A6CF7);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF0F2FF);
  static const Color textSecondary = Color(0xFF9BA3C4);
  static const Color textDisabled = Color(0xFF4A5080);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
}
