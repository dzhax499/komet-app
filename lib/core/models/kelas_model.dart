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

  KelasModel({
    required this.id,
    required this.nama,
    required this.guruId,
    required this.kodeKelas,
    required this.siswaIds,
    required this.assignmentIds,
    required this.isAktif,
    required this.dibuatPada,
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
    );
  }
}
