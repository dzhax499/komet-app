import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/database/mongo_service.dart';
import '../../../../core/models/assignment_model.dart';

abstract class AssignmentRemoteDataSource {
  Future<AssignmentModel> createAssignment(AssignmentModel assignment);
  Future<List<AssignmentModel>> getAssignmentsByClass(String kelasId);
  Future<void> deleteAssignment(String assignmentId);
}

class AssignmentRemoteDataSourceImpl implements AssignmentRemoteDataSource {
  final MongoService mongoService;

  AssignmentRemoteDataSourceImpl({required this.mongoService});

  @override
  Future<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    final assignmentCol = await mongoService.assignmentCollection;
    final classCol = await mongoService.classCollection;

    await assignmentCol.insertOne(assignment.toMap());

    await classCol.updateOne(
      where.eq('_id', assignment.kelasId),
      modify.push('assignments', assignment.id)
    );
    
    return assignment;
  }

  @override
  Future<List<AssignmentModel>> getAssignmentsByClass(String kelasId) async {
    final collection = await mongoService.assignmentCollection;

    final result = await collection.find(
      where.eq('classId', kelasId).eq('deletedAt', null)
    ).toList();

    return result.map((map) => AssignmentModel.fromMap(map)).toList();
  }

  @override
  Future<void> deleteAssignment(String assignmentId) async {
    final collection = await mongoService.assignmentCollection;

    await collection.updateOne(
      where.eq('_id', assignmentId),
      modify.set('deletedAt', DateTime.now().toIso8601String())
    );
  }
}
