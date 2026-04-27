import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/user_model.dart';

/// Kontrak (interface) untuk auth repository.
/// Implementasinya ada di data/repositories/auth_repository_impl.dart
abstract class AuthRepository {
  KometResult<UserModel> login(String email, String password);
  KometResult<UserModel> registerGuru(
    String nama,
    String email,
    String password,
  );
  KometResult<UserModel> registerSiswa(
    String nama,
    String email,
    String password,
    String? kodeKelas,
  );
  KometResult<void> logout();
  KometResult<UserModel?> getCurrentUser();
}
