// lib/features/editor_engine/domain/entities/block_data.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Entitas BlockData sesuai spesifikasi dokumen pengajuan.
//
// ⚠️  PENTING: F-24 (Putar Musik Latar) dan F-25 (Efek Suara) DIHAPUS
//     sesuai constraint "No Audio" dari PIC D.
//     BlockType TIDAK memiliki: putarMusikLatar, tampilkanEfekSuara.

import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ENUMS
// ─────────────────────────────────────────────────────────────────────────────

/// Tipe spesifik setiap blok visual di editor cerita.
/// Sesuai dokumen pengajuan — TANPA F-24 dan F-25 (No Audio).
enum BlockType {
  // ── Kategori Konten ────────────────────────────────────────────
  /// F-21: Tambahkan narasi/dialog ke halaman
  tampilkanTeks,

  /// F-22: Pilih gambar latar dari koleksi bawaan
  tampilkanGambarLatar,

  /// F-23: Tambahkan karakter dengan ekspresi & posisi
  tampilkanKarakter,

  // ── Kategori Alur ──────────────────────────────────────────────
  /// F-26: Cerita berlanjut ke halaman tertentu secara linear
  pindahKeHalaman,

  /// F-27: Tambahkan tombol pilihan di akhir halaman (max 3)
  tambahkanPilihan,

  /// F-28: Hubungkan pilihan ke halaman tujuan (cabang cerita)
  hubungkanPilihanKeHalaman,

  /// F-29: Tandai halaman sebagai akhir cerita
  akhiriCerita,

  // ── Kategori Variabel ──────────────────────────────────────────
  /// F-30: Tambah nilai variabel karakter (contoh: Keberanian+1)
  tambahNilaiKarakter,

  /// F-31: Tampilkan konten hanya jika kondisi variabel terpenuhi
  tampilkanKontenBersyarat,
}

/// Kategori pengelompokan blok di panel editor (F-20).
enum BlockKategori {
  /// Blok yang menampilkan konten visual ke layar
  konten,

  /// Blok yang mengontrol alur & navigasi halaman
  alur,

  /// Blok yang mengelola variabel karakter & kondisi
  variabel,
}

// ─────────────────────────────────────────────────────────────────────────────
// ENTITY
// ─────────────────────────────────────────────────────────────────────────────

/// Node terkecil yang mewakili satu instruksi blok dalam satu halaman cerita.
/// Sesuai spesifikasi Entitas Editor Visual bagian B.3 dokumen pengajuan.
class BlockData extends Equatable {
  /// ID blok (UUID)
  final String id;

  /// Tipe spesifik blok
  final BlockType tipe;

  /// Kategori pengelompokan (konten/alur/variabel)
  final BlockKategori kategori;

  /// Parameter nilai spesifik per tipe blok.
  /// Contoh untuk tampilkanTeks:
  ///   {"teks": "Hari itu...", "ukuran": "sedang", "warna": "#fff", "posisi": "tengah"}
  /// Contoh untuk tampilkanKarakter:
  ///   {"karakter": "Ara", "ekspresi": "senang", "posisi": "kiri"}
  /// Contoh untuk tambahNilaiKarakter:
  ///   {"variabel": "Keberanian", "nilai": 1}
  /// Contoh untuk tampilkanKontenBersyarat:
  ///   {"kondisi": "Keberanian > 2"}
  final Map<String, dynamic> parameter;

  /// Blok anak — HANYA diisi jika tipe == tampilkanKontenBersyarat (F-31).
  /// Berisi blok konten yang ditampilkan saat kondisi terpenuhi.
  final List<BlockData>? children;

  /// Nomor urut eksekusi dalam satu halaman (menentukan rendering order F-35)
  final int urutan;

  const BlockData({
    required this.id,
    required this.tipe,
    required this.kategori,
    required this.parameter,
    required this.urutan,
    this.children,
  });

  /// Kategori default berdasarkan tipe blok.
  static BlockKategori kategoriOf(BlockType tipe) {
    switch (tipe) {
      case BlockType.tampilkanTeks:
      case BlockType.tampilkanGambarLatar:
      case BlockType.tampilkanKarakter:
        return BlockKategori.konten;
      case BlockType.pindahKeHalaman:
      case BlockType.tambahkanPilihan:
      case BlockType.hubungkanPilihanKeHalaman:
      case BlockType.akhiriCerita:
        return BlockKategori.alur;
      case BlockType.tambahNilaiKarakter:
      case BlockType.tampilkanKontenBersyarat:
        return BlockKategori.variabel;
    }
  }

  BlockData copyWith({
    String? id,
    BlockType? tipe,
    BlockKategori? kategori,
    Map<String, dynamic>? parameter,
    List<BlockData>? children,
    int? urutan,
  }) {
    return BlockData(
      id: id ?? this.id,
      tipe: tipe ?? this.tipe,
      kategori: kategori ?? this.kategori,
      parameter: parameter ?? this.parameter,
      children: children ?? this.children,
      urutan: urutan ?? this.urutan,
    );
  }

  @override
  List<Object?> get props => [id, tipe, kategori, parameter, children, urutan];
}
