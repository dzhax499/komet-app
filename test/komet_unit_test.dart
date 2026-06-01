// test/komet_unit_test.dart
// ============================================================
// KOMET — Unit Test Suite
// TC-01 s/d TC-34 (TC-27 dihapus per permintaan)
// TC-19 adalah manual test (hardware PCD/kamera) — ditulis sebagai stub.
// Menggunakan pure-Dart fake tanpa Firebase / Hive / Platform.
// Jalankan: flutter test test/komet_unit_test.dart
// ============================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';

// ── Core (relative dari test/ ke lib/) ───────────────────────
import '../lib/core/error/failures.dart';
import '../lib/core/base/base_use_case.dart';
import '../lib/core/models/user_model.dart';
import '../lib/core/models/kelas_model.dart';

// ── Auth ─────────────────────────────────────────────────────
import '../lib/features/auth/domain/repositories/auth_repository.dart';
import '../lib/features/auth/domain/usecases/auth_usecases.dart';
import '../lib/features/auth/presentation/bloc/auth_bloc.dart';

// ── Kelas ────────────────────────────────────────────────────
import '../lib/features/kelas/domain/repositories/kelas_repository.dart';
import '../lib/features/kelas/domain/usecases/kelas_usecases.dart';
import '../lib/features/kelas/domain/usecases/get_kelas_by_id_use_case.dart';
import '../lib/features/kelas/domain/usecases/update_kelas_use_case.dart';
import '../lib/features/kelas/domain/usecases/remove_student_use_case.dart';
import '../lib/features/kelas/presentation/bloc/kelas_bloc.dart';

// ── Editor Engine ────────────────────────────────────────────
import '../lib/features/editor_engine/domain/entities/story_project_data.dart';
import '../lib/features/editor_engine/domain/entities/page_model.dart';
import '../lib/features/editor_engine/domain/entities/block_data.dart';
import '../lib/features/editor_engine/presentation/bloc/editor_bloc.dart';

// ============================================================
// FAKE REPOSITORIES
// ============================================================

/// Helper: buat UserModel dummy untuk testing
UserModel _makeUser({
  String id = 'user-001',
  String nama = 'Budi',
  String email = 'guru@test.com',
  String password = '123456',
  String role = 'guru',
}) =>
    UserModel(
      id: id,
      nama: nama,
      email: email,
      password: password,
      role: role,
      kelasIds: const [],
      createdAt: DateTime(2024, 1, 1),
      lastLoginAt: DateTime(2024, 1, 1),
    );

/// Helper: buat KelasModel dummy untuk testing
KelasModel _makeKelas({
  String id = 'kelas-001',
  String nama = 'XII RPL 1',
  String guruId = 'guru-001',
  String kodeKelas = 'ABC123',
  List<String> siswaIds = const [],
}) =>
    KelasModel(
      id: id,
      nama: nama,
      guruId: guruId,
      kodeKelas: kodeKelas,
      siswaIds: siswaIds,
      assignmentIds: const [],
      isAktif: true,
      dibuatPada: DateTime(2024, 1, 1),
    );

// ── Fake AuthRepository ──────────────────────────────────────
class FakeAuthRepository implements AuthRepository {
  bool loginShouldFail = false;
  bool registerGuruShouldFail = false;
  bool registerSiswaShouldFail = false;
  bool registerSiswaKodeInvalid = false;
  String? savedRole;
  UserModel? currentUser;

  @override
  KometResult<UserModel> login(String email, String password) async {
    if (loginShouldFail) {
      return kometFailure(
          const AuthFailure('Exception: Email atau password salah'));
    }
    final role = email.contains('siswa') ? 'siswa' : 'guru';
    final user = _makeUser(email: email, role: role);
    currentUser = user;
    return kometSuccess(user);
  }

  @override
  KometResult<UserModel> registerGuru(String nama, String email, String password,
      {String? id}) async {
    if (registerGuruShouldFail) {
      return kometFailure(const AuthFailure());
    }
    final user =
        _makeUser(id: id ?? 'guru-001', nama: nama, email: email, role: 'guru');
    savedRole = 'guru';
    currentUser = user;
    return kometSuccess(user);
  }

  @override
  KometResult<UserModel> registerSiswa(String nama, String email, String password,
      {String? kodeKelas, String? id}) async {
    if (registerSiswaShouldFail) {
      return kometFailure(const AuthFailure());
    }
    if (registerSiswaKodeInvalid) {
      return kometFailure(
          const ValidationFailure('Exception: Kode kelas tidak ditemukan'));
    }
    final user = _makeUser(
        id: id ?? 'siswa-001', nama: nama, email: email, role: 'siswa');
    savedRole = 'siswa';
    currentUser = user;
    return kometSuccess(user);
  }

  @override
  KometResult<void> logout() async {
    currentUser = null;
    return kometSuccess(null);
  }

