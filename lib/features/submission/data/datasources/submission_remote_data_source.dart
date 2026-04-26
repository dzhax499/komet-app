import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/database/mongo_service.dart';
import '../../../../core/models/submission_model.dart';

abstract class SubmissionRemoteDataSource {
  Future<SubmissionModel> saveSubmission(SubmissionModel submission);
  Future<List<SubmissionModel>> getSubmissionsByAssignment(String assignmentId);
  Future<List<SubmissionModel>> getSubmissionsByStudent(String studentId);
  Future<SubmissionModel> addFeedback(String submissionId, PageCommentModel feedback, SubmissionStatus newStatus);
  Future<List<SubmissionModel>> getSubmissionsByClass(String classId);
  Future<int> getReviewCount(List<String> assignmentIds);
}

class SubmissionRemoteDataSourceImpl implements SubmissionRemoteDataSource {
  final MongoService mongoService;

  SubmissionRemoteDataSourceImpl({required this.mongoService});

  @override
  Future<List<SubmissionModel>> getSubmissionsByClass(String classId) async {
    final submissionCollection = await mongoService.submissionCollection;
    final classCollection = await mongoService.classCollection;

    final kelas = await classCollection.findOne(where.eq('_id', classId));
    if (kelas == null) return [];

    final List<dynamic> assignmentIds = kelas['assignments'] ?? [];
    if (assignmentIds.isEmpty) return [];

    final result = await submissionCollection
        .find(
          where.oneFrom('assignmentId', assignmentIds).eq('deletedAt', null),
        )
        .toList();

    return result.map((map) => SubmissionModel.fromMap(map)).toList();
  }

  @override
  Future<SubmissionModel> saveSubmission(SubmissionModel submission) async {
    final collection = await mongoService.submissionCollection;
    final map = submission.toMap();

    await collection.updateOne(
      where.eq('_id', submission.id),
      {'\$set': map},
      upsert: true,
    );

    return submission;
  }

  @override
  Future<List<SubmissionModel>> getSubmissionsByAssignment(
    String assignmentId,
  ) async {
    final collection = await mongoService.submissionCollection;

    final result = await collection
        .find(
          where.eq('assignmentId', assignmentId).eq('deletedAt', null),
        )
        .toList();

    return result.map((map) => SubmissionModel.fromMap(map)).toList();
  }

  @override
  Future<List<SubmissionModel>> getSubmissionsByStudent(
    String studentId,
  ) async {
    final collection = await mongoService.submissionCollection;

    final result = await collection
        .find(
          where.eq('studentId', studentId).eq('deletedAt', null),
        )
        .toList();

    return result.map((map) => SubmissionModel.fromMap(map)).toList();
  }

  @override
  Future<SubmissionModel> addFeedback(
    String submissionId,
    PageCommentModel feedback,
    SubmissionStatus newStatus,
  ) async {
    final collection = await mongoService.submissionCollection;

    await collection.updateOne(
      where.eq('_id', submissionId),
      {
        '\$push': {
          'feedbackHistory': {
            'comment': feedback.komentar,
            'statusGiven': newStatus.name,
            'createdAt': feedback.dibuatPada.toIso8601String(),
          }
        },
        '\$set': {
          'status': newStatus.name,
          'updatedAt': DateTime.now().toIso8601String(),
        }
      },
    );

    final updatedMap = await collection.findOne(where.eq('_id', submissionId));
    if (updatedMap == null) {
      throw Exception('Submission tidak ditemukan setelah update');
    }
    return SubmissionModel.fromMap(updatedMap);
  }

  @override
  Future<int> getReviewCount(List<String> assignmentIds) async {
    if (assignmentIds.isEmpty) return 0;

    final collection = await mongoService.submissionCollection;

    final count = await collection.count(
      where
          .oneFrom('assignmentId', assignmentIds)
          .eq('status', 'submitted')
          .eq('deletedAt', null),
    );

    return count;
  }
}
