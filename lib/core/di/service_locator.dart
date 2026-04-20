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
import '../router/app_router.dart';
import '../local_storage/hive_service.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
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
  // ── Core: Network ───────────────────────────────────────────────────────
  // ConnectivityService: singleton — satu instance untuk seluruh app (F-53)
  sl.registerLazySingleton<ConnectivityService>(
    () => ConnectivityServiceImpl(),
  );

  // ── Core: Router ────────────────────────────────────────────────────────
  sl.registerLazySingleton<GoRouter>(() => appRouter);

  // ── Core: Local Storage (Hive) ──────────────────────────────────────────
  sl.registerLazySingleton<HiveService>(() => HiveService());

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

  // ── PIC D: Editor Engine Use Cases ─────────────────────────────────────
  // Didaftarkan setelah editor_engine selesai
  // sl.registerLazySingleton<LoadStoryUseCase>(...)
  // sl.registerLazySingleton<SaveStoryUseCase>(...)
  // sl.registerFactory<StoryInterpreter>(...)

  // ── Mulai monitoring koneksi ────────────────────────────────────────────
  sl<ConnectivityService>().startMonitoring();
}
