import 'package:hive/hive.dart';

part 'notification_model.g.dart';

@HiveType(typeId: 7)
enum NotificationType {
  @HiveField(0)
  submissionBaru,
  @HiveField(1)
  hasilPenilaian,
  @HiveField(2)
  pengingatDeadline
}

@HiveType(typeId: 8)
class NotificationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final NotificationType tipe;

  @HiveField(3)
  final String judul;

  @HiveField(4)
  final String pesan;

  @HiveField(5)
  final String referenceId;

  @HiveField(6)
  final bool sudahDibaca;

  @HiveField(7)
  final DateTime dibuatPada;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.tipe,
    required this.judul,
    required this.pesan,
    required this.referenceId,
    required this.sudahDibaca,
    required this.dibuatPada,
  });

  NotificationModel copyWith({
    String? id,
    String? userId,
    NotificationType? tipe,
    String? judul,
    String? pesan,
    String? referenceId,
    bool? sudahDibaca,
    DateTime? dibuatPada,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tipe: tipe ?? this.tipe,
      judul: judul ?? this.judul,
      pesan: pesan ?? this.pesan,
      referenceId: referenceId ?? this.referenceId,
      sudahDibaca: sudahDibaca ?? this.sudahDibaca,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }
}
