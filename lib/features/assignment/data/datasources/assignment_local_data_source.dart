import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/models/assignment_model.dart';

abstract class AssignmentLocalDataSource {
  Future<AssignmentModel> createAssignment(AssignmentModel assignment);
  Future<List<AssignmentModel>> getAssignmentsByClass(String kelasId);
  Future<void> deleteAssignment(String assignmentId);
}

class AssignmentLocalDataSourceImpl implements AssignmentLocalDataSource {
  final HiveService hiveService;

  AssignmentLocalDataSourceImpl({required this.hiveService});

  @override
  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    await hiveService.saveAssignment(assignment);
    return assignment;
  }

  @override
  Future<List<AssignmentModel>> getAssignmentsByClass(String kelasId) async {
    return hiveService.getAssignmentsByKelasId(kelasId);
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    await hiveService.deleteAssignment(assignmentId);
  }
}
