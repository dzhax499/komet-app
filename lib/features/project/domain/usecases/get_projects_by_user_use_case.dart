import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/project_model.dart';
import '../repositories/project_repository.dart';

class GetProjectsByUserUseCase implements UseCase<List<ProjectModel>, String> {
  final ProjectRepository repository;

  GetProjectsByUserUseCase(this.repository);

  @override
  KometResult<List<ProjectModel>> call(String ownerId) {
    return repository.getProjectsByUser(ownerId);
  }
}
