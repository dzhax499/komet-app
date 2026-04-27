import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/kelas_model.dart';
import '../../../../core/models/user_model.dart';
import '../repositories/kelas_repository.dart';

class CreateKelasParams {
  final String nama;
  final String guruId;
  CreateKelasParams({required this.nama, required this.guruId});
}

class CreateKelasUseCase implements UseCase<KelasModel, CreateKelasParams> {
  final KelasRepository repository;
  CreateKelasUseCase(this.repository);

  @override
  KometResult<KelasModel> call(CreateKelasParams params) {
    return repository.createKelas(params.nama, params.guruId);
  }
}

class GetKelasGuruUseCase implements UseCase<List<KelasModel>, String> {
  final KelasRepository repository;
  GetKelasGuruUseCase(this.repository);

  @override
  KometResult<List<KelasModel>> call(String guruId) {
    return repository.getKelasGuru(guruId);
  }
}

class GetKelasSiswaUseCase implements UseCase<List<KelasModel>, String> {
  final KelasRepository repository;
  GetKelasSiswaUseCase(this.repository);

  @override
  KometResult<List<KelasModel>> call(String siswaId) {
    return repository.getKelasSiswa(siswaId);
  }
}

class JoinKelasParams {
  final String kodeKelas;
  final String siswaId;
  JoinKelasParams({required this.kodeKelas, required this.siswaId});
}

class JoinKelasUseCase implements UseCase<KelasModel, JoinKelasParams> {
  final KelasRepository repository;
  JoinKelasUseCase(this.repository);

  @override
  KometResult<KelasModel> call(JoinKelasParams params) {
    return repository.joinKelas(params.kodeKelas, params.siswaId);
  }
}

class DeleteKelasUseCase implements UseCase<void, String> {
  final KelasRepository repository;
  DeleteKelasUseCase(this.repository);

  @override
  KometResult<void> call(String kelasId) {
    return repository.deleteKelas(kelasId);
  }
}

class GetSiswaInKelasUseCase implements UseCase<List<UserModel>, String> {
  final KelasRepository repository;
  GetSiswaInKelasUseCase(this.repository);

  @override
  KometResult<List<UserModel>> call(String kelasId) {
    return repository.getSiswaInKelas(kelasId);
  }
}

class LeaveKelasParams {
  final String kelasId;
  final String siswaId;
  LeaveKelasParams({required this.kelasId, required this.siswaId});
}

class LeaveKelasUseCase implements UseCase<void, LeaveKelasParams> {
  final KelasRepository repository;
  LeaveKelasUseCase(this.repository);

  @override
  KometResult<void> call(LeaveKelasParams params) {
    return repository.leaveKelas(params.kelasId, params.siswaId);
  }
}
