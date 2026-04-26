// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'project_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProjectModelAdapter extends TypeAdapter<ProjectModel> {
  @override
  final int typeId = 12;

  @override
  ProjectModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProjectModel(
      id: fields[0] as String,
      mongoId: fields[1] as String?,
      ownerId: fields[2] as String,
      title: fields[3] as String,
      projectData: fields[4] as String,
      isSubmitted: fields[5] as bool,
      lastEditedAt: fields[6] as DateTime,
      createdAt: fields[7] as DateTime,
      lastSyncedAt: fields[8] as DateTime?,
      deletedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ProjectModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.mongoId)
      ..writeByte(2)
      ..write(obj.ownerId)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.projectData)
      ..writeByte(5)
      ..write(obj.isSubmitted)
      ..writeByte(6)
      ..write(obj.lastEditedAt)
      ..writeByte(7)
      ..write(obj.createdAt)
      ..writeByte(8)
      ..write(obj.lastSyncedAt)
      ..writeByte(9)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
