import 'dart:async';
// FIX: Hapus unused import dart:convert
import '../local_storage/hive_service.dart';
import '../models/sync_queue_item_model.dart';
import 'connectivity_service.dart';
import 'package:flutter/foundation.dart'; // untuk debugPrint

/// Kontrak untuk pengiriman data ke server.
/// Akan diimplementasikan oleh PIC B/C untuk koneksi MongoDB.
abstract class RemoteSyncDataSource {
  Future<bool> syncItem(SyncQueueItemModel item);
}

/// Service untuk mengelola sinkronisasi data secara offline-first.
class SyncQueueService {
  final HiveService hiveService;
  final ConnectivityService connectivityService;
  final RemoteSyncDataSource? remoteDataSource;

  bool _isSyncing = false;

  SyncQueueService({
    required this.hiveService,
    required this.connectivityService,
    this.remoteDataSource,
  });

  void init() {
    connectivityService.statusStream.listen((status) {
      if (status == ConnectivityStatus.connected) {
        syncAll();
      }
    });
  }

  Future<void> enqueue(SyncQueueItemModel item) async {
    await hiveService.addSyncItem(item);
    if (await connectivityService.isConnected) {
      syncAll();
    }
  }

  Future<void> syncAll() async {
    if (_isSyncing || remoteDataSource == null) return;

    final queue = hiveService.getSyncQueue();
    if (queue.isEmpty) return;

    _isSyncing = true;
    // FIX: print → debugPrint (tidak muncul di production release)
    debugPrint('SyncQueue: Memulai sinkronisasi ${queue.length} item...');

    for (final item in queue) {
      if (!(await connectivityService.isConnected)) break;

      try {
        final success = await remoteDataSource!.syncItem(item);
        if (success) {
          await hiveService.removeSyncItem(item.id);
          debugPrint('SyncQueue: Berhasil sinkronisasi item ${item.id}');
        } else {
          debugPrint('SyncQueue: Gagal sinkronisasi item ${item.id}, akan dicoba lagi nanti');
        }
      } catch (e) {
        debugPrint('SyncQueue: Error saat sinkronisasi ${item.id}: $e');
      }
    }

    _isSyncing = false;
    debugPrint('SyncQueue: Sinkronisasi selesai.');
  }
}