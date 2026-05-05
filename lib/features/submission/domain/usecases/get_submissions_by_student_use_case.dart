import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/submission_model.dart';
import '../repositories/submission_repository.dart';

class GetSubmissionsByStudentUseCase
    implements UseCase<List<SubmissionModel>, String> {
  final SubmissionRepository repository;

  GetSubmissionsByStudentUseCase(this.repository);

  @override
  KometResult<List<SubmissionModel>> call(String studentId) {
    return repository.getSubmissionsByStudent(studentId);
  }
}
