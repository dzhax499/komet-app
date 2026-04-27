import 'package:equatable/equatable.dart';

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

  GradeSubmissionEvent({
    required this.submissionId,
    required this.grade,
    required this.teacherComment,
  });

  @override
  List<Object?> get props => [submissionId, grade, teacherComment];
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
