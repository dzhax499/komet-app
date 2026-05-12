import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/models/assignment_model.dart';

abstract class AssignmentLocalDataSource {
  Future<AssignmentModel> createAssignment(AssignmentModel assignment);
  Future<List<AssignmentModel>> getAssignmentsByClass(String kelasId);
  Future<void> deleteAssignment(String assignmentId);
  Future<AssignmentModel> updateAssignment(AssignmentModel assignment);
}

class AssignmentLocalDataSourceImpl implements AssignmentLocalDataSource {
  final HiveService hiveService;

  AssignmentLocalDataSourceImpl({required this.hiveService});

  @override
  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    await hiveService.assignmentBoxInstance.put(assignment.id, assignment);
    return assignment;
  }

  @override
  Future<List<AssignmentModel>> getAssignmentsByClass(String kelasId) async {
    final result = hiveService.assignmentBoxInstance.values
        .where((a) => a.kelasId == kelasId && a.deletedAt == null)
        .toList();
    return result;
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    final assignment = hiveService.assignmentBoxInstance.get(assignmentId);
    if (assignment != null) {
      final updated = assignment.copyWith(deletedAt: DateTime.now());
      await hiveService.assignmentBoxInstance.put(assignmentId, updated);
    }
  }

  @override
  Future<AssignmentModel> updateAssignment(AssignmentModel assignment) async {
    await hiveService.assignmentBoxInstance.put(assignment.id, assignment);
    return assignment;
  }
}
