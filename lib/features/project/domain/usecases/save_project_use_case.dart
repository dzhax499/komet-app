import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/project_model.dart';
import '../repositories/project_repository.dart';

class SaveProjectUseCase implements UseCase<ProjectModel, ProjectModel> {
  final ProjectRepository repository;

  SaveProjectUseCase(this.repository);

  @override
  KometResult<ProjectModel> call(ProjectModel params) {
    return repository.saveProject(params);
  }
}
