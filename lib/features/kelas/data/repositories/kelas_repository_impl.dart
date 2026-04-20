import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/kelas_model.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/repositories/kelas_repository.dart';
import '../datasources/kelas_local_data_source.dart';

class KelasRepositoryImpl implements KelasRepository {
  final KelasLocalDataSource localDataSource;
  final Uuid uuid;

  KelasRepositoryImpl({required this.localDataSource, required this.uuid});

  @override
  KometResult<KelasModel> createKelas(String nama, String guruId) async {
    try {
      final kelas = KelasModel(
        id: uuid.v4(),
        nama: nama,
        guruId: guruId,
        kodeKelas: _generateKodeKelas(),
        siswaIds: [],
        assignmentIds: [],
        isAktif: true,
        dibuatPada: DateTime.now(),
      );
      final result = await localDataSource.createKelas(kelas);
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(CacheFailure(message: e.toString()));
    }
  }

  @override
  KometResult<void> deleteKelas(String kelasId) async {
    try {
      await localDataSource.deleteKelas(kelasId);
      return kometSuccess(null);
    } catch (e) {
      return kometFailure(CacheFailure(message: e.toString()));
    }
  }

  @override
  KometResult<List<KelasModel>> getKelasGuru(String guruId) async {
    try {
      final result = await localDataSource.getKelasGuru(guruId);
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(CacheFailure(message: e.toString()));
    }
  }

  @override
  KometResult<List<KelasModel>> getKelasSiswa(String siswaId) async {
    try {
      final result = await localDataSource.getKelasSiswa(siswaId);
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(CacheFailure(message: e.toString()));
    }
  }

  @override
  KometResult<List<UserModel>> getSiswaInKelas(String kelasId) async {
    try {
      final result = await localDataSource.getSiswaInKelas(kelasId);
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(CacheFailure(message: e.toString()));
    }
  }

  @override
  KometResult<KelasModel> joinKelas(String kodeKelas, String siswaId) async {
    try {
      final result = await localDataSource.joinKelas(kodeKelas, siswaId);
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(CacheFailure(message: e.toString()));
    }
  }

  String _generateKodeKelas() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }
}
