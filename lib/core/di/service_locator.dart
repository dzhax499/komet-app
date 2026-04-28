import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/foundation.dart';
import '../network/connectivity_service.dart';
import '../network/sync_queue_service.dart';
import '../router/app_router.dart';
import '../local_storage/hive_service.dart';
import '../../features/submission/domain/usecases/get_submissions_by_assignment_use_case.dart';
import '../../features/submission/domain/usecases/get_submissions_by_class_use_case.dart';
import '../../features/submission/domain/usecases/get_review_count_use_case.dart';
import '../../features/submission/domain/usecases/grade_submission_use_case.dart';
import '../../features/submission/domain/usecases/get_submissions_by_student_use_case.dart';
import '../../features/submission/domain/usecases/submit_task_use_case.dart';
import '../../features/submission/presentation/bloc/submission_bloc.dart';
import '../../features/auth/data/datasources/auth_local_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/auth_usecases.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/kelas/data/datasources/kelas_local_data_source.dart';
import '../../features/kelas/data/datasources/kelas_remote_data_source.dart';
import '../../features/kelas/data/repositories/kelas_repository_impl.dart';
import '../../features/kelas/domain/repositories/kelas_repository.dart';
import '../../features/kelas/domain/usecases/kelas_usecases.dart';
import '../../features/kelas/presentation/bloc/kelas_bloc.dart';

import '../../features/assignment/data/datasources/assignment_local_data_source.dart';
import '../../features/assignment/data/datasources/assignment_remote_data_source.dart';
import '../../features/assignment/data/repositories/assignment_repository_impl.dart';
import '../../features/assignment/domain/repositories/assignment_repository.dart';

import '../../features/submission/data/datasources/submission_local_data_source.dart';
import '../../features/submission/data/datasources/submission_remote_data_source.dart';
import '../../features/submission/data/repositories/submission_repository_impl.dart';
import '../../features/submission/domain/repositories/submission_repository.dart';

import '../../features/project/data/datasources/project_local_data_source.dart';
import '../../features/project/data/datasources/project_remote_data_source.dart';
import '../../features/kelas/domain/usecases/get_kelas_by_id_use_case.dart';
import '../../features/project/data/repositories/project_repository_impl.dart';
import '../../features/project/domain/repositories/project_repository.dart';

import '../../features/assignment/domain/usecases/create_assignment_use_case.dart';
import '../../features/assignment/domain/usecases/get_assignments_by_class_use_case.dart';
import '../../features/assignment/presentation/bloc/assignment_bloc.dart';

