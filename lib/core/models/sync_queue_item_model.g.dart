// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_queue_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SyncQueueItemModelAdapter extends TypeAdapter<SyncQueueItemModel> {
  @override
  final int typeId = 11;

  @override
  SyncQueueItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SyncQueueItemModel(
      id: fields[0] as String,
      tipeData: fields[1] as SyncDataType,
      referenceId: fields[2] as String,
      payload: fields[3] as String,
      operasi: fields[4] as SyncOperation,
      dibuatPada: fields[5] as DateTime,
      retriedCount: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SyncQueueItemModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tipeData)
      ..writeByte(2)
      ..write(obj.referenceId)
      ..writeByte(3)
      ..write(obj.payload)
      ..writeByte(4)
      ..write(obj.operasi)
      ..writeByte(5)
      ..write(obj.dibuatPada)
      ..writeByte(6)
      ..write(obj.retriedCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncQueueItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncDataTypeAdapter extends TypeAdapter<SyncDataType> {
  @override
  final int typeId = 9;

  @override
  SyncDataType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncDataType.submission;
      case 1:
        return SyncDataType.user;
      case 2:
        return SyncDataType.kelas;
      default:
        return SyncDataType.submission;
    }
  }

  @override
  void write(BinaryWriter writer, SyncDataType obj) {
    switch (obj) {
      case SyncDataType.submission:
        writer.writeByte(0);
        break;
      case SyncDataType.user:
        writer.writeByte(1);
        break;
      case SyncDataType.kelas:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncDataTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncOperationAdapter extends TypeAdapter<SyncOperation> {
  @override
  final int typeId = 10;

  @override
  SyncOperation read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncOperation.create;
      case 1:
        return SyncOperation.update;
      case 2:
        return SyncOperation.delete;
      default:
        return SyncOperation.create;
    }
  }

  @override
  void write(BinaryWriter writer, SyncOperation obj) {
    switch (obj) {
      case SyncOperation.create:
        writer.writeByte(0);
        break;
      case SyncOperation.update:
        writer.writeByte(1);
        break;
      case SyncOperation.delete:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
