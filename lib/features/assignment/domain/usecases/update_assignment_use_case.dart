import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/assignment_model.dart';
import '../repositories/assignment_repository.dart';

class UpdateAssignmentUseCase {
  final AssignmentRepository repository;

  UpdateAssignmentUseCase(this.repository);

  KometResult<AssignmentModel> call(AssignmentModel assignment) {
    return repository.updateAssignment(assignment);
  }
}
