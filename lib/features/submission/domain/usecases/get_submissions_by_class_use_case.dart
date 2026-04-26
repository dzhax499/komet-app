import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/submission_model.dart';
import '../repositories/submission_repository.dart';

class GetSubmissionsByClassUseCase extends UseCase<List<SubmissionModel>, String> {
  final SubmissionRepository repository;

  GetSubmissionsByClassUseCase(this.repository);

  @override
  KometResult<List<SubmissionModel>> call(String params) {
    return repository.getSubmissionsByClass(params);
  }
}
