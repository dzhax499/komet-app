import 'package:uuid/uuid.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/project_model.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/project_local_data_source.dart';
import '../datasources/project_remote_data_source.dart';

class ProjectRepositoryImpl implements ProjectRepository {
  final ProjectLocalDataSource localDataSource;
  final ProjectRemoteDataSource remoteDataSource;
  final Uuid uuid;

  ProjectRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.uuid,
  });

  @override
  KometResult<ProjectModel> saveProject(ProjectModel project) async {
    try {
      final modelToSave = project.id.isEmpty
          ? project.copyWith(
              id: uuid.v4(),
              createdAt: DateTime.now(),
              lastEditedAt: DateTime.now(),
            )
          : project.copyWith(
              lastEditedAt: DateTime.now(),
            );

      final localResult = await localDataSource.saveProject(modelToSave);

      try {
        final remoteResult = await remoteDataSource.saveProject(localResult);
        final syncedLocalResult =
            await localDataSource.saveProject(remoteResult);
        return kometSuccess(syncedLocalResult);
      } catch (_) {
        return kometSuccess(localResult);
      }
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<ProjectModel> syncProject(String projectId) async {
    try {
      final localProject = await localDataSource.getProjectById(projectId);
      if (localProject == null) {
        throw Exception("Project tidak ditemukan di lokal");
      }

      final remoteResult = await remoteDataSource.saveProject(localProject);
      final finalResult = await localDataSource.saveProject(remoteResult);

      return kometSuccess(finalResult);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<List<ProjectModel>> getProjectsByUser(String ownerId) async {
    try {
      final remoteData = await remoteDataSource.getProjectsByUser(ownerId);
      for (final proj in remoteData) {
        await localDataSource.saveProject(proj);
      }
      return kometSuccess(remoteData);
    } catch (e) {
      try {
        final localData = await localDataSource.getProjectsByUser(ownerId);
        return kometSuccess(localData);
      } catch (e2) {
        return kometFailure(LocalStorageFailure(e2.toString()));
      }
    }
  }

  @override
  KometResult<ProjectModel?> getProjectById(String projectId) async {
    try {
      final localData = await localDataSource.getProjectById(projectId);
      return kometSuccess<ProjectModel?>(localData);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }
}
