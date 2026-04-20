import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/models/kelas_model.dart';
import '../../../../core/models/user_model.dart';
import 'package:hive/hive.dart';

abstract class KelasLocalDataSource {
  Future<KelasModel> createKelas(KelasModel kelas);
  Future<List<KelasModel>> getKelasGuru(String guruId);
  Future<List<KelasModel>> getKelasSiswa(String siswaId);
  Future<KelasModel> joinKelas(String kodeKelas, String siswaId);
  Future<void> deleteKelas(String kelasId);
  Future<List<UserModel>> getSiswaInKelas(String kelasId);
}

class KelasLocalDataSourceImpl implements KelasLocalDataSource {
  final HiveService hiveService;

  KelasLocalDataSourceImpl({required this.hiveService});

  @override
  Future<KelasModel> createKelas(KelasModel kelas) async {
    await Hive.box<KelasModel>(HiveService.kelasBox).put(kelas.id, kelas);
    return kelas;
  }

  @override
  Future<void> deleteKelas(String kelasId) async {
    await Hive.box<KelasModel>(HiveService.kelasBox).delete(kelasId);
  }

  @override
  Future<List<KelasModel>> getKelasGuru(String guruId) async {
    return hiveService.getKelasByGuruId(guruId);
  }

  @override
  Future<List<KelasModel>> getKelasSiswa(String siswaId) async {
    return hiveService.getKelasBySiswaId(siswaId);
  }

  @override
  Future<List<UserModel>> getSiswaInKelas(String kelasId) async {
    final kelas = Hive.box<KelasModel>(HiveService.kelasBox).get(kelasId);
    if (kelas == null) return [];
    
    final userBox = Hive.box<UserModel>(HiveService.userBox);
    return kelas.siswaIds.map((id) => userBox.get(id)).whereType<UserModel>().toList();
  }

  @override
  Future<KelasModel> joinKelas(String kodeKelas, String siswaId) async {
    final kelas = hiveService.getKelasByKode(kodeKelas);
    if (kelas == null) throw Exception('Kode kelas tidak valid');
    
    if (kelas.siswaIds.contains(siswaId)) {
      return kelas; // Sudah join
    }

    final updatedSiswaIds = List<String>.from(kelas.siswaIds)..add(siswaId);
    final updatedKelas = kelas.copyWith(siswaIds: updatedSiswaIds);
    
    await Hive.box<KelasModel>(HiveService.kelasBox).put(kelas.id, updatedKelas);
    
    // Update user's kelasIds
    final userBox = Hive.box<UserModel>(HiveService.userBox);
    final user = userBox.get(siswaId);
    if (user != null) {
      final updatedUserKelasIds = List<String>.from(user.kelasIds)..add(kelas.id);
      await userBox.put(user.id, user.copyWith(kelasIds: updatedUserKelasIds));
    }

    return updatedKelas;
  }
}
