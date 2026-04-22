// lib/core/error/exceptions.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Custom exceptions yang dilempar di data layer, lalu di-catch dan dikonversi
// menjadi Failure di repository. Jangan biarkan exceptions menembus domain layer.

/// Exception untuk semua kegagalan operasi Hive lokal.
class LocalStorageException implements Exception {
  final String message;
  const LocalStorageException([
    this.message = 'Operasi penyimpanan lokal gagal.',
  ]);

  @override
  String toString() => 'LocalStorageException: $message';
}

/// Exception untuk kegagalan koneksi ke MongoDB Atlas.
class CloudStorageException implements Exception {
  final String message;
  final int? statusCode;

  const CloudStorageException({
    this.message = 'Koneksi ke server gagal.',
    this.statusCode,
  });

  @override
  String toString() =>
      'CloudStorageException(${statusCode ?? 'N/A'}): $message';
}

/// Exception untuk kegagalan autentikasi (login/register).
class AuthException implements Exception {
  final String message;
  const AuthException([this.message = 'Autentikasi gagal.']);

  @override
  String toString() => 'AuthException: $message';
}

/// Exception saat proses parsing JSON cerita gagal.
class SerializationException implements Exception {
  final String message;
  const SerializationException([
    this.message = 'Gagal memproses format data cerita.',
  ]);

  @override
  String toString() => 'SerializationException: $message';
}

/// Exception saat resource yang dicari tidak ada di database.
class NotFoundException implements Exception {
  final String message;
  const NotFoundException([this.message = 'Data tidak ditemukan.']);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception saat validasi input gagal sebelum operasi dilakukan.
class ValidationException implements Exception {
  final String message;
  const ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}
