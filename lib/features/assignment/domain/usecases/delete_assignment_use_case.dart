import '../../../../core/base/base_use_case.dart';
import '../repositories/assignment_repository.dart';

class DeleteAssignmentUseCase {
  final AssignmentRepository repository;

  DeleteAssignmentUseCase(this.repository);

  KometResult<void> call(String assignmentId) {
    return repository.deleteAssignment(assignmentId);
  }
}
