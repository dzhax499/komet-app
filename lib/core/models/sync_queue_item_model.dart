import 'package:hive/hive.dart';

part 'sync_queue_item_model.g.dart';

@HiveType(typeId: 9)
enum SyncDataType {
  @HiveField(0)
  submission,
  @HiveField(1)
  user,
  @HiveField(2)
  kelas
}

@HiveType(typeId: 10)
enum SyncOperation {
  @HiveField(0)
  create,
  @HiveField(1)
  update,
  @HiveField(2)
  delete
}

@HiveType(typeId: 11)
class SyncQueueItemModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final SyncDataType tipeData;

  @HiveField(2)
  final String referenceId;

  @HiveField(3)
  final String payload;

  @HiveField(4)
  final SyncOperation operasi;

  @HiveField(5)
  final DateTime dibuatPada;

  @HiveField(6)
  final int retriedCount;

  SyncQueueItemModel({
    required this.id,
    required this.tipeData,
    required this.referenceId,
    required this.payload,
    required this.operasi,
    required this.dibuatPada,
    this.retriedCount = 0,
  });
}
