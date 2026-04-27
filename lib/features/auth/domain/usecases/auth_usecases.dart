import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/user_model.dart';
import '../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;
  LoginParams({required this.email, required this.password});
}

class LoginUseCase implements UseCase<UserModel, LoginParams> {
  final AuthRepository repository;
  LoginUseCase(this.repository);

  @override
  KometResult<UserModel> call(LoginParams params) {
    return repository.login(params.email, params.password);
  }
}

class RegisterGuruParams {
  final String nama;
  final String email;
  final String password;
  final String? id;
  RegisterGuruParams({required this.nama, required this.email, required this.password, this.id});
}

class RegisterGuruUseCase implements UseCase<UserModel, RegisterGuruParams> {
  final AuthRepository repository;
  RegisterGuruUseCase(this.repository);

  @override
  KometResult<UserModel> call(RegisterGuruParams params) {
    return repository.registerGuru(params.nama, params.email, params.password, id: params.id);
  }
}

class RegisterSiswaParams {
  final String nama;
  final String email;
  final String password;
  final String? kodeKelas;
  final String? id;
  RegisterSiswaParams({
    required this.nama,
    required this.email,
    required this.password,
    this.kodeKelas,
    this.id,
  });
}

class RegisterSiswaUseCase implements UseCase<UserModel, RegisterSiswaParams> {
  final AuthRepository repository;
  RegisterSiswaUseCase(this.repository);

  @override
  KometResult<UserModel> call(RegisterSiswaParams params) {
    return repository.registerSiswa(
      params.nama,
      params.email,
      params.password,
      kodeKelas: params.kodeKelas,
      id: params.id,
    );
  }
}

class LogoutUseCase implements UseCaseNoParams<void> {
  final AuthRepository repository;
  LogoutUseCase(this.repository);

  @override
  KometResult<void> call() {
    return repository.logout();
  }
}

class GetCurrentUserUseCase implements UseCaseNoParams<UserModel?> {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);

  @override
  KometResult<UserModel?> call() {
    return repository.getCurrentUser();
  }
}

class GoogleLoginUseCase implements UseCaseNoParams<UserModel> {
  final AuthRepository repository;
  GoogleLoginUseCase(this.repository);

  @override
  KometResult<UserModel> call() {
    return repository.signInWithGoogle();
  }
}
