import 'dart:math';
import 'package:uuid/uuid.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/kelas_model.dart';
import '../../../../core/models/user_model.dart';
import '../../domain/repositories/kelas_repository.dart';
import '../datasources/kelas_local_data_source.dart';
import '../datasources/kelas_remote_data_source.dart';

class KelasRepositoryImpl implements KelasRepository {
  final KelasLocalDataSource localDataSource;
  final KelasRemoteDataSource remoteDataSource;
  final Uuid uuid;

  KelasRepositoryImpl({
    required this.localDataSource, 
    required this.remoteDataSource,
    required this.uuid,
  });

  @override
  KometResult<KelasModel> createKelas(String nama, String guruId) async {
    try {
      String finalCode = _generateKodeKelas();
      bool isUnique = false;
      int attempts = 0;

      while (!isUnique && attempts < 5) {
        final available = await remoteDataSource.isKodeKelasAvailable(finalCode);
        if (available) {
          isUnique = true;
        } else {
          finalCode = _generateKodeKelas();
          attempts++;
        }
      }

      final kelas = KelasModel(
        id: uuid.v4(),
        nama: nama,
        guruId: guruId,
        kodeKelas: finalCode,
        siswaIds: [],
        assignmentIds: [],
        isAktif: true,
        dibuatPada: DateTime.now(),
      );
      
      // 1. Simpan ke server (MongoDB)
      final remoteKelas = await remoteDataSource.createKelas(kelas);
      
      // 2. Simpan ke lokal
      final result = await localDataSource.createKelas(remoteKelas);
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<void> deleteKelas(String kelasId) async {
    try {
      await remoteDataSource.deleteKelas(kelasId);
      await localDataSource.deleteKelas(kelasId);
      return kometSuccess(null);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<List<KelasModel>> getKelasGuru(String guruId) async {
    try {
      final remoteData = await remoteDataSource.getKelasGuru(guruId);
      for (final kelas in remoteData) {
        await localDataSource.createKelas(kelas); 
      }
      return kometSuccess(remoteData);
    } catch (e) {
      try {
        final localData = await localDataSource.getKelasGuru(guruId);
        return kometSuccess(localData);
      } catch (e2) {
        return kometFailure(LocalStorageFailure(e2.toString()));
      }
    }
  }


  @override
  KometResult<List<KelasModel>> getKelasSiswa(String siswaId) async {
    try {
      final remoteData = await remoteDataSource.getKelasSiswa(siswaId);
      for (final kelas in remoteData) {
        await localDataSource.createKelas(kelas);
      }
      return kometSuccess(remoteData);
    } catch (e) {
      try {
        final localData = await localDataSource.getKelasSiswa(siswaId);
        return kometSuccess(localData);
      } catch (e2) {
        return kometFailure(LocalStorageFailure(e2.toString()));
      }
    }
  }


  @override
  KometResult<List<UserModel>> getSiswaInKelas(String kelasId) async {
    try {
      final remoteData = await remoteDataSource.getSiswaInKelas(kelasId);
      return kometSuccess(remoteData);
    } catch (e) {
      try {
        final localData = await localDataSource.getSiswaInKelas(kelasId);
        return kometSuccess(localData);
      } catch (e2) {
        return kometFailure(LocalStorageFailure(e2.toString()));
      }
    }
  }


  @override
  KometResult<KelasModel> joinKelas(String kodeKelas, String siswaId) async {
    try {
      // Update di MongoDB
      final remoteKelas = await remoteDataSource.joinKelas(kodeKelas, siswaId);
      // Cache ke lokal
      await localDataSource.joinKelas(kodeKelas, siswaId);
      return kometSuccess(remoteKelas);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<KelasModel> getKelasById(String kelasId) async {
    try {
      final remoteData = await remoteDataSource.getKelasById(kelasId);
      await localDataSource.createKelas(remoteData);
      return kometSuccess(remoteData);
    } catch (e) {
      try {
        final localData = await localDataSource.getKelasById(kelasId);
        return kometSuccess(localData);
      } catch (e2) {
        return kometFailure(LocalStorageFailure(e2.toString()));
      }
    }
  }

  String _generateKodeKelas() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[Random().nextInt(chars.length)]).join();
  }
}