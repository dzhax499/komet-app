import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/models/submission_model.dart';

abstract class SubmissionLocalDataSource {
  Future<SubmissionModel> saveSubmission(SubmissionModel submission);
  Future<List<SubmissionModel>> getSubmissionsByAssignment(String assignmentId);
  Future<List<SubmissionModel>> getSubmissionsByStudent(String studentId);
  Future<List<SubmissionModel>> getSubmissionsByClass(String classId);
  Future<SubmissionModel?> getSubmissionById(String submissionId);
}

class SubmissionLocalDataSourceImpl implements SubmissionLocalDataSource {
  final HiveService hiveService;

  SubmissionLocalDataSourceImpl({required this.hiveService});

  @override
  Future<SubmissionModel> saveSubmission(SubmissionModel submission) async {
    await hiveService.saveSubmission(submission);
    return submission;
  }

  @override
  Future<List<SubmissionModel>> getSubmissionsByAssignment(String assignmentId) async {
    return hiveService.getSubmissionsByAssignmentId(assignmentId);
  }

  @override
  Future<List<SubmissionModel>> getSubmissionsByStudent(String studentId) async {
    return hiveService.getSubmissionsByStudentId(studentId);
  }

  @override
  Future<List<SubmissionModel>> getSubmissionsByClass(String classId) async {
    return hiveService.getSubmissionsByClassId(classId);
  }

  @override
  Future<SubmissionModel?> getSubmissionById(String submissionId) async {
    return hiveService.getSubmissionById(submissionId);
  }
}
