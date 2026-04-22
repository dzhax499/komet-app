// lib/features/editor_engine/domain/entities/page_model.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Entitas PageModel sesuai dokumen pengajuan Entitas B.2.

import 'package:equatable/equatable.dart';
import 'block_data.dart';

/// Tipe halaman cerita.
enum PageTipe {
  /// Halaman pertama — otomatis dibuat saat project baru (F-18)
  pembuka,

  /// Halaman biasa di tengah cerita
  normal,

  /// Halaman akhir — ditandai oleh blok akhiriCerita (F-29)
  ending,
}

/// Merepresentasikan satu halaman dalam proyek cerita interaktif.
/// Berisi daftar blok visual dan informasi koneksi ke halaman lain.
class PageModel extends Equatable {
  /// ID halaman (UUID)
  final String id;

  /// Label halaman di panel navigasi thumbnail (F-19)
  final String judul;

  /// Tipe halaman: pembuka / normal / ending
  final PageTipe tipe;

  /// Daftar blok visual yang disusun siswa, sesuai urutan eksekusi
  final List<BlockData> blocks;

  /// Peta koneksi pilihan ke halaman tujuan (F-28).
  /// Key: label pilihan (dari blok tambahkanPilihan, F-27)
  /// Value: pageId halaman tujuan
  /// Kosong jika halaman menggunakan pindahKeHalaman atau akhiriCerita.
  final Map<String, String> connections;

  /// ID halaman berikutnya untuk alur linear tanpa percabangan (F-26).
  /// null jika halaman menggunakan pilihan atau merupakan ending.
  final String? nextPageId;

  /// Data gambar thumbnail halaman (base64) untuk pratampil di panel (F-19).
  final String? thumbnailData;

  const PageModel({
    required this.id,
    required this.judul,
    required this.tipe,
    required this.blocks,
    required this.connections,
    this.nextPageId,
    this.thumbnailData,
  });

  /// true jika halaman ini adalah halaman akhir cerita (F-29)
  bool get isEnding => tipe == PageTipe.ending;

  /// true jika halaman menggunakan alur percabangan (pilihan)
  bool get hasPilihan => connections.isNotEmpty;

  /// true jika halaman memiliki alur linear ke halaman berikutnya
  bool get hasNextPage => nextPageId != null;

  /// true jika halaman terisolasi — tidak ada koneksi ke manapun (F-32: Story Map)
  bool get isIsolated => !isEnding && !hasPilihan && !hasNextPage;

  /// Blok diurutkan berdasarkan field [urutan]
  List<BlockData> get sortedBlocks =>
      [...blocks]..sort((a, b) => a.urutan.compareTo(b.urutan));

  PageModel copyWith({
    String? id,
    String? judul,
    PageTipe? tipe,
    List<BlockData>? blocks,
    Map<String, String>? connections,
    String? nextPageId,
    String? thumbnailData,
  }) {
    return PageModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      tipe: tipe ?? this.tipe,
      blocks: blocks ?? this.blocks,
      connections: connections ?? this.connections,
      nextPageId: nextPageId ?? this.nextPageId,
      thumbnailData: thumbnailData ?? this.thumbnailData,
    );
  }

  @override
  List<Object?> get props =>
      [id, judul, tipe, blocks, connections, nextPageId, thumbnailData];
}
