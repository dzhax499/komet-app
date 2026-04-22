// lib/features/editor_engine/domain/entities/story_project_data.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Entitas root proyek cerita interaktif. Sesuai dokumen pengajuan Entitas B.1.
// Hierarki: StoryProjectData → PageModel → BlockData

import 'package:equatable/equatable.dart';
import 'page_model.dart';

/// Bungkus luar dari satu proyek cerita interaktif milik siswa.
/// Seluruh data ini di-serialize ke JSON dan disimpan di SubmissionModel.storyDataJson.
class StoryProjectData extends Equatable {
  /// ID proyek cerita (UUID)
  final String id;

  /// ID tugas yang menjadi konteks pembuatan cerita (F-18)
  final String assignmentId;

  /// Judul cerita yang ditulis siswa
  final String judulCerita;

  /// Nama siswa penulis — ditampilkan di layar penutup (F-38)
  final String namaPenulis;

  /// ID PageModel yang menjadi titik awal cerita (F-18: otomatis dibuat)
  final String halamanPembuka;

  /// Daftar seluruh halaman dalam proyek cerita ini
  final List<PageModel> pages;

  /// Penyimpanan nilai variabel karakter (F-30, F-31).
  /// Contoh: {"Keberanian": 2, "Kebaikan": 1}
  /// Nilai ini akan berubah selama pembaca membuat pilihan di mode baca.
  final Map<String, int> variabelKarakter;

  /// Waktu proyek pertama kali dibuat
  final DateTime createdAt;

  /// Waktu terakhir proyek dimodifikasi — sinkron dengan SubmissionModel.updatedAt (F-55)
  final DateTime updatedAt;

  const StoryProjectData({
    required this.id,
    required this.assignmentId,
    required this.judulCerita,
    required this.namaPenulis,
    required this.halamanPembuka,
    required this.pages,
    required this.variabelKarakter,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Total halaman dalam cerita
  int get totalHalaman => pages.length;

  /// Halaman pembuka (titik awal cerita)
  PageModel? get firstPage {
    try {
      return pages.firstWhere((p) => p.id == halamanPembuka);
    } catch (_) {
      return pages.isNotEmpty ? pages.first : null;
    }
  }

  /// Semua halaman ending dalam cerita
  List<PageModel> get endingPages =>
      pages.where((p) => p.isEnding).toList();

  /// Semua halaman yang terisolasi (F-32: Story Map — warning ke siswa)
  List<PageModel> get isolatedPages =>
      pages.where((p) => p.isIsolated).toList();

  /// Cari halaman berdasarkan ID
  PageModel? pageById(String pageId) {
    try {
      return pages.firstWhere((p) => p.id == pageId);
    } catch (_) {
      return null;
    }
  }

  /// Cerita dianggap valid jika: ada halaman pembuka, setidaknya 1 ending,
  /// tidak ada halaman terisolasi, dan semua koneksi valid.
  bool get isValid {
    if (firstPage == null) return false;
    if (endingPages.isEmpty) return false;
    if (isolatedPages.isNotEmpty) return false;
    // Validasi koneksi: semua pageId di connections harus ada di pages
    final pageIds = pages.map((p) => p.id).toSet();
    for (final page in pages) {
      if (page.nextPageId != null && !pageIds.contains(page.nextPageId)) {
        return false;
      }
      for (final targetId in page.connections.values) {
        if (!pageIds.contains(targetId)) return false;
      }
    }
    return true;
  }

  StoryProjectData copyWith({
    String? id,
    String? assignmentId,
    String? judulCerita,
    String? namaPenulis,
    String? halamanPembuka,
    List<PageModel>? pages,
    Map<String, int>? variabelKarakter,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StoryProjectData(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      judulCerita: judulCerita ?? this.judulCerita,
      namaPenulis: namaPenulis ?? this.namaPenulis,
      halamanPembuka: halamanPembuka ?? this.halamanPembuka,
      pages: pages ?? this.pages,
      variabelKarakter: variabelKarakter ?? this.variabelKarakter,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        assignmentId,
        judulCerita,
        namaPenulis,
        halamanPembuka,
        pages,
        variabelKarakter,
        createdAt,
        updatedAt,
      ];
}
