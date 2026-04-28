import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/submission_model.dart';
import '../repositories/submission_repository.dart';

class SubmitTaskUseCase implements UseCase<SubmissionModel, SubmissionModel> {
  final SubmissionRepository repository;

  SubmitTaskUseCase(this.repository);

  @override
  KometResult<SubmissionModel> call(SubmissionModel params) async {
    return await repository.submitTask(params);
  }
}
