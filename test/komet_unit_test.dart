// ============================================================
// KOMET — Unit Test Script
// Proyek 4, D3 Teknik Informatika, Politeknik Negeri Bandung 2026
// Kelompok C2 — PIC D: Dzakir Tsabit Asy Syafiq (241511071)
//
// Jalankan dengan: flutter test
// Target: All 33 tests passed
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:KOMET/core/error/failures.dart';
import 'package:KOMET/core/utils/extensions.dart';
import 'package:KOMET/features/editor_engine/domain/entities/block_data.dart';
import 'package:KOMET/features/editor_engine/domain/entities/page_model.dart';
import 'package:KOMET/features/editor_engine/domain/entities/story_project_data.dart';

// ─────────────────────────────────────────────────────────────
// HELPER: factory minimal untuk unit test (tanpa Hive/MongoDB)
// ─────────────────────────────────────────────────────────────

BlockData _makeBlock(String id, BlockType tipe, {int urutan = 0}) {
  return BlockData(
    id: id,
    tipe: tipe,
    kategori: BlockData.kategoriOf(tipe),
    parameter: const {},
    urutan: urutan,
  );
}

PageModel _makePage(
  String id, {
  String judul = 'Halaman',
  PageTipe tipe = PageTipe.normal,
  List<BlockData> blocks = const [],
  Map<String, String> connections = const {},
  String? nextPageId,
}) {
  return PageModel(
    id: id,
    judul: judul,
    tipe: tipe,
    blocks: blocks,
    connections: connections,
    nextPageId: nextPageId,
  );
}

StoryProjectData _makeProject({
  required String pembuka,
  required List<PageModel> pages,
  Map<String, int> variabel = const {},
}) {
  final now = DateTime(2026, 6, 1);
  return StoryProjectData(
    id: 'proj-test',
    assignmentId: 'assign-001',
    judulCerita: 'Cerita Test',
    namaPenulis: 'Siswa Test',
    halamanPembuka: pembuka,
    pages: pages,
    variabelKarakter: variabel,
    createdAt: now,
    updatedAt: now,
  );
}

