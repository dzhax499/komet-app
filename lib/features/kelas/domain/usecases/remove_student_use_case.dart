import '../../../../core/base/base_use_case.dart';
import '../repositories/kelas_repository.dart';

class RemoveStudentParams {
  final String kelasId;
  final String siswaId;
  RemoveStudentParams({required this.kelasId, required this.siswaId});
}

class RemoveStudentUseCase implements UseCase<void, RemoveStudentParams> {
  final KelasRepository repository;
  RemoveStudentUseCase(this.repository);

  @override
  KometResult<void> call(RemoveStudentParams params) {
    return repository.removeStudent(params.kelasId, params.siswaId);
  }
}
