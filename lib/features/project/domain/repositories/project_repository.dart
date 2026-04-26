import '../../../../core/base/base_use_case.dart';
import '../../../../core/models/project_model.dart';

abstract class ProjectRepository {

  KometResult<ProjectModel> saveProject(ProjectModel project);

  KometResult<List<ProjectModel>> getProjectsByUser(String ownerId);

  KometResult<ProjectModel?> getProjectById(String projectId);

  KometResult<ProjectModel> syncProject(String projectId);
}
