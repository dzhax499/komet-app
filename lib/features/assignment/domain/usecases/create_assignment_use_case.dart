import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/assignment_model.dart';
import '../repositories/assignment_repository.dart';

class CreateAssignmentUseCase extends UseCase<AssignmentModel, AssignmentModel> {
  final AssignmentRepository repository;

  CreateAssignmentUseCase(this.repository);

  @override
  KometResult<AssignmentModel> call(AssignmentModel params) {
    return repository.createAssignment(params);
  }
}
