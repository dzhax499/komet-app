import '../../../../core/base/base_use_case.dart';
import '../repositories/submission_repository.dart';

class GetReviewCountUseCase extends UseCase<int, List<String>> {
  final SubmissionRepository repository;

  GetReviewCountUseCase(this.repository);

  @override
  KometResult<int> call(List<String> params) {
    return repository.getReviewCount(params);
  }
}
