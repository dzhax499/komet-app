import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/database/mongo_service.dart';
import '../../../../core/models/project_model.dart';

abstract class ProjectRemoteDataSource {
  Future<ProjectModel> saveProject(ProjectModel project);
  Future<List<ProjectModel>> getProjectsByUser(String ownerId);
}

class ProjectRemoteDataSourceImpl implements ProjectRemoteDataSource {
  final MongoService mongoService;

  ProjectRemoteDataSourceImpl({required this.mongoService});

  @override
  Future<ProjectModel> saveProject(ProjectModel project) async {
    final collection = await mongoService.projectCollection;

    final map = project.toMap();
    
    if (project.mongoId != null) {
      await collection.updateOne(
        where.eq('_id', project.mongoId),
        { '\$set': map }
      );
    } else {
      final newMongoId = ObjectId().oid;
      map['_id'] = newMongoId;
      await collection.insertOne(map);
      return project.copyWith(mongoId: newMongoId, lastSyncedAt: DateTime.now());
    }

    return project.copyWith(lastSyncedAt: DateTime.now());
  }

  @override
  Future<List<ProjectModel>> getProjectsByUser(String ownerId) async {
    final collection = await mongoService.projectCollection;

    final result = await collection.find(
      where.eq('ownerId', ownerId).eq('deletedAt', null)
    ).toList();

    return result.map((map) => ProjectModel.fromMap(map)).toList();
  }
}
