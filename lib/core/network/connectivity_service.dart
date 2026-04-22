// lib/core/network/connectivity_service.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Interface dan implementasi ConnectivityService menggunakan connectivity_plus.
//
// PENTING untuk PIC B (sync/):
// - Import interface ini di sync repository Anda
// - GetIt: sl<ConnectivityService>() untuk mendapatkan instance
// - Gunakan [statusStream] untuk memantau perubahan koneksi real-time (F-53)
// - Gunakan [isConnected] untuk cek satu kali sebelum operasi sync (F-40, F-54)

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ABSTRACT INTERFACE (Domain layer — jangan ubah tanpa koordinasi PIC D)
// ─────────────────────────────────────────────────────────────────────────────

/// Kontrak untuk layanan pengecekan koneksi internet.
/// Digunakan oleh:
/// - PIC D: Editor Canvas (cek sebelum auto-save ke cloud)
/// - PIC B: Sync Manager (F-53, F-54, F-56)
abstract class ConnectivityService {
  /// Stream yang memancarkan [ConnectivityStatus] setiap kali status berubah.
  /// PIC B: Subscribe stream ini di sync_manager untuk trigger sinkronisasi otomatis.
  Stream<ConnectivityStatus> get statusStream;

  /// Cek status koneksi satu kali (non-reactive).
  Future<bool> get isConnected;

  /// Status koneksi saat ini secara sinkron (gunakan hati-hati, cache saja).
  ConnectivityStatus get currentStatus;

  /// Mulai monitoring koneksi. Panggil saat app startup.
  void startMonitoring();

  /// Hentikan monitoring untuk menghemat resource.
  void stopMonitoring();
}

// ─────────────────────────────────────────────────────────────────────────────
// ENUM STATUS
// ─────────────────────────────────────────────────────────────────────────────

enum ConnectivityStatus {
  /// Terhubung ke internet (wifi atau mobile data).
  connected,

  /// Tidak ada koneksi internet.
  disconnected,

  /// Status belum diketahui (sebelum cek pertama dilakukan).
  unknown,
}

// ─────────────────────────────────────────────────────────────────────────────
// IMPLEMENTASI (Data layer — menggunakan connectivity_plus)
// ─────────────────────────────────────────────────────────────────────────────

/// Implementasi konkret [ConnectivityService] menggunakan package connectivity_plus.
/// Didaftarkan di ServiceLocator sebagai singleton.
class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;
  final _statusController = StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityStatus _currentStatus = ConnectivityStatus.unknown;

  ConnectivityServiceImpl({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  @override
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  @override
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return _resultsToStatus(results) == ConnectivityStatus.connected;
  }

  @override
  ConnectivityStatus get currentStatus => _currentStatus;

  @override
  void startMonitoring() {
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final status = _resultsToStatus(results);
        if (status != _currentStatus) {
          _currentStatus = status;
          _statusController.add(status);
        }
      },
    );
    // Cek status awal saat monitoring dimulai
    _connectivity.checkConnectivity().then((results) {
      _currentStatus = _resultsToStatus(results);
      _statusController.add(_currentStatus);
    });
  }

  @override
  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Konversi List<ConnectivityResult> connectivity_plus ke [ConnectivityStatus].
  ConnectivityStatus _resultsToStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      return ConnectivityStatus.disconnected;
    }
    return ConnectivityStatus.connected;
  }

  /// Dispose saat widget/service dihancurkan.
  void dispose() {
    stopMonitoring();
    _statusController.close();
  }
}
