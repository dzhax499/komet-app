// lib/core/utils/constants.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Konstanta global yang digunakan di seluruh aplikasi KOMET.
// SWEBOK v3: Modul constants mencegah "magic string" dan meningkatkan maintainability.

/// Nama-nama Hive box yang digunakan untuk penyimpanan lokal.
/// PIC B (submission/, sync/) wajib menggunakan konstanta ini agar konsisten.
class KometBoxNames {
  KometBoxNames._();

  static const String users = 'komet_users';
  static const String kelas = 'komet_kelas';
  static const String assignments = 'komet_assignments';
  static const String submissions = 'komet_submissions';
  static const String storyProjects = 'komet_story_projects';
  static const String notifications = 'komet_notifications';
  static const String syncQueue = 'komet_sync_queue';
  static const String settings = 'komet_settings';
}

/// Path-path route GoRouter. Gunakan konstanta ini — jangan hardcode string path.
class KometRoutes {
  KometRoutes._();

  // Auth — PIC A
  static const String splash = '/';
  static const String login = '/login';
  static const String registerSiswa = '/register/siswa';
  static const String registerGuru = '/register/guru';

  // Dashboard — PIC A
  static const String dashboardGuru = '/dashboard/guru';
  static const String dashboardSiswa = '/dashboard/siswa';

  // Kelas — PIC A
  static const String kelasList = '/kelas';
  static const String kelasDetail = '/kelas/:kelasId';
  static const String kelasSiswa = '/kelas/:kelasId/siswa';

  // Assignment — PIC A
  static const String assignmentList = '/kelas/:kelasId/assignment';
  static const String assignmentDetail = '/assignment/:assignmentId';
  static const String assignmentCreate = '/kelas/:kelasId/assignment/create';

  // Editor — PIC D
  static const String editorCanvas = '/editor/:submissionId';
  static const String editorPreview = '/editor/:submissionId/preview';
  static const String storyMap = '/editor/:submissionId/map';

  // Submission — PIC B & C
  static const String submissionList = '/submission';
  static const String submissionDetail = '/submission/:submissionId';

  // Review — PIC A
  static const String reviewDetail = '/review/:submissionId';

  // Notifikasi — PIC A
  static const String notifications = '/notifications';
}

/// Kunci untuk shared settings di Hive box 'komet_settings'.
class KometSettingsKeys {
  KometSettingsKeys._();

  static const String currentUserId = 'current_user_id';
  static const String currentUserRole = 'current_user_role';
  static const String isLoggedIn = 'is_logged_in';
  static const String lastSyncAt = 'last_sync_at';
}

/// Nilai-nilai default dan limitasi sesuai spesifikasi dokumen pengajuan.
class KometDefaults {
  KometDefaults._();

  /// Panjang kode kelas yang di-generate (F-06)
  static const int kodePanjang = 6;

  /// Maksimal pilihan per halaman cerita (F-27)
  static const int maxPilihanPerHalaman = 3;

  /// Delay auto-save dalam milidetik (F-33)
  static const int autoSaveDelayMs = 1500;

  /// Maksimal percobaan retry sync (F-54)
  static const int maxSyncRetry = 3;

  /// Nilai minimal untuk assignment (F-11)
  static const int nilaiMin = 0;

  /// Nilai maksimal default untuk assignment (F-11)
  static const int nilaiMaksimalDefault = 100;
}
