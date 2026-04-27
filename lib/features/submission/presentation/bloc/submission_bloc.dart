import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_submissions_by_assignment_use_case.dart';
import '../../domain/usecases/get_submissions_by_class_use_case.dart';
import '../../domain/usecases/get_review_count_use_case.dart';
import '../../domain/usecases/grade_submission_use_case.dart';
import 'submission_event.dart';
import 'submission_state.dart';

class SubmissionBloc extends Bloc<SubmissionEvent, SubmissionState> {
  final GetSubmissionsByAssignmentUseCase getSubmissionsByAssignmentUseCase;
  final GetSubmissionsByClassUseCase getSubmissionsByClassUseCase;
  final GetReviewCountUseCase getReviewCountUseCase;
  final GradeSubmissionUseCase gradeSubmissionUseCase;

  SubmissionBloc({
    required this.getSubmissionsByAssignmentUseCase,
    required this.getSubmissionsByClassUseCase,
    required this.getReviewCountUseCase,
    required this.gradeSubmissionUseCase,
  }) : super(SubmissionInitial()) {
    on<GetSubmissionsByAssignmentEvent>(_onGetSubmissionsByAssignment);
    on<GetSubmissionsByClassEvent>(_onGetSubmissionsByClass);
    on<GetReviewCountEvent>(_onGetReviewCount);
    on<GradeSubmissionEvent>(_onGradeSubmission);
  }

  Future<void> _onGetReviewCount(
    GetReviewCountEvent event,
    Emitter<SubmissionState> emit,
  ) async {
    final result = await getReviewCountUseCase(event.assignmentIds);
    if (result.data != null) {
      emit(SubmissionReviewCountLoaded(result.data!));
    }
  }

  Future<void> _onGetSubmissionsByAssignment(
    GetSubmissionsByAssignmentEvent event,
    Emitter<SubmissionState> emit,
  ) async {
    emit(SubmissionLoading());
    final result = await getSubmissionsByAssignmentUseCase(
      event.assignmentId,
    );

    if (result.failure != null) {
      emit(SubmissionFailure(result.failure!.message));
    } else {
      emit(SubmissionSuccess(result.data ?? []));
    }
  }

  Future<void> _onGetSubmissionsByClass(
    GetSubmissionsByClassEvent event,
    Emitter<SubmissionState> emit,
  ) async {
    emit(SubmissionLoading());
    final result = await getSubmissionsByClassUseCase(event.classId);

    if (result.failure != null) {
      emit(SubmissionFailure(result.failure!.message));
    } else {
      emit(SubmissionSuccess(result.data ?? []));
    }
  }

  Future<void> _onGradeSubmission(
    GradeSubmissionEvent event,
    Emitter<SubmissionState> emit,
  ) async {
    emit(SubmissionLoading());
    final result = await gradeSubmissionUseCase(
      GradeSubmissionParams(
        submissionId: event.submissionId,
        grade: event.grade,
        teacherComment: event.teacherComment,
      ),
    );

    if (result.failure != null) {
      emit(SubmissionFailure(result.failure!.message));
    } else {
      emit(SubmissionGradedSuccess(result.data!));
    }
  }
}
