// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'assignment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AssignmentModelAdapter extends TypeAdapter<AssignmentModel> {
  @override
  final int typeId = 3;

  @override
  AssignmentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AssignmentModel(
      id: fields[0] as String,
      judul: fields[1] as String,
      deskripsi: fields[2] as String,
      kelasId: fields[3] as String,
      guruId: fields[4] as String,
      deadline: fields[5] as DateTime,
      nilaiMaksimal: fields[6] as int,
      status: fields[7] as AssignmentStatus,
      dibuatPada: fields[8] as DateTime,
      deletedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, AssignmentModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.judul)
      ..writeByte(2)
      ..write(obj.deskripsi)
      ..writeByte(3)
      ..write(obj.kelasId)
      ..writeByte(4)
      ..write(obj.guruId)
      ..writeByte(5)
      ..write(obj.deadline)
      ..writeByte(6)
      ..write(obj.nilaiMaksimal)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.dibuatPada)
      ..writeByte(9)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AssignmentStatusAdapter extends TypeAdapter<AssignmentStatus> {
  @override
  final int typeId = 2;

  @override
  AssignmentStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AssignmentStatus.aktif;
      case 1:
        return AssignmentStatus.kadaluarsa;
      case 2:
        return AssignmentStatus.ditutup;
      default:
        return AssignmentStatus.aktif;
    }
  }

  @override
  void write(BinaryWriter writer, AssignmentStatus obj) {
    switch (obj) {
      case AssignmentStatus.aktif:
        writer.writeByte(0);
        break;
      case AssignmentStatus.kadaluarsa:
        writer.writeByte(1);
        break;
      case AssignmentStatus.ditutup:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AssignmentStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
