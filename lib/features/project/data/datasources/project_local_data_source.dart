import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/models/project_model.dart';

abstract class ProjectLocalDataSource {
  Future<ProjectModel> saveProject(ProjectModel project);
  Future<List<ProjectModel>> getProjectsByUser(String ownerId);
  Future<ProjectModel?> getProjectById(String projectId);
}

class ProjectLocalDataSourceImpl implements ProjectLocalDataSource {
  final HiveService hiveService;

  ProjectLocalDataSourceImpl({required this.hiveService});

  @override
  Future<ProjectModel> saveProject(ProjectModel project) async {
    await hiveService.saveProject(project);
    return project;
  }

  @override
  Future<List<ProjectModel>> getProjectsByUser(String ownerId) async {
    return hiveService.getProjectsByOwnerId(ownerId);
  }

  @override
  Future<ProjectModel?> getProjectById(String projectId) async {
    return hiveService.getProjectById(projectId);
  }
}
