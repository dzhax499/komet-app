import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/error/exceptions.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> registerGuru(UserModel user);
  Future<UserModel> registerSiswa(UserModel user, String kodeKelas);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final HiveService hiveService;

  AuthLocalDataSourceImpl({required this.hiveService});

  @override
  Future<UserModel> login(String email, String password) async {
    final user = hiveService.getUserByEmail(email);
    if (user != null && user.password == password) {
      await hiveService.persistUser(user);
      return user;
    } else {
      throw Exception('Email atau password salah');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return hiveService.getCurrentUser();
  }

  @override
  Future<void> logout() async {
    await hiveService.logout();
  }

  @override
  Future<UserModel> registerGuru(UserModel user) async {
    await hiveService.persistUser(user);
    return user;
  }

  @override
  Future<UserModel> registerSiswa(UserModel user, String kodeKelas) async {
    // TODO: Validasi kode kelas (F-02)
    await hiveService.persistUser(user);
    return user;
  }
}
