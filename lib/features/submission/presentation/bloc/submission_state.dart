import 'package:equatable/equatable.dart';
import '../../../../core/models/submission_model.dart';

abstract class SubmissionState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SubmissionInitial extends SubmissionState {}

class SubmissionLoading extends SubmissionState {}

class SubmissionSuccess extends SubmissionState {
  final List<SubmissionModel> submissions;
  SubmissionSuccess(this.submissions);
  @override
  List<Object?> get props => [submissions];
}

class SubmissionGradedSuccess extends SubmissionState {
  final SubmissionModel submission;
  SubmissionGradedSuccess(this.submission);
  @override
  List<Object?> get props => [submission];
}

class SubmissionFailure extends SubmissionState {
  final String message;
  SubmissionFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class SubmissionReviewCountLoaded extends SubmissionState {
  final int count;
  SubmissionReviewCountLoaded(this.count);
  @override
  List<Object?> get props => [count];
}

class SubmissionSaved extends SubmissionState {
  final SubmissionModel submission;
  SubmissionSaved(this.submission);
  @override
  List<Object?> get props => [submission];
}

class ExistingSubmissionLoaded extends SubmissionState {
  final SubmissionModel submission;
  ExistingSubmissionLoaded(this.submission);
  @override
  List<Object?> get props => [submission];
}