// ─────────────────────────────────────────────────────────────
void main() {
  // ═══════════════════════════════════════════════════════════
  // GROUP 1 — BlockData: kategoriOf() mapping (6 tests)
  // Sumber: lib/features/editor_engine/domain/entities/block_data.dart
  // ═══════════════════════════════════════════════════════════
  group('TC-01..06 | BlockData.kategoriOf()', () {
    test('TC-01: tampilkanTeks → kategori konten', () {
      expect(
        BlockData.kategoriOf(BlockType.tampilkanTeks),
        BlockKategori.konten,
      );
    });

    test('TC-02: tampilkanGambarLatar → kategori konten', () {
      expect(
        BlockData.kategoriOf(BlockType.tampilkanGambarLatar),
        BlockKategori.konten,
      );
    });

    test('TC-03: tampilkanKarakter → kategori konten', () {
      expect(
        BlockData.kategoriOf(BlockType.tampilkanKarakter),
        BlockKategori.konten,
      );
    });

    test('TC-04: pindahKeHalaman → kategori alur', () {
      expect(
        BlockData.kategoriOf(BlockType.pindahKeHalaman),
        BlockKategori.alur,
      );
    });

    test('TC-05: tambahNilaiKarakter → kategori variabel', () {
      expect(
        BlockData.kategoriOf(BlockType.tambahNilaiKarakter),
        BlockKategori.variabel,
      );
    });

    test('TC-06: tampilkanKontenBersyarat → kategori variabel', () {
      expect(
        BlockData.kategoriOf(BlockType.tampilkanKontenBersyarat),
        BlockKategori.variabel,
      );
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 2 — PageModel: derived properties (6 tests)
  // Sumber: lib/features/editor_engine/domain/entities/page_model.dart
  // ═══════════════════════════════════════════════════════════
  group('TC-07..12 | PageModel derived properties', () {
    test('TC-07: isEnding = true untuk PageTipe.ending', () {
      final page = _makePage('p1', tipe: PageTipe.ending);
      expect(page.isEnding, isTrue);
    });

    test('TC-08: isEnding = false untuk PageTipe.normal', () {
      final page = _makePage('p1', tipe: PageTipe.normal);
      expect(page.isEnding, isFalse);
    });

    test('TC-09: hasPilihan = true jika connections tidak kosong', () {
      final page = _makePage('p1', connections: {'Pilihan A': 'p2'});
      expect(page.hasPilihan, isTrue);
    });

    test('TC-10: hasNextPage = true jika nextPageId diisi', () {
      final page = _makePage('p1', nextPageId: 'p2');
      expect(page.hasNextPage, isTrue);
    });

    test('TC-11: isIsolated = true jika tidak ada koneksi, bukan ending', () {
      final page = _makePage('p1', tipe: PageTipe.normal);
      expect(page.isIsolated, isTrue);
    });

    test('TC-12: isIsolated = false jika ada nextPageId', () {
      final page = _makePage('p1', nextPageId: 'p2');
      expect(page.isIsolated, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 3 — PageModel: sortedBlocks (2 tests)
  // Sumber: lib/features/editor_engine/domain/entities/page_model.dart
  // ═══════════════════════════════════════════════════════════
  group('TC-13..14 | PageModel.sortedBlocks', () {
    test('TC-13: blok diurutkan berdasarkan field urutan ascending', () {
      final b1 = _makeBlock('b1', BlockType.tampilkanTeks, urutan: 2);
      final b2 = _makeBlock('b2', BlockType.tampilkanKarakter, urutan: 0);
      final b3 = _makeBlock('b3', BlockType.tampilkanGambarLatar, urutan: 1);
      final page = _makePage('p1', blocks: [b1, b2, b3]);
      expect(page.sortedBlocks.map((b) => b.id).toList(), ['b2', 'b3', 'b1']);
    });

    test('TC-14: sortedBlocks tidak mengubah list asli', () {
      final b1 = _makeBlock('b1', BlockType.tampilkanTeks, urutan: 5);
      final b2 = _makeBlock('b2', BlockType.akhiriCerita, urutan: 1);
      final page = _makePage('p1', blocks: [b1, b2]);
      final sorted = page.sortedBlocks;
      expect(sorted.first.id, 'b2');
      expect(page.blocks.first.id, 'b1'); // list asli tidak berubah
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 4 — StoryProjectData.isValid (7 tests)
  // Sumber: lib/features/editor_engine/domain/entities/story_project_data.dart
  // ═══════════════════════════════════════════════════════════
  group('TC-15..21 | StoryProjectData.isValid', () {
    test('TC-15: valid — ada pembuka, ada ending, koneksi benar', () {
      final p1 = _makePage('p1', tipe: PageTipe.pembuka, nextPageId: 'p2');
      final p2 = _makePage('p2', tipe: PageTipe.ending);
      final project = _makeProject(pembuka: 'p1', pages: [p1, p2]);
      expect(project.isValid, isTrue);
    });

    test('TC-16: tidak valid — tidak ada ending page', () {
      final p1 = _makePage('p1', tipe: PageTipe.pembuka, nextPageId: 'p2');
      final p2 = _makePage('p2', tipe: PageTipe.normal, nextPageId: null);
      final project = _makeProject(pembuka: 'p1', pages: [p1, p2]);
      expect(project.isValid, isFalse);
    });

    test('TC-17: tidak valid — ada halaman terisolasi', () {
      final p1 = _makePage('p1', tipe: PageTipe.pembuka, nextPageId: 'p3');
      final p2 = _makePage('p2', tipe: PageTipe.normal); // isolated
      final p3 = _makePage('p3', tipe: PageTipe.ending);
      final project = _makeProject(pembuka: 'p1', pages: [p1, p2, p3]);
      expect(project.isValid, isFalse);
    });

    test('TC-18: tidak valid — firstPage null (pembuka tidak ada di pages)', () {
      final p2 = _makePage('p2', tipe: PageTipe.ending);
      final project = _makeProject(pembuka: 'p-nonexist', pages: [p2]);
      expect(project.isValid, isFalse);
    });

    test('TC-19: tidak valid — nextPageId merujuk pageId yang tidak ada', () {
      final p1 = _makePage('p1', tipe: PageTipe.pembuka, nextPageId: 'pGhost');
      final p2 = _makePage('p2', tipe: PageTipe.ending);
      final project = _makeProject(pembuka: 'p1', pages: [p1, p2]);
      expect(project.isValid, isFalse);
    });

    test('TC-20: tidak valid — connections merujuk pageId yang tidak ada', () {
      final p1 = _makePage(
        'p1',
        tipe: PageTipe.pembuka,
        connections: {'Pilih A': 'pGhost'},
      );
      final p2 = _makePage('p2', tipe: PageTipe.ending);
      final project = _makeProject(pembuka: 'p1', pages: [p1, p2]);
      expect(project.isValid, isFalse);
    });

    test('TC-21: valid — percabangan pilihan dengan semua target ada', () {
      final p1 = _makePage(
        'p1',
        tipe: PageTipe.pembuka,
        connections: {'Pilih A': 'p2', 'Pilih B': 'p3'},
      );
      final p2 = _makePage('p2', tipe: PageTipe.ending);
      final p3 = _makePage('p3', tipe: PageTipe.ending);
      final project = _makeProject(pembuka: 'p1', pages: [p1, p2, p3]);
      expect(project.isValid, isTrue);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 5 — StoryProjectData: helper methods (4 tests)
  // Sumber: lib/features/editor_engine/domain/entities/story_project_data.dart
  // ═══════════════════════════════════════════════════════════
  group('TC-22..25 | StoryProjectData helper methods', () {
    test('TC-22: pageById mengembalikan page yang benar', () {
      final p1 = _makePage('p1', tipe: PageTipe.pembuka);
      final p2 = _makePage('p2', tipe: PageTipe.ending);
      final project = _makeProject(pembuka: 'p1', pages: [p1, p2]);
      expect(project.pageById('p2')?.id, 'p2');
    });

    test('TC-23: pageById mengembalikan null jika tidak ditemukan', () {
      final p1 = _makePage('p1', tipe: PageTipe.pembuka);
      final project = _makeProject(pembuka: 'p1', pages: [p1]);
      expect(project.pageById('ghost'), isNull);
    });

    test('TC-24: endingPages hanya berisi halaman tipe ending', () {
      final p1 = _makePage('p1', tipe: PageTipe.pembuka);
      final p2 = _makePage('p2', tipe: PageTipe.ending);
      final p3 = _makePage('p3', tipe: PageTipe.normal, nextPageId: 'p2');
      final project = _makeProject(pembuka: 'p1', pages: [p1, p2, p3]);
      expect(project.endingPages.length, 1);
      expect(project.endingPages.first.id, 'p2');
    });

    test('TC-25: totalHalaman mengembalikan jumlah semua halaman', () {
      final pages = List.generate(
        5,
        (i) => _makePage('p$i', tipe: i == 4 ? PageTipe.ending : PageTipe.normal),
      );
      final project = _makeProject(pembuka: 'p0', pages: pages);
      expect(project.totalHalaman, 5);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 6 — KometDateTimeExtension (5 tests)
  // Sumber: lib/core/utils/extensions.dart
  // ═══════════════════════════════════════════════════════════
  group('TC-26..30 | KometDateTimeExtension', () {
    test('TC-26: isDeadlinePassed = true untuk tanggal di masa lalu', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(past.isDeadlinePassed, isTrue);
    });

    test('TC-27: isDeadlinePassed = false untuk tanggal di masa depan', () {
      final future = DateTime.now().add(const Duration(days: 10));
      expect(future.isDeadlinePassed, isFalse);
    });

    test('TC-28: isDeadlineNearBy = true jika deadline ≤ 1 hari lagi', () {
      final nearDeadline = DateTime.now().add(const Duration(hours: 12));
      expect(nearDeadline.isDeadlineNearBy, isTrue);
    });

    test('TC-29: isDeadlineNearBy = false jika deadline masih > 1 hari', () {
      final farDeadline = DateTime.now().add(const Duration(days: 5));
      expect(farDeadline.isDeadlineNearBy, isFalse);
    });

    test('TC-30: isDeadlineNearBy = false jika deadline sudah lewat', () {
      final past = DateTime.now().subtract(const Duration(days: 1));
      expect(past.isDeadlineNearBy, isFalse);
    });
  });

  // ═══════════════════════════════════════════════════════════
  // GROUP 7 — KometStringExtension (3 tests)
  // Sumber: lib/core/utils/extensions.dart
  // ═══════════════════════════════════════════════════════════
  group('TC-31..33 | KometStringExtension', () {
    test('TC-31: isNotBlank = false untuk string kosong ""', () {
      expect(''.isNotBlank, isFalse);
    });

    test('TC-32: isNotBlank = false untuk string berisi spasi saja', () {
      expect('   '.isNotBlank, isFalse);
    });

    test('TC-33: isNotBlank = true untuk string yang berisi konten', () {
      expect('KOMET'.isNotBlank, isTrue);
    });
  });
}
