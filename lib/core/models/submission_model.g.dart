// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PageCommentModelAdapter extends TypeAdapter<PageCommentModel> {
  @override
  final int typeId = 5;

  @override
  PageCommentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PageCommentModel(
      pageId: fields[0] as String,
      komentar: fields[1] as String,
      dibuatPada: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, PageCommentModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.pageId)
      ..writeByte(1)
      ..write(obj.komentar)
      ..writeByte(2)
      ..write(obj.dibuatPada);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageCommentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubmissionModelAdapter extends TypeAdapter<SubmissionModel> {
  @override
  final int typeId = 6;

  @override
  SubmissionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SubmissionModel(
      id: fields[0] as String,
      assignmentId: fields[1] as String,
      siswaId: fields[2] as String,
      storyDataJson: fields[3] as String,
      status: fields[4] as SubmissionStatus,
      sudahSync: fields[5] as bool,
      submittedAt: fields[6] as DateTime?,
      reviewedAt: fields[7] as DateTime?,
      updatedAt: fields[8] as DateTime,
      nilai: fields[9] as int?,
      komentarUmum: fields[10] as String?,
      komentarHalaman: (fields[11] as List).cast<PageCommentModel>(),
      revisiCount: fields[12] as int,
    );
  }

  @override
  void write(BinaryWriter writer, SubmissionModel obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.assignmentId)
      ..writeByte(2)
      ..write(obj.siswaId)
      ..writeByte(3)
      ..write(obj.storyDataJson)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.sudahSync)
      ..writeByte(6)
      ..write(obj.submittedAt)
      ..writeByte(7)
      ..write(obj.reviewedAt)
      ..writeByte(8)
      ..write(obj.updatedAt)
      ..writeByte(9)
      ..write(obj.nilai)
      ..writeByte(10)
      ..write(obj.komentarUmum)
      ..writeByte(11)
      ..write(obj.komentarHalaman)
      ..writeByte(12)
      ..write(obj.revisiCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SubmissionStatusAdapter extends TypeAdapter<SubmissionStatus> {
  @override
  final int typeId = 4;

  @override
  SubmissionStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SubmissionStatus.draft;
      case 1:
        return SubmissionStatus.submitted;
      case 2:
        return SubmissionStatus.reviewed;
      case 3:
        return SubmissionStatus.needsRevision;
      default:
        return SubmissionStatus.draft;
    }
  }

  @override
  void write(BinaryWriter writer, SubmissionStatus obj) {
    switch (obj) {
      case SubmissionStatus.draft:
        writer.writeByte(0);
        break;
      case SubmissionStatus.submitted:
        writer.writeByte(1);
        break;
      case SubmissionStatus.reviewed:
        writer.writeByte(2);
        break;
      case SubmissionStatus.needsRevision:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SubmissionStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
