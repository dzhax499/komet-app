// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kelas_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class KelasModelAdapter extends TypeAdapter<KelasModel> {
  @override
  final int typeId = 1;

  @override
  KelasModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return KelasModel(
      id: fields[0] as String,
      nama: fields[1] as String,
      guruId: fields[2] as String,
      kodeKelas: fields[3] as String,
      siswaIds: (fields[4] as List).cast<String>(),
      assignmentIds: (fields[5] as List).cast<String>(),
      isAktif: fields[6] as bool,
      dibuatPada: fields[7] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, KelasModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.nama)
      ..writeByte(2)
      ..write(obj.guruId)
      ..writeByte(3)
      ..write(obj.kodeKelas)
      ..writeByte(4)
      ..write(obj.siswaIds)
      ..writeByte(5)
      ..write(obj.assignmentIds)
      ..writeByte(6)
      ..write(obj.isAktif)
      ..writeByte(7)
      ..write(obj.dibuatPada);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KelasModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
