import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/assignment_model.dart';

abstract class AssignmentRepository {

  KometResult<AssignmentModel> createAssignment(AssignmentModel assignment);

  KometResult<List<AssignmentModel>> getAssignmentsByClass(String kelasId);

  KometResult<void> deleteAssignment(String assignmentId);
}