import '../../features/editor_engine/presentation/bloc/editor_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../database/mongo_service.dart';

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
  // ── Core: Environment ──────────────────────────────────────────────────
  await dotenv.load(fileName: ".env");

  // ── Core: Local Storage (Hive) — HARUS PERTAMA ────────────────────────
  final hiveService = HiveService();
  await hiveService.init();
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
  final mongoService = MongoService();
  sl.registerSingleton<MongoService>(mongoService);
  mongoService.connect().catchError((e) {
    debugPrint("DATABASE: Koneksi awal gagal (Akan dicoba lagi saat dibutuhkan): $e");
  });

  // ── Auth Module (PIC A) ────────────────────────────────────────────────
  sl.registerLazySingleton<Uuid>(() => const Uuid());
  
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(hiveService: sl()),
  );
  
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(mongoService: sl()),
  );
  
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      localDataSource: sl(), 
      remoteDataSource: sl(),
      uuid: sl(),
    ),
  );
  
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => RegisterGuruUseCase(sl()));
  sl.registerLazySingleton(() => RegisterSiswaUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCurrentUserUseCase(sl()));
  sl.registerLazySingleton(() => GoogleLoginUseCase(sl()));

  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      registerGuruUseCase: sl(),
      registerSiswaUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
      googleLoginUseCase: sl(),
    ),
  );

  // ── Kelas Module (PIC A) ───────────────────────────────────────────────
  sl.registerLazySingleton<KelasLocalDataSource>(
    () => KelasLocalDataSourceImpl(hiveService: sl()),
  );
  
  sl.registerLazySingleton<KelasRemoteDataSource>(
    () => KelasRemoteDataSourceImpl(mongoService: sl()),
  );
  
  sl.registerLazySingleton<KelasRepository>(
    () => KelasRepositoryImpl(
      localDataSource: sl(), 
      remoteDataSource: sl(),
      uuid: sl(),
    ),
  );
  
  sl.registerLazySingleton(() => CreateKelasUseCase(sl()));
  sl.registerLazySingleton(() => GetKelasGuruUseCase(sl()));
  sl.registerLazySingleton(() => GetKelasSiswaUseCase(sl()));
  sl.registerLazySingleton(() => JoinKelasUseCase(sl()));
  sl.registerLazySingleton(() => DeleteKelasUseCase(sl()));
  sl.registerLazySingleton(() => GetSiswaInKelasUseCase(sl()));
  sl.registerLazySingleton(() => GetKelasByIdUseCase(sl()));
  sl.registerLazySingleton(() => LeaveKelasUseCase(sl()));

  sl.registerFactory(
    () => KelasBloc(
      createKelasUseCase: sl(),
      getKelasGuruUseCase: sl(),
      getKelasSiswaUseCase: sl(),
      joinKelasUseCase: sl(),
      deleteKelasUseCase: sl(),
      getKelasByIdUseCase: sl(),
      leaveKelasUseCase: sl(),
    ),
  );

  // Assignment Module (Tahap 1) 
  sl.registerLazySingleton<AssignmentLocalDataSource>(
    () => AssignmentLocalDataSourceImpl(hiveService: sl()),
  );

  sl.registerLazySingleton<AssignmentRemoteDataSource>(
    () => AssignmentRemoteDataSourceImpl(mongoService: sl()),
  );

  sl.registerLazySingleton<AssignmentRepository>(
    () => AssignmentRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      kelasLocalDataSource: sl(),
      uuid: sl(),
    ),
  );

  sl.registerLazySingleton(() => CreateAssignmentUseCase(sl()));
  sl.registerLazySingleton(() => GetAssignmentsByClassUseCase(sl()));

  sl.registerFactory(
    () => AssignmentBloc(
      createAssignmentUseCase: sl(),
      getAssignmentsByClassUseCase: sl(),
    ),
  );

  // Submission Module (Tahap 2) 
  sl.registerLazySingleton<SubmissionLocalDataSource>(
    () => SubmissionLocalDataSourceImpl(hiveService: sl()),
  );

  sl.registerLazySingleton<SubmissionRemoteDataSource>(
    () => SubmissionRemoteDataSourceImpl(mongoService: sl()),
  );

  sl.registerLazySingleton<SubmissionRepository>(
    () => SubmissionRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      uuid: sl(),
    ),
  );

  sl.registerLazySingleton(() => GetSubmissionsByAssignmentUseCase(sl()));
  sl.registerLazySingleton(() => GetSubmissionsByClassUseCase(sl()));
  sl.registerLazySingleton(() => GetReviewCountUseCase(sl()));
  sl.registerLazySingleton(() => GradeSubmissionUseCase(sl()));
  sl.registerLazySingleton(() => GetSubmissionsByStudentUseCase(sl()));
  sl.registerLazySingleton(() => SubmitTaskUseCase(sl()));

  sl.registerFactory(
    () => SubmissionBloc(
      getSubmissionsByAssignmentUseCase: sl(),
      getSubmissionsByClassUseCase: sl(),
      getReviewCountUseCase: sl(),
      gradeSubmissionUseCase: sl(),
      getSubmissionsByStudentUseCase: sl(),
      submitTaskUseCase: sl(),
    ),
  );

  // ── Project Module (Tahap 3) ───────────────────────────────────────────
  sl.registerLazySingleton<ProjectLocalDataSource>(
    () => ProjectLocalDataSourceImpl(hiveService: sl()),
  );

  sl.registerLazySingleton<ProjectRemoteDataSource>(
    () => ProjectRemoteDataSourceImpl(mongoService: sl()),
  );

  sl.registerLazySingleton<ProjectRepository>(
    () => ProjectRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
      uuid: sl(),
    ),
  );

  // ── PIC D: Editor Engine ───────────────────────────────────────────────
  sl.registerFactory(() => EditorBloc());

  // ── Mulai monitoring koneksi & sync ─────────────────────────────────────
  sl<ConnectivityService>().startMonitoring();
  sl<SyncQueueService>().init();
}
