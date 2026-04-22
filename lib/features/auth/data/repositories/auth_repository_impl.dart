import 'package:uuid/uuid.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthLocalDataSource localDataSource;
  final Uuid uuid;

  AuthRepositoryImpl({required this.localDataSource, required this.uuid});

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
      final user = await localDataSource.login(email, password);
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
    String password,
  ) async {
    try {
      final user = UserModel(
        id: uuid.v4(),
        nama: nama,
        email: email,
        password: password,
        role: 'guru',
        kelasIds: [],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      final result = await localDataSource.registerGuru(user);
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(AuthFailure(e.toString()));
    }
  }

  @override
  KometResult<UserModel> registerSiswa(
    String nama,
    String email,
    String password,
    String? kodeKelas,
  ) async {
    try {
      final user = UserModel(
        id: uuid.v4(),
        nama: nama,
        email: email,
        password: password,
        role: 'siswa',
        kelasIds: [],
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      final result = await localDataSource.registerSiswa(user, kodeKelas);
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(AuthFailure(e.toString()));
    }
  }
}
