// lib/core/error/failures.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Hierarchy failure untuk error handling Clean Architecture.
// SWEBOK v3: Memisahkan domain failures dari exception teknis.

import 'package:equatable/equatable.dart';

/// Base class untuk semua kegagalan (failures) di domain layer.
/// Gunakan ini sebagai return type untuk Either<Failure, T> di repository.
sealed class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Gagal karena tidak ada koneksi internet (F-53: connectivity_plus).
class NetworkFailure extends Failure {
  const NetworkFailure([
    super.message = 'Tidak ada koneksi internet. Coba lagi nanti.',
  ]);
}

/// Gagal operasi baca/tulis di Hive lokal (F-52: penyimpanan lokal penuh).
class LocalStorageFailure extends Failure {
  const LocalStorageFailure([
    super.message = 'Gagal menyimpan atau membaca data lokal.',
  ]);
}

/// Gagal operasi di MongoDB Atlas (F-40: submit, F-55: sync).
class CloudStorageFailure extends Failure {
  const CloudStorageFailure([
    super.message = 'Gagal sinkronisasi dengan server. Data disimpan lokal.',
  ]);
}

/// Gagal autentikasi — login/register (F-01 hingga F-03).
class AuthFailure extends Failure {
  const AuthFailure([
    super.message = 'Email atau password tidak valid.',
  ]);
}

/// Gagal validasi input dari pengguna.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Gagal saat parsing/deserialisasi data JSON cerita.
class SerializationFailure extends Failure {
  const SerializationFailure([
    super.message = 'Format data cerita tidak valid atau rusak.',
  ]);
}

/// Gagal karena resource tidak ditemukan (submission, halaman, blok).
class NotFoundFailure extends Failure {
  const NotFoundFailure([
    super.message = 'Data yang diminta tidak ditemukan.',
  ]);
}
