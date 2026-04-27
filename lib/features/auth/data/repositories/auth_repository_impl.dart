import 'package:uuid/uuid.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final AuthRemoteDataSource remoteDataSource;
  final Uuid uuid;

  AuthRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.uuid,
  });

  @override
  KometResult<UserModel?> getCurrentUser() async {
    try {
      final user = await localDataSource.getCurrentUser();
      return kometSuccess<UserModel?>(
        user,
      ); // explicit type agar Dart tidak salah infer T=UserModel
    } catch (e) {
      // FIX: CacheFailure tidak ada → gunakan LocalStorageFailure
      // FIX: parameter positional bukan named
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<UserModel> login(String email, String password) async {
    try {
      // 1. Coba login via server (MongoDB)
      final user = await remoteDataSource.login(email, password);
      // 2. Jika sukses, simpan session ke lokal
      await localDataSource.registerGuru(user); 
      return kometSuccess(user);
    } catch (e) {
      // FIX: AuthFailure parameter positional
      return kometFailure(AuthFailure(e.toString()));
    }
  }

  @override
  KometResult<void> logout() async {
    try {
      await localDataSource.logout();
      return kometSuccess(null);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<UserModel> registerGuru(
    String nama,
    String email,
    String password, {
    String? id,
  }) async {
    try {
      final user = UserModel(
        id: id ?? uuid.v4(),
        nama: nama,
        email: email,
        password: password,
        role: 'guru',
        kelasIds: [],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      // 1. Register ke server (MongoDB)
      final remoteUser = await remoteDataSource.registerGuru(user);
      
      // 2. Simpan ke lokal
      final result = await localDataSource.registerGuru(remoteUser);
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(AuthFailure(e.toString()));
    }
  }

  @override
  KometResult<UserModel> registerSiswa(
    String nama,
    String email,
    String password, {
    String? kodeKelas,
    String? id,
  }) async {
    try {
      final user = UserModel(
        id: id ?? uuid.v4(),
        nama: nama,
        email: email,
        password: password,
        role: 'siswa',
        kelasIds: [],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      // 1. Register ke server (MongoDB)
      final remoteUser = await remoteDataSource.registerSiswa(user, kodeKelas);
      
      // 2. Simpan ke lokal
      final result = await localDataSource.registerSiswa(remoteUser, kodeKelas);
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(AuthFailure(e.toString()));
    }
  }

  @override
  KometResult<UserModel> signInWithGoogle() async {
    try {
      final user = await remoteDataSource.signInWithGoogle();
      // Simpan session ke lokal HANYA jika bukan user baru (yang belum pilih role)
      if (user.role != 'NEW_USER') {
        if (user.role == 'guru') {
          await localDataSource.registerGuru(user);
        } else {
          await localDataSource.registerSiswa(user, null);
        }
      }
      return kometSuccess(user);
    } catch (e) {
      return kometFailure(AuthFailure(e.toString()));
    }
  }
}
