import 'package:hive/hive.dart';

part 'kelas_model.g.dart';

@HiveType(typeId: 1)
class KelasModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nama;

  @HiveField(2)
  final String guruId;

  @HiveField(3)
  final String kodeKelas;

  @HiveField(4)
  final List<String> siswaIds;

  @HiveField(5)
  final List<String> assignmentIds;

  @HiveField(6)
  final bool isAktif;

  @HiveField(7)
  final DateTime dibuatPada;

  @HiveField(8)
  final DateTime? deletedAt;

  KelasModel({
    required this.id,
    required this.nama,
    required this.guruId,
    required this.kodeKelas,
    required this.siswaIds,
    required this.assignmentIds,
    required this.isAktif,
    required this.dibuatPada,
    this.deletedAt,
  });

  KelasModel copyWith({
    String? id,
    String? nama,
    String? guruId,
    String? kodeKelas,
    List<String>? siswaIds,
    List<String>? assignmentIds,
    bool? isAktif,
    DateTime? dibuatPada,
    DateTime? deletedAt,
  }) {
    return KelasModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      guruId: guruId ?? this.guruId,
      kodeKelas: kodeKelas ?? this.kodeKelas,
      siswaIds: siswaIds ?? this.siswaIds,
      assignmentIds: assignmentIds ?? this.assignmentIds,
      isAktif: isAktif ?? this.isAktif,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Konversi ke MongoDB Map 
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'teacherId': guruId,
      'className': nama,
      'classCode': kodeKelas,
      'isOpen': isAktif,
      'students': siswaIds,
      'assignments': assignmentIds,
      'createdAt': dibuatPada.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  // Buat KelasModel dari data MongoDB 
  factory KelasModel.fromMap(Map<String, dynamic> map) {
    return KelasModel(
      id: map['_id']?.toString() ?? '',
      guruId: map['teacherId']?.toString() ?? '',
      nama: map['className'] ?? '',
      kodeKelas: map['classCode'] ?? '',
      isAktif: map['isOpen'] ?? true,
      siswaIds: List<String>.from(
        (map['students'] ?? []).map((e) => e.toString()),
      ),
      assignmentIds: List<String>.from(
        (map['assignments'] ?? []).map((e) => e.toString()),
      ),
      dibuatPada: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'].toString())
          : null,
    );
  }
}

