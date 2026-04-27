import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/kelas_model.dart';
import '../repositories/kelas_repository.dart';

class GetKelasByIdUseCase extends UseCase<KelasModel, String> {
  final KelasRepository repository;

  GetKelasByIdUseCase(this.repository);

  @override
  KometResult<KelasModel> call(String params) {
    return repository.getKelasById(params);
  }
}
