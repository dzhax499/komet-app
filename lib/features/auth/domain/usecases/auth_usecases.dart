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

class UpdateProfileParams {
  final String userId;
  final String? nama;
  final String? photoUrl;
  UpdateProfileParams({required this.userId, this.nama, this.photoUrl});
}

class UpdateProfileUseCase implements UseCase<UserModel, UpdateProfileParams> {
  final AuthRepository repository;
  UpdateProfileUseCase(this.repository);

  @override
  KometResult<UserModel> call(UpdateProfileParams params) {
    return repository.updateProfile(params.userId, nama: params.nama, photoUrl: params.photoUrl);
  }
}

class SendPasswordResetOtpUseCase implements UseCase<void, String> {
  final AuthRepository repository;
  SendPasswordResetOtpUseCase(this.repository);

  @override
  KometResult<void> call(String email) {
    return repository.sendPasswordResetOtp(email);
  }
}

class VerifyOtpParams {
  final String email;
  final String otp;
  VerifyOtpParams({required this.email, required this.otp});
}

class VerifyResetOtpUseCase implements UseCase<void, VerifyOtpParams> {
  final AuthRepository repository;
  VerifyResetOtpUseCase(this.repository);

  @override
  KometResult<void> call(VerifyOtpParams params) {
    return repository.verifyResetOtp(params.email, params.otp);
  }
}

class ResetPasswordParams {
  final String email;
  final String newPassword;
  ResetPasswordParams({required this.email, required this.newPassword});
}

class ResetPasswordUseCase implements UseCase<void, ResetPasswordParams> {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);

  @override
  KometResult<void> call(ResetPasswordParams params) {
    return repository.resetPassword(params.email, params.newPassword);
  }
}
