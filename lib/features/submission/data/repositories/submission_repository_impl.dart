import 'package:uuid/uuid.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/submission_model.dart';
import '../../domain/repositories/submission_repository.dart';
import '../datasources/submission_local_data_source.dart';
import '../datasources/submission_remote_data_source.dart';

class SubmissionRepositoryImpl implements SubmissionRepository {
  final SubmissionLocalDataSource localDataSource;
  final SubmissionRemoteDataSource remoteDataSource;
  final Uuid uuid;

  SubmissionRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.uuid,
  });

  @override
  KometResult<SubmissionModel> submitTask(SubmissionModel submission) async {
    try {
      final modelToSave = submission.id.isEmpty
          ? submission.copyWith(
              id: uuid.v4(),
              submittedAt: DateTime.now(),
            )
          : submission.copyWith(
              updatedAt: DateTime.now(),
            );

      final remoteResult = await remoteDataSource.saveSubmission(modelToSave);
      final localResult = await localDataSource.saveSubmission(remoteResult);

      return kometSuccess(localResult);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<List<SubmissionModel>> getSubmissionsByAssignment(
    String assignmentId,
  ) async {
    try {
      final remoteData = await remoteDataSource.getSubmissionsByAssignment(
        assignmentId,
      );
      for (final sub in remoteData) {
        await localDataSource.saveSubmission(sub);
      }
      return kometSuccess(remoteData);
    } catch (e) {
      try {
        final localData = await localDataSource.getSubmissionsByAssignment(
          assignmentId,
        );
        return kometSuccess(localData);
      } catch (e2) {
        return kometFailure(LocalStorageFailure(e2.toString()));
      }
    }
  }

  @override
  KometResult<List<SubmissionModel>> getSubmissionsByStudent(
    String studentId,
  ) async {
    try {
      final remoteData = await remoteDataSource.getSubmissionsByStudent(
        studentId,
      );
      for (final sub in remoteData) {
        await localDataSource.saveSubmission(sub);
      }
      return kometSuccess(remoteData);
    } catch (e) {
      try {
        final localData = await localDataSource.getSubmissionsByStudent(
          studentId,
        );
        return kometSuccess(localData);
      } catch (e2) {
        return kometFailure(LocalStorageFailure(e2.toString()));
      }
    }
  }

  @override
  KometResult<SubmissionModel> gradeSubmission(
    String submissionId,
    int grade,
    String teacherComment,
  ) async {
    try {
      final localSub = await localDataSource.getSubmissionById(submissionId);
      if (localSub == null) {
        throw Exception("Submission tidak ditemukan di lokal");
      }

      final updatedSub = localSub.copyWith(
        nilai: grade,
        komentarUmum: teacherComment,
        status: SubmissionStatus.reviewed,
        updatedAt: DateTime.now(),
      );

      final remoteResult = await remoteDataSource.saveSubmission(updatedSub);
      final finalResult = await localDataSource.saveSubmission(remoteResult);

      return kometSuccess(finalResult);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<SubmissionModel> addFeedback(
    String submissionId,
    PageCommentModel feedback,
    SubmissionStatus newStatus,
  ) async {
    try {
      final localSub = await localDataSource.getSubmissionById(submissionId);
      if (localSub == null) {
        throw Exception("Submission tidak ditemukan di lokal");
      }

      final updatedComments = List<PageCommentModel>.from(
        localSub.komentarHalaman,
      )..add(feedback);

      final updatedSub = localSub.copyWith(
        komentarHalaman: updatedComments,
        status: newStatus,
        updatedAt: DateTime.now(),
      );

      final remoteResult = await remoteDataSource.saveSubmission(updatedSub);
      final finalResult = await localDataSource.saveSubmission(remoteResult);

      return kometSuccess(finalResult);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<List<SubmissionModel>> getSubmissionsByClass(
    String classId,
  ) async {
    try {
      final remoteData = await remoteDataSource.getSubmissionsByClass(classId);
      for (final sub in remoteData) {
        await localDataSource.saveSubmission(sub);
      }
      return kometSuccess(remoteData);
    } catch (e) {
      try {
        final localData = await localDataSource.getSubmissionsByClass(classId);
        return kometSuccess(localData);
      } catch (e2) {
        return kometFailure(LocalStorageFailure(e2.toString()));
      }
    }
  }

  @override
  KometResult<int> getReviewCount(List<String> assignmentIds) async {
    try {
      final count = await remoteDataSource.getReviewCount(assignmentIds);
      return kometSuccess(count);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }
}
