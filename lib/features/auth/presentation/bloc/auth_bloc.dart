import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/usecases/auth_usecases.dart';

// ── EVENTS ──────────────────────────────────────────────────────────────────
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterGuruRequested extends AuthEvent {
  final String nama;
  final String email;
  final String password;
  AuthRegisterGuruRequested({required this.nama, required this.email, required this.password});
  @override
  List<Object?> get props => [nama, email, password];
}

class AuthRegisterSiswaRequested extends AuthEvent {
  final String nama;
  final String email;
  final String password;
  final String kodeKelas;
  AuthRegisterSiswaRequested({
    required this.nama,
    required this.email,
    required this.password,
    required this.kodeKelas,
  });
  @override
  List<Object?> get props => [nama, email, password, kodeKelas];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthCheckStatusRequested extends AuthEvent {}

// ── STATES ──────────────────────────────────────────────────────────────────
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLOC ────────────────────────────────────────────────────────────────────
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterGuruUseCase registerGuruUseCase;
  final RegisterSiswaUseCase registerSiswaUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerGuruUseCase,
    required this.registerSiswaUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckStatusRequested>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthRegisterGuruRequested>(_onRegisterGuru);
    on<AuthRegisterSiswaRequested>(_onRegisterSiswa);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckStatus(AuthCheckStatusRequested event, Emitter<AuthState> emit) async {
    final result = await getCurrentUserUseCase();
    if (result.data != null) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await loginUseCase(LoginParams(email: event.email, password: event.password));
    if (result.data != null) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.failure?.message ?? 'Gagal login'));
    }
  }

  Future<void> _onRegisterGuru(AuthRegisterGuruRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerGuruUseCase(RegisterGuruParams(
      nama: event.nama,
      email: event.email,
      password: event.password,
    ));
    if (result.data != null) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.failure?.message ?? 'Gagal register guru'));
    }
  }

  Future<void> _onRegisterSiswa(AuthRegisterSiswaRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await registerSiswaUseCase(RegisterSiswaParams(
      nama: event.nama,
      email: event.email,
      password: event.password,
      kodeKelas: event.kodeKelas,
    ));
    if (result.data != null) {
      emit(AuthAuthenticated(result.data!));
    } else {
      emit(AuthError(result.failure?.message ?? 'Gagal register siswa'));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    await logoutUseCase();
    emit(AuthUnauthenticated());
  }
}
