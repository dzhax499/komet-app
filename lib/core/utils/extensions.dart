// lib/core/utils/extensions.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Dart extension methods untuk utility yang sering digunakan.

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Extension tambahan untuk tipe String.
extension KometStringExtension on String {
  /// Menghasilkan UUID v4 (wrapper convenience).
  static String generateUuid() => _uuid.v4();

  /// Memastikan string tidak kosong dan tidak hanya spasi.
  bool get isNotBlank => trim().isNotEmpty;

  /// Kapitalisasi huruf pertama setiap kata.
  String toTitleCase() {
    if (isEmpty) return this;
    return split(' ')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
            : '')
        .join(' ');
  }
}

/// Extension tambahan untuk tipe DateTime.
extension KometDateTimeExtension on DateTime {
  /// Format tanggal ke string Indonesia: "14 April 2026"
  String toIndonesianDate() {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '$day ${bulan[month]} $year';
  }

  /// Format tanggal + waktu: "14 Apr 2026, 10:30"
  String toIndonesianDateTime() {
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    final jam = hour.toString().padLeft(2, '0');
    final menit = minute.toString().padLeft(2, '0');
    return '$day ${bulan[month]} $year, $jam:$menit';
  }

  /// Cek apakah deadline sudah lewat (F-12: indikator warna assignment).
  bool get isDeadlinePassed => isBefore(DateTime.now());

  /// Sisa hari hingga deadline (negatif jika sudah lewat).
  int get daysUntilDeadline => difference(DateTime.now()).inDays;

  /// true jika deadline tinggal ≤ 1 hari (F-59: notifikasi pengingat).
  bool get isDeadlineNearBy => !isDeadlinePassed && daysUntilDeadline <= 1;
}

/// Extension untuk nullable DateTime.
extension KometNullableDateTimeExtension on DateTime? {
  /// Kembalikan string "-" jika null, atau format Indonesia jika ada.
  String toDisplayString() {
    if (this == null) return '-';
    return this!.toIndonesianDate();
  }
}

/// Extension untuk BuildContext — akses Theme dan MediaQuery lebih ringkas.
extension KometContextExtension on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isTablet => screenWidth >= 600;
}
