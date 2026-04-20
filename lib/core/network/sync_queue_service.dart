import 'dart:async';
import 'dart:convert';
import '../local_storage/hive_service.dart';
import '../models/sync_queue_item_model.dart';
import 'connectivity_service.dart';

/// Kontrak untuk pengiriman data ke server.
/// Akan diimplementasikan oleh PIC B/C untuk koneksi MongoDB.
abstract class RemoteSyncDataSource {
  Future<bool> syncItem(SyncQueueItemModel item);
}

/// Service untuk mengelola sinkronisasi data secara offline-first.
/// PIC D: Fondasi sistem sinkronisasi.
class SyncQueueService {
  final HiveService hiveService;
  final ConnectivityService connectivityService;
  final RemoteSyncDataSource? remoteDataSource; // Opsional sampai PIC B selesai

  bool _isSyncing = false;

  SyncQueueService({
    required this.hiveService,
    required this.connectivityService,
    this.remoteDataSource,
  });

  /// Inisialisasi monitoring koneksi untuk trigger sync otomatis.
  void init() {
    connectivityService.statusStream.listen((status) {
      if (status == ConnectivityStatus.connected) {
        syncAll();
      }
    });
  }

  /// Menambahkan item baru ke antrean sinkronisasi.
  Future<void> enqueue(SyncQueueItemModel item) async {
    await hiveService.addSyncItem(item);
    // Coba sync langsung jika online
    if (await connectivityService.isConnected) {
      syncAll();
    }
  }

  /// Memproses semua item dalam antrean.
  Future<void> syncAll() async {
    if (_isSyncing || remoteDataSource == null) return;
    
    final queue = hiveService.getSyncQueue();
    if (queue.isEmpty) return;

    _isSyncing = true;
    print('SyncQueue: Memulai sinkronisasi ${queue.length} item...');

    for (final item in queue) {
      // Cek koneksi di setiap iterasi
      if (!(await connectivityService.isConnected)) break;

      try {
        final success = await remoteDataSource!.syncItem(item);
        if (success) {
          await hiveService.removeSyncItem(item.id);
          print('SyncQueue: Berhasil sinkronisasi item ${item.id}');
        } else {
          // TODO: Handle max retries (F-54)
          print('SyncQueue: Gagal sinkronisasi item ${item.id}, akan dicoba lagi nanti');
        }
      } catch (e) {
        print('SyncQueue: Error saat sinkronisasi ${item.id}: $e');
      }
    }

    _isSyncing = false;
    print('SyncQueue: Sinkronisasi selesai.');
  }
}
