// lib/core/base/base_state.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Sealed class State yang digunakan sebagai base untuk semua Cubit/BLoC state.
// SWEBOK v3: Representasi state yang eksplisit mencegah "impossible states".

import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base sealed class untuk state aplikasi KOMET.
///
/// Setiap feature Cubit harus extend salah satu dari turunan ini.
///
/// Contoh penggunaan:
/// ```dart
/// class SubmissionState extends KometState<List<SubmissionModel>> {}
///
/// // Di Cubit:
/// emit(KometLoading());
/// emit(KometSuccess(data: submissions));
/// emit(KometError(failure: NetworkFailure()));
/// ```
sealed class KometState<T> extends Equatable {
  const KometState();
}

/// State awal sebelum aksi apapun dilakukan.
final class KometInitial<T> extends KometState<T> {
  const KometInitial();

  @override
  List<Object?> get props => [];
}

/// State loading — proses sedang berjalan.
final class KometLoading<T> extends KometState<T> {
  const KometLoading();

  @override
  List<Object?> get props => [];
}

/// State berhasil — data tersedia.
final class KometSuccess<T> extends KometState<T> {
  final T data;
  const KometSuccess({required this.data});

  @override
  List<Object?> get props => [data];
}

/// State gagal — failure tersedia untuk ditampilkan ke UI.
final class KometError<T> extends KometState<T> {
  final Failure failure;
  const KometError({required this.failure});

  @override
  List<Object?> get props => [failure];

  /// Pesan error siap ditampilkan di UI snackbar/dialog.
  String get displayMessage => failure.message;
}
