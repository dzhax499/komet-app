import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/submission_model.dart';
import '../repositories/submission_repository.dart';

class GradeSubmissionParams {
  final String submissionId;
  final int grade;
  final String teacherComment;
  final SubmissionStatus status;

  GradeSubmissionParams({
    required this.submissionId,
    required this.grade,
    required this.teacherComment,
    required this.status,
  });
}

class GradeSubmissionUseCase extends UseCase<SubmissionModel, GradeSubmissionParams> {
  final SubmissionRepository repository;

  GradeSubmissionUseCase(this.repository);

  @override
  KometResult<SubmissionModel> call(GradeSubmissionParams params) {
    return repository.gradeSubmission(
      params.submissionId,
      params.grade,
      params.teacherComment,
      params.status,
    );
  }
}