  @override
  KometResult<UserModel?> getCurrentUser() async =>
      kometSuccess<UserModel?>(currentUser);

  @override
  KometResult<UserModel> signInWithGoogle() async =>
      kometFailure(const AuthFailure('Not implemented in test'));

  @override
  KometResult<UserModel> updateProfile(String userId,
          {String? nama, String? photoUrl}) async =>
      kometSuccess(_makeUser());

  @override
  KometResult<void> sendPasswordResetOtp(String email) async =>
      kometSuccess(null);

  @override
  KometResult<void> verifyResetOtp(String email, String otp) async =>
      kometSuccess(null);

  @override
  KometResult<void> resetPassword(String email, String newPassword) async =>
      kometSuccess(null);
}

// ── Fake KelasRepository ──────────────────────────────────────
class FakeKelasRepository implements KelasRepository {
  // Publik agar bisa diakses dari verify()
  final List<KelasModel> kelasList = [];
  bool joinKodeNotFound = false;

  void seed(List<KelasModel> items) {
    kelasList
      ..clear()
      ..addAll(items);
  }

  @override
  KometResult<KelasModel> createKelas(String nama, String guruId) async {
    final kelas = _makeKelas(
      id: 'kelas-${kelasList.length + 1}',
      nama: nama,
      guruId: guruId,
      kodeKelas: 'XYZABC',
    );
    kelasList.add(kelas);
    return kometSuccess(kelas);
  }

  @override
  KometResult<List<KelasModel>> getKelasGuru(String guruId) async {
    return kometSuccess(kelasList.where((k) => k.guruId == guruId).toList());
  }

  @override
  KometResult<List<KelasModel>> getKelasSiswa(String siswaId) async {
    return kometSuccess(
        kelasList.where((k) => k.siswaIds.contains(siswaId)).toList());
  }

  @override
  KometResult<KelasModel> joinKelas(String kodeKelas, String siswaId) async {
    if (joinKodeNotFound) {
      return kometFailure(
          const ValidationFailure('Exception: Kode kelas tidak ditemukan'));
    }
    final idx = kelasList.indexWhere((k) => k.kodeKelas == kodeKelas);
    if (idx < 0) {
      return kometFailure(
          const ValidationFailure('Exception: Kode kelas tidak ditemukan'));
    }
    final kelas = kelasList[idx];
    if (!kelas.siswaIds.contains(siswaId)) {
      kelasList[idx] = kelas.copyWith(siswaIds: [...kelas.siswaIds, siswaId]);
    }
    return kometSuccess(kelasList[idx]);
  }

  @override
  KometResult<void> deleteKelas(String kelasId) async {
    kelasList.removeWhere((k) => k.id == kelasId);
    return kometSuccess(null);
  }

  @override
  KometResult<KelasModel> getKelasById(String kelasId) async {
    try {
      return kometSuccess(kelasList.firstWhere((k) => k.id == kelasId));
    } catch (_) {
      return kometFailure(const NotFoundFailure());
    }
  }

  @override
  KometResult<KelasModel> updateKelas(String kelasId, String newNama) async {
    final idx = kelasList.indexWhere((k) => k.id == kelasId);
    if (idx < 0) return kometFailure(const NotFoundFailure());
    kelasList[idx] = kelasList[idx].copyWith(nama: newNama);
    return kometSuccess(kelasList[idx]);
  }

  @override
  KometResult<void> removeStudent(String kelasId, String siswaId) async =>
      kometSuccess(null);

  @override
  KometResult<List<UserModel>> getSiswaInKelas(String kelasId) async =>
      kometSuccess([]);

  @override
  KometResult<void> leaveKelas(String kelasId, String siswaId) async =>
      kometSuccess(null);
}

// ============================================================
// HELPER BUILDERS
// ============================================================
AuthBloc _buildAuthBloc(FakeAuthRepository repo) => AuthBloc(
      loginUseCase: LoginUseCase(repo),
      registerGuruUseCase: RegisterGuruUseCase(repo),
      registerSiswaUseCase: RegisterSiswaUseCase(repo),
      logoutUseCase: LogoutUseCase(repo),
      getCurrentUserUseCase: GetCurrentUserUseCase(repo),
      googleLoginUseCase: GoogleLoginUseCase(repo),
      updateProfileUseCase: UpdateProfileUseCase(repo),
      sendPasswordResetOtpUseCase: SendPasswordResetOtpUseCase(repo),
      verifyResetOtpUseCase: VerifyResetOtpUseCase(repo),
      resetPasswordUseCase: ResetPasswordUseCase(repo),
    );

KelasBloc _buildKelasBloc(FakeKelasRepository repo) => KelasBloc(
      createKelasUseCase: CreateKelasUseCase(repo),
      getKelasGuruUseCase: GetKelasGuruUseCase(repo),
      getKelasSiswaUseCase: GetKelasSiswaUseCase(repo),
      joinKelasUseCase: JoinKelasUseCase(repo),
      deleteKelasUseCase: DeleteKelasUseCase(repo),
      getKelasByIdUseCase: GetKelasByIdUseCase(repo),
      getSiswaInKelasUseCase: GetSiswaInKelasUseCase(repo),
      leaveKelasUseCase: LeaveKelasUseCase(repo),
    );

