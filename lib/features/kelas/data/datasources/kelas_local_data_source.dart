import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/kelas_model.dart';

abstract class KelasLocalDataSource {
  Future<KelasModel> createKelas(KelasModel kelas);
  Future<List<KelasModel>> getKelasGuru(String guruId);
  Future<List<KelasModel>> getKelasSiswa(String siswaId);
  Future<KelasModel> joinKelas(String kodeKelas, String siswaId);
  Future<KelasModel> getKelasById(String kelasId);
  Future<void> deleteKelas(String kelasId);
  Future<List<UserModel>> getSiswaInKelas(String kelasId);
}

class KelasLocalDataSourceImpl implements KelasLocalDataSource {
  final HiveService hiveService;

  KelasLocalDataSourceImpl({required this.hiveService});

  @override
  Future<KelasModel> createKelas(KelasModel kelas) async {
    await hiveService.saveKelas(kelas);
    return kelas;
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
  Future<KelasModel> joinKelas(String kodeKelas, String siswaId) async {
    final kelas = hiveService.getKelasByKode(kodeKelas);
    if (kelas == null) {
      throw Exception('Kode kelas tidak ditemukan');
    }

    if (kelas.siswaIds.contains(siswaId)) {
      return kelas;
    }

    final updatedSiswaIds = List<String>.from(kelas.siswaIds)..add(siswaId);
    final updatedKelas = kelas.copyWith(siswaIds: updatedSiswaIds);
    await hiveService.saveKelas(updatedKelas);

    // Update user juga
    final user = hiveService.getCurrentUser();
    if (user != null && user.id == siswaId) {
      final updatedKelasIds = List<String>.from(user.kelasIds)..add(kelas.id);
      await hiveService.saveUser(user.copyWith(kelasIds: updatedKelasIds));
    }

    return updatedKelas;
  }

  @override
  Future<void> deleteKelas(String kelasId) async {
    await hiveService.deleteKelas(kelasId);
  }

  @override
  Future<KelasModel> getKelasById(String kelasId) async {
    final kelas = hiveService.getKelasById(kelasId);
    if (kelas == null) throw Exception('Kelas tidak ditemukan di lokal');
    return kelas;
  }

  @override
  Future<List<UserModel>> getSiswaInKelas(String kelasId) async {
    final kelas = hiveService.getKelasById(kelasId);
    if (kelas == null) return [];
    return hiveService.getUsersByIds(kelas.siswaIds);
  }
}