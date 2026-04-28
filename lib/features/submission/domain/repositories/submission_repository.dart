import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/submission_model.dart';

abstract class SubmissionRepository {

  KometResult<SubmissionModel> submitTask(SubmissionModel submission);

  KometResult<List<SubmissionModel>> getSubmissionsByAssignment(String assignmentId);

  KometResult<List<SubmissionModel>> getSubmissionsByStudent(String studentId);

  KometResult<SubmissionModel> gradeSubmission(String submissionId, int grade, String teacherComment, SubmissionStatus status);

  KometResult<SubmissionModel> addFeedback(String submissionId, PageCommentModel feedback, SubmissionStatus newStatus);

  KometResult<List<SubmissionModel>> getSubmissionsByClass(String classId);
  
  KometResult<int> getReviewCount(List<String> assignmentIds);
}
