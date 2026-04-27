import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/assignment_model.dart';
import '../repositories/assignment_repository.dart';

class GetAssignmentsByClassUseCase extends UseCase<List<AssignmentModel>, String> {
  final AssignmentRepository repository;

  GetAssignmentsByClassUseCase(this.repository);

  @override
  KometResult<List<AssignmentModel>> call(String params) {
    return repository.getAssignmentsByClass(params);
  }
}