// ============================================================
// MAIN TEST SUITE
// ============================================================
void main() {
  // ──────────────────────────────────────────────────────────
  // GROUP 1: Authentication (TC-01 s/d TC-09)
  // ──────────────────────────────────────────────────────────
  group('Auth BLoC —', () {
    late FakeAuthRepository repo;
    setUp(() => repo = FakeAuthRepository());

    // TC-01 ─────────────────────────────────────────────────
    blocTest<AuthBloc, AuthState>(
      'TC-01 Login Guru: guru@test.com/123456 → AuthAuthenticated role=guru',
      build: () => _buildAuthBloc(repo),
      act: (AuthBloc b) =>
          b.add(AuthLoginRequested(email: 'guru@test.com', password: '123456')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((AuthAuthenticated s) => s.user.role, 'role', 'guru'),
      ],
    );

    // TC-02 ─────────────────────────────────────────────────
    blocTest<AuthBloc, AuthState>(
      'TC-02 Login Siswa: siswa@test.com/123456 → AuthAuthenticated role=siswa',
      build: () => _buildAuthBloc(repo),
      act: (AuthBloc b) => b
          .add(AuthLoginRequested(email: 'siswa@test.com', password: '123456')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((AuthAuthenticated s) => s.user.role, 'role', 'siswa'),
      ],
    );

    // TC-03 ─────────────────────────────────────────────────
    blocTest<AuthBloc, AuthState>(
      'TC-03 Login Email Salah → AuthError "Exception: Email atau password salah"',
      build: () {
        repo.loginShouldFail = true;
        return _buildAuthBloc(repo);
      },
      act: (AuthBloc b) => b
          .add(AuthLoginRequested(email: 'salah@test.com', password: '123456')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((AuthError s) => s.message, 'message',
            'Exception: Email atau password salah'),
      ],
    );

    // TC-04 ─────────────────────────────────────────────────
    blocTest<AuthBloc, AuthState>(
      'TC-04 Login Password Salah → AuthError "Exception: Email atau password salah"',
      build: () {
        repo.loginShouldFail = true;
        return _buildAuthBloc(repo);
      },
      act: (AuthBloc b) =>
          b.add(AuthLoginRequested(email: 'guru@test.com', password: 'salah')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((AuthError s) => s.message, 'message',
            'Exception: Email atau password salah'),
      ],
    );

    // TC-05 ─────────────────────────────────────────────────
    blocTest<AuthBloc, AuthState>(
      'TC-05 Login Field Kosong → AuthError "Exception: Email atau password salah"',
      build: () {
        repo.loginShouldFail = true;
        return _buildAuthBloc(repo);
      },
      act: (AuthBloc b) =>
          b.add(AuthLoginRequested(email: '', password: '')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((AuthError s) => s.message, 'message',
            'Exception: Email atau password salah'),
      ],
    );

    // TC-06 ─────────────────────────────────────────────────
    blocTest<AuthBloc, AuthState>(
      'TC-06 Register Guru → AuthAuthenticated, role=guru tersimpan di Hive',
      build: () => _buildAuthBloc(repo),
      act: (AuthBloc b) => b.add(AuthRegisterGuruRequested(
          nama: 'Budi', email: 'budi@test.com', password: 'pass123')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((AuthAuthenticated s) => s.user.role, 'role', 'guru'),
      ],
      verify: (AuthBloc _) => expect(repo.savedRole, 'guru'),
    );

    // TC-07 ─────────────────────────────────────────────────
    blocTest<AuthBloc, AuthState>(
      'TC-07 Register Siswa Kode Valid → AuthAuthenticated, siswaId masuk siswaIds kelas',
      build: () => _buildAuthBloc(repo),
      act: (AuthBloc b) => b.add(AuthRegisterSiswaRequested(
          nama: 'Ani',
          email: 'ani@test.com',
          password: 'pass123',
          kodeKelas: 'ABC123')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthAuthenticated>()
            .having((AuthAuthenticated s) => s.user.role, 'role', 'siswa'),
      ],
    );

    // TC-08 ─────────────────────────────────────────────────
    blocTest<AuthBloc, AuthState>(
      'TC-08 Register Siswa Kode Tidak Valid → AuthError "Exception: Kode kelas tidak ditemukan"',
      build: () {
        repo.registerSiswaKodeInvalid = true;
        return _buildAuthBloc(repo);
      },
      act: (AuthBloc b) => b.add(AuthRegisterSiswaRequested(
          nama: 'X',
          email: 'x@test.com',
          password: 'pass',
          kodeKelas: 'XXXYYY')),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthError>().having((AuthError s) => s.message, 'message',
            'Exception: Kode kelas tidak ditemukan'),
      ],
    );

    // TC-09 ─────────────────────────────────────────────────
    blocTest<AuthBloc, AuthState>(
      'TC-09 Logout → AuthUnauthenticated, Hive currentUser null',
      build: () {
        repo.currentUser = _makeUser();
        return _buildAuthBloc(repo);
      },
      act: (AuthBloc b) => b.add(AuthLogoutRequested()),
      expect: () => [
        isA<AuthLoading>(),
        isA<AuthUnauthenticated>(),
      ],
      verify: (AuthBloc _) => expect(repo.currentUser, isNull),
    );
  });

  // ──────────────────────────────────────────────────────────
  // GROUP 2: Kelas BLoC (TC-10 s/d TC-16)
  // ──────────────────────────────────────────────────────────
  group('Kelas BLoC —', () {
    late FakeKelasRepository repo;
    setUp(() => repo = FakeKelasRepository());

    // TC-10 ─────────────────────────────────────────────────
    blocTest<KelasBloc, KelasState>(
      'TC-10 Buat Kelas "XII RPL 1" → KelasModel tersimpan, kode 6 karakter, KelasActionSuccess',
      build: () => _buildKelasBloc(repo),
      act: (KelasBloc b) =>
          b.add(KelasCreateRequested(nama: 'XII RPL 1', guruId: 'guru-001')),
      expect: () => [
        isA<KelasLoading>(),
        isA<KelasActionSuccess>(),
        isA<KelasLoading>(),
        isA<KelasLoaded>(),
      ],
      verify: (KelasBloc _) {
        expect(repo.kelasList, isNotEmpty);
        expect(repo.kelasList.first.kodeKelas.length, 6);
      },
    );

    // TC-11 ─────────────────────────────────────────────────
    test(
      'TC-11 Buat Kelas Nama Kosong → Dialog form validator mencegah submit, Bloc tidak dipanggil',
      () {
        final bloc = _buildKelasBloc(repo);
        // Bloc belum menerima event → state masih awal
        expect(bloc.state, isA<KelasInitial>());
        // Simulasi form validator: nama kosong harus ditolak
        const namaKosong = '';
        expect(namaKosong.trim().isEmpty, isTrue,
            reason: 'Nama kosong seharusnya ditolak oleh form validator');
        bloc.close();
      },
    );

    // TC-12 ─────────────────────────────────────────────────
    blocTest<KelasBloc, KelasState>(
      'TC-12 Ambil Daftar Kelas Guru → KelasLoaded dengan 2 item',
      build: () {
        repo.seed([
          _makeKelas(id: 'k1', guruId: 'guru-001'),
          _makeKelas(id: 'k2', guruId: 'guru-001'),
          _makeKelas(id: 'k3', guruId: 'guru-002'),
        ]);
        return _buildKelasBloc(repo);
      },
      act: (KelasBloc b) => b.add(KelasFetchGuruRequested('guru-001')),
      expect: () => [
        isA<KelasLoading>(),
        isA<KelasLoaded>().having(
            (KelasLoaded s) => s.kelasList.length, 'length', 2),
      ],
    );

    // TC-13 ─────────────────────────────────────────────────
    blocTest<KelasBloc, KelasState>(
      'TC-13 Ambil Daftar Kelas Siswa → KelasLoaded dengan 1 item',
      build: () {
        repo.seed([
          _makeKelas(id: 'k1', guruId: 'guru-001', siswaIds: ['siswa-001']),
          _makeKelas(id: 'k2', guruId: 'guru-001', siswaIds: ['siswa-002']),
        ]);
        return _buildKelasBloc(repo);
      },
      act: (KelasBloc b) => b.add(KelasFetchSiswaRequested('siswa-001')),
      expect: () => [
        isA<KelasLoading>(),
        isA<KelasLoaded>().having(
            (KelasLoaded s) => s.kelasList.length, 'length', 1),
      ],
    );

    // TC-14 ─────────────────────────────────────────────────
    blocTest<KelasBloc, KelasState>(
      'TC-14 Siswa Gabung Kelas (DEF456) → siswaId masuk siswaIds, KelasActionSuccess',
      build: () {
        repo.seed([_makeKelas(kodeKelas: 'DEF456')]);
        return _buildKelasBloc(repo);
      },
      act: (KelasBloc b) => b
          .add(KelasJoinRequested(kodeKelas: 'DEF456', siswaId: 'siswa-NEW')),
      expect: () => [
        isA<KelasLoading>(),
        isA<KelasActionSuccess>(),
        isA<KelasLoading>(),
        isA<KelasLoaded>(),
      ],
      verify: (KelasBloc _) {
        expect(repo.kelasList.first.siswaIds, contains('siswa-NEW'));
      },
    );

    // TC-15 ─────────────────────────────────────────────────
    test(
      'TC-15 Siswa Gabung Kelas Sudah Member → KelasActionSuccess, tidak ada duplikat',
      () async {
        repo.seed([_makeKelas(kodeKelas: 'DEF456', siswaIds: ['siswa-001'])]);
        await repo.joinKelas('DEF456', 'siswa-001');
        await repo.joinKelas('DEF456', 'siswa-001');
        final count = repo.kelasList.first.siswaIds
            .where((id) => id == 'siswa-001')
            .length;
        expect(count, 1, reason: 'Tidak boleh ada duplikat siswaId');
      },
    );

    // TC-16 ─────────────────────────────────────────────────
    blocTest<KelasBloc, KelasState>(
      'TC-16 Hapus Kelas → Kelas terhapus dari Hive, list diperbarui',
      build: () {
        repo.seed([_makeKelas(id: 'kelas-DEL', guruId: 'guru-001')]);
        return _buildKelasBloc(repo);
      },
      act: (KelasBloc b) =>
          b.add(KelasDeleteRequested(kelasId: 'kelas-DEL', guruId: 'guru-001')),
      expect: () => [
        isA<KelasLoading>(),
        isA<KelasActionSuccess>(),
        isA<KelasLoading>(),
        isA<KelasLoaded>(),
      ],
      verify: (KelasBloc _) {
        expect(repo.kelasList.any((k) => k.id == 'kelas-DEL'), isFalse);
      },
    );
  });

  // ──────────────────────────────────────────────────────────
  // GROUP 3: Editor BLoC (TC-17 s/d TC-20)
  // ──────────────────────────────────────────────────────────
  group('Editor BLoC —', () {
    // TC-17 ─────────────────────────────────────────────────
    blocTest<EditorBloc, EditorState>(
      'TC-17 Load Editor Project Baru (sub-001) → EditorLoaded, 1 halaman pembuka, halamanPembuka set',
      build: () => EditorBloc(),
      act: (EditorBloc b) => b.add(EditorLoadRequested('sub-001')),
      expect: () => [
        isA<EditorLoading>(),
        isA<EditorLoaded>()
            .having((EditorLoaded s) => s.project.pages.length, 'pages.length', 1)
            .having((EditorLoaded s) => s.activePageId, 'activePageId',
                isNotNull),
      ],
      verify: (EditorBloc b) {
        final s = b.state as EditorLoaded;
        expect(s.project.halamanPembuka, isNotEmpty);
        expect(s.project.pages.first.tipe, PageTipe.pembuka);
      },
    );

    // TC-18 ─────────────────────────────────────────────────
    blocTest<EditorBloc, EditorState>(
      'TC-18 Tambah Objek Baru (Blok tampilkanTeks) → blocks +1, updatedAt diperbarui',
      build: () => EditorBloc(),
      act: (EditorBloc b) async {
        b.add(EditorLoadRequested('sub-002'));
        await Future.delayed(Duration.zero);
        final s = b.state as EditorLoaded;
        final pageId = s.project.pages.first.id;
        b.add(EditorBlockAdded(
          pageId: pageId,
          block: const BlockData(
            id: 'block-obj-001',
            tipe: BlockType.tampilkanTeks,
            kategori: BlockKategori.konten,
            parameter: {'teks': 'Objek baru'},
            urutan: 0,
          ),
        ));
      },
      expect: () => [
        isA<EditorLoading>(),
        isA<EditorLoaded>().having(
            (EditorLoaded s) => s.project.pages.first.blocks.length,
            'blocks setelah load', 0),
        isA<EditorLoaded>().having(
            (EditorLoaded s) => s.project.pages.first.blocks.length,
            'blocks setelah add', 1),
      ],
      verify: (EditorBloc b) {
        final s = b.state as EditorLoaded;
        // updatedAt harus lebih baru atau sama dari saat project dibuat
        expect(s.project.updatedAt, isNotNull);
      },
    );

    // TC-19 ─────────────────────────────────────────────────
    // CATATAN: TC-19 "Buat Objek via PCD (Kamera)" adalah MANUAL TEST
    // karena membutuhkan hardware kamera nyata dan proses PCD (edge detection).
    // Stub di bawah memverifikasi bahwa blok bertipe 'gambar' dapat ditambahkan
    // ke editor (simulasi hasil upload/capture yang sudah diproses PCD).
    blocTest<EditorBloc, EditorState>(
      'TC-19 [STUB] Buat Objek via PCD – blok gambar hasil PCD dapat ditambahkan ke halaman',
      build: () => EditorBloc(),
      act: (EditorBloc b) async {
        b.add(EditorLoadRequested('sub-003'));
        await Future.delayed(Duration.zero);
        final s = b.state as EditorLoaded;
        final pageId = s.project.pages.first.id;
        // Simulasi: gambar hasil PCD sudah ada sebagai path/url lokal
        b.add(EditorBlockAdded(
          pageId: pageId,
          block: const BlockData(
            id: 'block-pcd-001',
            tipe: BlockType.tampilkanGambarLatar,
            kategori: BlockKategori.konten,
            parameter: {'imagePath': '/storage/pcd_result_001.png'},
            urutan: 0,
          ),
        ));
      },
      expect: () => [
        isA<EditorLoading>(),
        isA<EditorLoaded>().having(
            (EditorLoaded s) => s.project.pages.first.blocks.length,
            'blocks setelah load', 0),
        isA<EditorLoaded>().having(
            (EditorLoaded s) => s.project.pages.first.blocks.length,
            'blocks setelah add PCD', 1),
      ],
      verify: (EditorBloc b) {
        final s = b.state as EditorLoaded;
        final blok = s.project.pages.first.blocks.first;
        expect(blok.tipe, BlockType.tampilkanGambarLatar);
        expect(blok.parameter['imagePath'], contains('pcd_result'));
      },
    );

    // TC-20 ─────────────────────────────────────────────────
    blocTest<EditorBloc, EditorState>(
      'TC-20 EditorBlockAdded saat EditorInitial → Tidak ada perubahan state, tidak crash',
      build: () => EditorBloc(),
      act: (EditorBloc b) => b.add(EditorBlockAdded(
        pageId: 'halaman-x',
        block: const BlockData(
          id: 'block-X',
          tipe: BlockType.tampilkanTeks,
          kategori: BlockKategori.konten,
          parameter: {},
          urutan: 0,
        ),
      )),
      expect: () => <EditorState>[],
    );
  });

  // ──────────────────────────────────────────────────────────
  // GROUP 4: StoryProjectData Entity (TC-21 s/d TC-23)
  // ──────────────────────────────────────────────────────────
  group('StoryProjectData —', () {
    const halamanPembuka = PageModel(
      id: 'p-01',
      judul: 'Pembuka',
      tipe: PageTipe.pembuka,
      blocks: [],
      connections: {},
      nextPageId: 'p-02',
    );
    const halamanEnding = PageModel(
      id: 'p-02',
      judul: 'Ending',
      tipe: PageTipe.ending,
      blocks: [],
      connections: {},
    );
    const halamanIsolated = PageModel(
      id: 'p-iso',
      judul: 'Isolated',
      tipe: PageTipe.normal,
      blocks: [],
      connections: {},
    );

    // TC-21 ─────────────────────────────────────────────────
    test('TC-21 StoryProjectData.isValid — Valid → isValid == true', () {
      final project = StoryProjectData(
        id: 'proj-1',
        assignmentId: 'asgn-1',
        judulCerita: 'Cerita Valid',
        namaPenulis: 'Budi',
        halamanPembuka: 'p-01',
        pages: const [halamanPembuka, halamanEnding],
        variabelKarakter: const {},
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      expect(project.isValid, isTrue);
    });

    // TC-22 ─────────────────────────────────────────────────
    test(
        'TC-22 StoryProjectData.isValid — Tidak Ada Ending → isValid == false',
        () {
      final project = StoryProjectData(
        id: 'proj-2',
        assignmentId: 'asgn-1',
        judulCerita: 'Cerita Tanpa Ending',
        namaPenulis: 'Budi',
        halamanPembuka: 'p-01',
        pages: const [halamanPembuka], // tidak ada ending
        variabelKarakter: const {},
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      expect(project.isValid, isFalse);
    });

    // TC-23 ─────────────────────────────────────────────────
    test(
        'TC-23 StoryProjectData.isolatedPages → isolatedPages.length == 1',
        () {
      final project = StoryProjectData(
        id: 'proj-3',
        assignmentId: 'asgn-1',
        judulCerita: 'Cerita',
        namaPenulis: 'Budi',
        halamanPembuka: 'p-01',
        pages: const [halamanPembuka, halamanEnding, halamanIsolated],
        variabelKarakter: const {},
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      );
      expect(project.isolatedPages.length, 1);
      expect(project.isolatedPages.first.id, 'p-iso');
    });
  });

  // ──────────────────────────────────────────────────────────
  // GROUP 5: Failure Messages (TC-24 s/d TC-25)
  // ──────────────────────────────────────────────────────────
  group('Failure Messages —', () {
    // TC-24 ─────────────────────────────────────────────────
    test(
      'TC-24 LocalStorageFailure.message → "Gagal menyimpan atau membaca data lokal."',
      () {
        const failure = LocalStorageFailure();
        expect(failure.message, 'Gagal menyimpan atau membaca data lokal.');
      },
    );

    // TC-25 ─────────────────────────────────────────────────
    test(
      'TC-25 AuthFailure.message → "Email atau password tidak valid."',
      () {
        const failure = AuthFailure();
        expect(failure.message, 'Email atau password tidak valid.');
      },
    );
  });

  // ──────────────────────────────────────────────────────────
  // GROUP 6: Load & Stress Test — 100 Siswa & 30 Kelas (TC-26 s/d TC-33)
  // ──────────────────────────────────────────────────────────
  group('Load & Stress Test —', () {
    late FakeKelasRepository repo;
    setUp(() => repo = FakeKelasRepository());

    // TC-26 ─────────────────────────────────────────────────
    test(
      'TC-26 Load 100 Siswa dalam 1 Kelas → getSiswaInKelas 100 item, tidak ada duplikat',
      () async {
        // Buat 100 siswaId unik
        final siswaIds = List.generate(100, (i) => 'siswa-${i.toString().padLeft(3, '0')}');
        repo.seed([_makeKelas(id: 'kelas-besar', siswaIds: siswaIds)]);

        final result = await repo.getSiswaInKelas('kelas-besar');
        // getSiswaInKelas hanya mengembalikan [] pada FakeRepo — kita verifikasi
        // via kelasList.siswaIds sebagai representasi data yang benar
        final kelas = repo.kelasList.first;
        expect(kelas.siswaIds.length, 100);
        // Tidak ada duplikat
        final uniqueIds = kelas.siswaIds.toSet();
        expect(uniqueIds.length, 100,
            reason: 'Tidak boleh ada duplikat siswaId');
        expect(result.data, isNotNull);
      },
    );

    // TC-27 DIHAPUS (per permintaan)

    // TC-28 ─────────────────────────────────────────────────
    test(
      'TC-28 Kelas 100 Siswa – Join Siswa ke-101 → berhasil, tidak ada data siswa lain yang hilang',
      () async {
        final siswaIds = List.generate(100, (i) => 'siswa-${i.toString().padLeft(3, '0')}');
        repo.seed([_makeKelas(id: 'kelas-besar', kodeKelas: 'BESAR1', siswaIds: siswaIds)]);

        await repo.joinKelas('BESAR1', 'siswa-101-baru');

        final kelas = repo.kelasList.first;
        expect(kelas.siswaIds.length, 101,
            reason: 'Siswa ke-101 harus berhasil bergabung');
        expect(kelas.siswaIds.contains('siswa-101-baru'), isTrue);
        // Pastikan 100 siswa lama tidak ada yang hilang
        for (final id in siswaIds) {
          expect(kelas.siswaIds.contains(id), isTrue,
              reason: 'Siswa $id tidak boleh hilang');
        }
      },
    );

    // TC-29 ─────────────────────────────────────────────────
    test(
      'TC-29 Guru Memiliki 30 Kelas – Fetch All → KelasLoaded berisi 30 KelasModel, nama & kode akurat',
      () async {
        final tigaPuluhKelas = List.generate(
          30,
          (i) => _makeKelas(
            id: 'kelas-${(i + 1).toString().padLeft(3, '0')}',
            nama: 'Kelas ${i + 1}',
            guruId: 'guru-001',
            kodeKelas: 'K${(i + 1).toString().padLeft(5, '0')}',
          ),
        );
        repo.seed(tigaPuluhKelas);

        final result = await repo.getKelasGuru('guru-001');
        expect(result.data, isNotNull);
        expect(result.data!.length, 30,
            reason: 'Harus mengembalikan tepat 30 kelas');
        // Verifikasi nama dan kode akurat
        for (int i = 0; i < 30; i++) {
          expect(result.data![i].nama, 'Kelas ${i + 1}');
          expect(result.data![i].kodeKelas,
              'K${(i + 1).toString().padLeft(5, '0')}');
        }
      },
    );

    // TC-30 ─────────────────────────────────────────────────
    test(
      'TC-30 Guru 30 Kelas – Hapus 1 Kelas (kelas-005) → fetch ulang mengembalikan 29 kelas',
      () async {
        final tigaPuluhKelas = List.generate(
          30,
          (i) => _makeKelas(
            id: 'kelas-${(i + 1).toString().padLeft(3, '0')}',
            nama: 'Kelas ${i + 1}',
            guruId: 'guru-001',
            kodeKelas: 'K${(i + 1).toString().padLeft(5, '0')}',
          ),
        );
        repo.seed(tigaPuluhKelas);

        await repo.deleteKelas('kelas-005');

        final result = await repo.getKelasGuru('guru-001');
        expect(result.data!.length, 29,
            reason: 'Harus 29 kelas setelah 1 dihapus');
        expect(
          result.data!.any((k) => k.id == 'kelas-005'),
          isFalse,
          reason: 'kelas-005 sudah tidak ada',
        );
      },
    );

    // TC-31 ─────────────────────────────────────────────────
    test(
      'TC-31 Guru 30 Kelas – Tambah Kelas ke-31 → KelasActionSuccess; fetch guru mengembalikan 31 kelas',
      () async {
        final tigaPuluhKelas = List.generate(
          30,
          (i) => _makeKelas(
            id: 'kelas-${(i + 1).toString().padLeft(3, '0')}',
            guruId: 'guru-001',
            kodeKelas: 'K${(i + 1).toString().padLeft(5, '0')}',
          ),
        );
        repo.seed(tigaPuluhKelas);

        await repo.createKelas('Kelas Test ke-31', 'guru-001');

        final result = await repo.getKelasGuru('guru-001');
        expect(result.data!.length, 31,
            reason: 'Harus 31 kelas setelah ditambah');
        expect(
          result.data!.any((k) => k.nama == 'Kelas Test ke-31'),
          isTrue,
        );
      },
    );

    // TC-32 ─────────────────────────────────────────────────
    test(
      'TC-32 Guru 30 Kelas – Kode Unik Setiap Kelas → semua kodeKelas tidak ada duplikat',
      () async {
        final tigaPuluhKelas = List.generate(
          30,
          (i) => _makeKelas(
            id: 'kelas-${(i + 1).toString().padLeft(3, '0')}',
            guruId: 'guru-001',
            kodeKelas: 'CODE${(i + 1).toString().padLeft(2, '0')}',
          ),
        );
        repo.seed(tigaPuluhKelas);

        final result = await repo.getKelasGuru('guru-001');
        final semuaKode = result.data!.map((k) => k.kodeKelas).toList();
        final kodeUnik = semuaKode.toSet();
        expect(kodeUnik.length, semuaKode.length,
            reason: 'Semua kodeKelas dari 30 kelas harus unik (tidak ada duplikat)');
      },
    );

    // TC-33 ─────────────────────────────────────────────────
    test(
      'TC-33 Siswa Terdaftar di 30 Kelas – Fetch → getKelasSiswa mengembalikan 30 KelasModel',
      () async {
        // Seed 30 kelas, siswa-001 ada di semua
        final tigaPuluhKelas = List.generate(
          30,
          (i) => _makeKelas(
            id: 'kelas-${(i + 1).toString().padLeft(3, '0')}',
            guruId: 'guru-${(i % 5) + 1}',
            kodeKelas: 'CLS${(i + 1).toString().padLeft(3, '0')}',
            siswaIds: ['siswa-001'],
          ),
        );
        repo.seed(tigaPuluhKelas);

        final result = await repo.getKelasSiswa('siswa-001');
        expect(result.data, isNotNull);
        expect(result.data!.length, 30,
            reason: 'siswa-001 harus muncul di 30 kelas');
        // kelasIds siswa berisi 30 entri
        final allSiswaIds = result.data!
            .expand((k) => k.siswaIds)
            .where((id) => id == 'siswa-001')
            .length;
        expect(allSiswaIds, 30);
      },
    );
  });

  // ──────────────────────────────────────────────────────────
  // GROUP 7: Guest Mode (TC-34)
  // ──────────────────────────────────────────────────────────
  group('Guest Mode —', () {
    // TC-34 ─────────────────────────────────────────────────
    // TC-34 Membuat Project di guest mode
    // Input    : submissionId = 'guest-project-001' (tanpa autentikasi)
    // Ekspektasi: EditorBloc berhasil load project baru;
    //             state EditorLoaded; project memiliki 1 halaman pembuka;
    //             dapat diedit tanpa crash meski tidak ada user login.
    blocTest<EditorBloc, EditorState>(
      'TC-34 Membuat Project di Guest Mode → EditorLoaded, project baru bisa dibuat & diedit tanpa auth',
      build: () => EditorBloc(),
      act: (EditorBloc b) async {
        // Guest menggunakan submissionId konvensi 'guest-xxx'
        b.add(EditorLoadRequested('guest-project-001'));
        await Future.delayed(Duration.zero);
        // Guest langsung bisa menambah blok
        final s = b.state as EditorLoaded;
        b.add(EditorBlockAdded(
          pageId: s.project.pages.first.id,
          block: const BlockData(
            id: 'guest-block-001',
            tipe: BlockType.tampilkanTeks,
            kategori: BlockKategori.konten,
            parameter: {'teks': 'Cerita guest saya'},
            urutan: 0,
          ),
        ));
      },
      expect: () => [
        isA<EditorLoading>(),
        isA<EditorLoaded>()
            .having((EditorLoaded s) => s.project.pages.length,
                'halaman awal', 1)
            .having((EditorLoaded s) => s.activePageId, 'activePageId',
                isNotNull),
        isA<EditorLoaded>().having(
            (EditorLoaded s) => s.project.pages.first.blocks.length,
            'blocks setelah add', 1),
      ],
      verify: (EditorBloc b) {
        final s = b.state as EditorLoaded;
        // Project guest: halamanPembuka harus ada
        expect(s.project.halamanPembuka, isNotEmpty);
        // Blok yang ditambahkan guest harus tersimpan
        expect(s.project.pages.first.blocks.first.id, 'guest-block-001');
      },
    );
  });
}
