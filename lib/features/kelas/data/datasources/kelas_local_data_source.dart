import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/models/kelas_model.dart';

abstract class KelasLocalDataSource {
  Future<KelasModel> createKelas(KelasModel kelas);
  Future<List<KelasModel>> getKelasGuru(String guruId);
  Future<List<KelasModel>> getKelasSiswa(String siswaId);
  Future<KelasModel> joinKelas(String kodeKelas, String siswaId);
  Future<KelasModel> getKelasById(String kelasId);
  Future<KelasModel> updateKelas(KelasModel kelas);
  Future<void> deleteKelas(String kelasId);
  Future<void> removeStudent(String kelasId, String siswaId);
  Future<void> leaveKelas(String kelasId, String siswaId);
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

    if (!kelas.siswaIds.contains(siswaId)) {
      final updatedSiswaIds = List<String>.from(kelas.siswaIds)..add(siswaId);
      final updatedKelas = kelas.copyWith(siswaIds: updatedSiswaIds);
      await hiveService.saveKelas(updatedKelas);
    }

    // Update user juga (selalu cek agar lokal sinkron)
    final user = hiveService.getCurrentUser();
    if (user != null && user.id == siswaId) {
      if (!user.kelasIds.contains(kelas.id)) {
        final updatedKelasIds = List<String>.from(user.kelasIds)..add(kelas.id);
        await hiveService.saveUser(user.copyWith(kelasIds: updatedKelasIds));
      }
    }

    return hiveService.getKelasById(kelas.id) ?? kelas;
  }

  @override
  Future<KelasModel> updateKelas(KelasModel kelas) async {
    await hiveService.saveKelas(kelas);
    return kelas;
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
  Future<void> removeStudent(String kelasId, String siswaId) async {
    final kelas = hiveService.getKelasById(kelasId);
    if (kelas != null) {
      final updatedSiswaIds = List<String>.from(kelas.siswaIds)..remove(siswaId);
      await hiveService.saveKelas(kelas.copyWith(siswaIds: updatedSiswaIds));
    }
  }

  @override
  Future<void> leaveKelas(String kelasId, String siswaId) async {
    // 1. Hapus kelas dari daftar kelas lokal
    await hiveService.deleteKelas(kelasId);

    // 2. Update user lokal agar kelasIds-nya berkurang
    final user = hiveService.getCurrentUser();
    if (user != null && user.id == siswaId) {
      final updatedKelasIds = List<String>.from(user.kelasIds)..remove(kelasId);
      await hiveService.saveUser(user.copyWith(kelasIds: updatedKelasIds));
    }
  }

  @override
  Future<List<UserModel>> getSiswaInKelas(String kelasId) async {
    final kelas = hiveService.getKelasById(kelasId);
    if (kelas == null) return [];
    return hiveService.getUsersByIds(kelas.siswaIds);
  }
}