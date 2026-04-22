import 'package:hive/hive.dart';

part 'assignment_model.g.dart';

@HiveType(typeId: 2)
enum AssignmentStatus {
  @HiveField(0)
  aktif,
  @HiveField(1)
  kadaluarsa,
  @HiveField(2)
  ditutup
}

@HiveType(typeId: 3)
class AssignmentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String judul;

  @HiveField(2)
  final String deskripsi;

  @HiveField(3)
  final String kelasId;

  @HiveField(4)
  final String guruId;

  @HiveField(5)
  final DateTime deadline;

  @HiveField(6)
  final int nilaiMaksimal;

  @HiveField(7)
  final AssignmentStatus status;

  @HiveField(8)
  final DateTime dibuatPada;

  AssignmentModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.kelasId,
    required this.guruId,
    required this.deadline,
    required this.nilaiMaksimal,
    required this.status,
    required this.dibuatPada,
  });

  AssignmentModel copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    String? kelasId,
    String? guruId,
    DateTime? deadline,
    int? nilaiMaksimal,
    AssignmentStatus? status,
    DateTime? dibuatPada,
  }) {
    return AssignmentModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      kelasId: kelasId ?? this.kelasId,
      guruId: guruId ?? this.guruId,
      deadline: deadline ?? this.deadline,
      nilaiMaksimal: nilaiMaksimal ?? this.nilaiMaksimal,
      status: status ?? this.status,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }
}
