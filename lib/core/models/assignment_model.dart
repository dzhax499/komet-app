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

  @HiveField(9)
  final DateTime? deletedAt;

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
    this.deletedAt,
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
    DateTime? deletedAt,
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
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Konversi ke MongoDB Map 
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'classId': kelasId,
      'title': judul,
      'description': deskripsi,
      'deadline': deadline.toIso8601String(),
      'createdAt': dibuatPada.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  // Buat AssignmentModel dari data MongoDB
  factory AssignmentModel.fromMap(Map<String, dynamic> map) {
    return AssignmentModel(
      id: map['_id']?.toString() ?? '',
      kelasId: map['classId']?.toString() ?? '',
      judul: map['title'] ?? '',
      deskripsi: map['description'] ?? '',
      deadline: map['deadline'] != null
          ? DateTime.parse(map['deadline'].toString())
          : DateTime.now(),
      dibuatPada: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'].toString())
          : null,
      // Nilai default untuk field lokal
      guruId: '',
      nilaiMaksimal: 100,
      status: AssignmentStatus.aktif,
    );
  }
}
