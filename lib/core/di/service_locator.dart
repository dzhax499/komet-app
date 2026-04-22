// lib/core/di/service_locator.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// GetIt Service Locator — dependency injection entry point.
// Panggil setupServiceLocator() di main() sebelum runApp().
//
// Cara menggunakan:
//   final connectivity = sl<ConnectivityService>();
//   final router = sl<GoRouter>();

import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import '../network/connectivity_service.dart';
import '../network/sync_queue_service.dart';
import '../router/app_router.dart';
import '../local_storage/hive_service.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/kelas/data/datasources/kelas_local_data_source.dart';
import '../../features/kelas/data/repositories/kelas_repository_impl.dart';
import '../../features/kelas/domain/repositories/kelas_repository.dart';
import '../../features/kelas/domain/usecases/kelas_usecases.dart';
import '../../features/kelas/presentation/bloc/kelas_bloc.dart';
import '../../features/editor_engine/presentation/bloc/editor_bloc.dart';
import 'package:uuid/uuid.dart';

/// Instance global GetIt. Gunakan alias [sl] (short: service locator).
final GetIt sl = GetIt.instance;

/// Inisialisasi semua dependency. Panggil di main() sebelum runApp().
///
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   await setupServiceLocator();
///   runApp(const KometApp());
/// }
/// ```
Future<void> setupServiceLocator() async {

  // ── Core: Local Storage (Hive) — HARUS PERTAMA ────────────────────────
  final hiveService = HiveService();
  await hiveService.init(); // ✅ WAIT FOR INIT
  sl.registerSingleton<HiveService>(hiveService);
  
  // ── Core: Network ───────────────────────────────────────────────────────
  // ConnectivityService: singleton — satu instance untuk seluruh app (F-53)
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(),
  );

  sl.registerLazySingleton<SyncQueueService>(
    () => SyncQueueService(
      hiveService: sl(),
      connectivityService: sl(),
    ),
  );

  // ── Core: Router ────────────────────────────────────────────────────────
  sl.registerLazySingleton<GoRouter>(() => appRouter);


  // ── PIC B: MongoDB Service ───────────────────────────────────────────────
  // TODO PIC B: Implementasikan MongoDBService
  // sl.registerLazySingleton<MongoDBService>(() => MongoDBServiceImpl());

  // ── PIC B: Repository ────────────────────────────────────────────────────
  // TODO PIC B:
  // sl.registerLazySingleton<SubmissionRepository>(...)
  // sl.registerLazySingleton<SyncRepository>(...)

  // ── Auth Module (PIC A) ────────────────────────────────────────────────
  sl.registerLazySingleton<Uuid>(() => const Uuid());
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(hiveService: sl()),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(localDataSource: sl(), uuid: sl()),
  );
  
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterGuruUseCase(sl()));
  sl.registerLazySingleton(() => RegisterSiswaUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));

  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerGuruUseCase: sl(),
      registerSiswaUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  // ── Kelas Module (PIC A) ───────────────────────────────────────────────
  sl.registerLazySingleton<KelasLocalDataSource>(
    () => KelasLocalDataSourceImpl(hiveService: sl()),
  );
  
  sl.registerLazySingleton<KelasRepository>(
    () => KelasRepositoryImpl(localDataSource: sl(), uuid: sl()),
  );
  
  sl.registerLazySingleton(() => CreateKelasUseCase(sl()));
  sl.registerLazySingleton(() => GetKelasGuruUseCase(sl()));
  sl.registerLazySingleton(() => GetKelasSiswaUseCase(sl()));
  sl.registerLazySingleton(() => JoinKelasUseCase(sl()));
  sl.registerLazySingleton(() => DeleteKelasUseCase(sl()));
  sl.registerLazySingleton(() => GetSiswaInKelasUseCase(sl()));

  sl.registerFactory(
    () => KelasBloc(
      createKelasUseCase: sl(),
      getKelasGuruUseCase: sl(),
      getKelasSiswaUseCase: sl(),
      joinKelasUseCase: sl(),
      deleteKelasUseCase: sl(),
    ),
  );

  // ── PIC D: Editor Engine ───────────────────────────────────────────────
  sl.registerFactory(() => EditorBloc());

  // ── Mulai monitoring koneksi & sync ─────────────────────────────────────
  sl<ConnectivityService>().startMonitoring();
  sl<SyncQueueService>().init();
}
