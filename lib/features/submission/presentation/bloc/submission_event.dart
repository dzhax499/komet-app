import 'package:equatable/equatable.dart';
import '../../../../core/models/submission_model.dart';
abstract class SubmissionEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class GetSubmissionsByAssignmentEvent extends SubmissionEvent {
  final String assignmentId;
  GetSubmissionsByAssignmentEvent(this.assignmentId);
  @override
  List<Object?> get props => [assignmentId];
}

class GradeSubmissionEvent extends SubmissionEvent {
  final String submissionId;
  final int grade;
  final String teacherComment;
  final SubmissionStatus status;

  GradeSubmissionEvent({
    required this.submissionId,
    required this.grade,
    required this.teacherComment,
    required this.status,
  });

  @override
  List<Object?> get props => [submissionId, grade, teacherComment, status];
}

class GetSubmissionsByClassEvent extends SubmissionEvent {
  final String classId;
  GetSubmissionsByClassEvent(this.classId);
  @override
  List<Object?> get props => [classId];
}

class GetReviewCountEvent extends SubmissionEvent {
  final List<String> assignmentIds;
  GetReviewCountEvent(this.assignmentIds);
  @override
  List<Object?> get props => [assignmentIds];
}

class GetSubmissionsByStudentEvent extends SubmissionEvent {
  final String studentId;
  GetSubmissionsByStudentEvent(this.studentId);
  @override
  List<Object?> get props => [studentId];
}

class SubmitTaskEvent extends SubmissionEvent {
  final SubmissionModel submission;
  SubmitTaskEvent(this.submission);
  @override
  List<Object?> get props => [submission];
}

class LoadExistingSubmissionEvent extends SubmissionEvent {
  final String assignmentId;
  final String studentId;
  LoadExistingSubmissionEvent({required this.assignmentId, required this.studentId});
  @override
  List<Object?> get props => [assignmentId, studentId];
}
