import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/kelas_model.dart';
import '../repositories/kelas_repository.dart';

class UpdateKelasParams {
  final String kelasId;
  final String newNama;
  UpdateKelasParams({required this.kelasId, required this.newNama});
}

class UpdateKelasUseCase implements UseCase<KelasModel, UpdateKelasParams> {
  final KelasRepository repository;
  UpdateKelasUseCase(this.repository);

  @override
  KometResult<KelasModel> call(UpdateKelasParams params) {
    return repository.updateKelas(params.kelasId, params.newNama);
  }
}
