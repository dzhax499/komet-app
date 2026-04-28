import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/get_submissions_by_assignment_use_case.dart';
import '../../domain/usecases/get_submissions_by_class_use_case.dart';
import '../../domain/usecases/get_review_count_use_case.dart';
import '../../domain/usecases/grade_submission_use_case.dart';
import '../../domain/usecases/get_submissions_by_student_use_case.dart';
import '../../domain/usecases/submit_task_use_case.dart';
import 'submission_event.dart';
import 'submission_state.dart';

class SubmissionBloc extends Bloc<SubmissionEvent, SubmissionState> {
  final GetSubmissionsByAssignmentUseCase getSubmissionsByAssignmentUseCase;
  final GetSubmissionsByClassUseCase getSubmissionsByClassUseCase;
  final GetReviewCountUseCase getReviewCountUseCase;
  final GradeSubmissionUseCase gradeSubmissionUseCase;
  final GetSubmissionsByStudentUseCase getSubmissionsByStudentUseCase;
  final SubmitTaskUseCase submitTaskUseCase;

  SubmissionBloc({
    required this.getSubmissionsByAssignmentUseCase,
    required this.getSubmissionsByClassUseCase,
    required this.getReviewCountUseCase,
    required this.gradeSubmissionUseCase,
    required this.getSubmissionsByStudentUseCase,
    required this.submitTaskUseCase,
  }) : super(SubmissionInitial()) {
    on<GetSubmissionsByAssignmentEvent>(_onGetSubmissionsByAssignment);
    on<GetSubmissionsByClassEvent>(_onGetSubmissionsByClass);
    on<GetReviewCountEvent>(_onGetReviewCount);
    on<GradeSubmissionEvent>(_onGradeSubmission);
    on<GetSubmissionsByStudentEvent>(_onGetSubmissionsByStudent);
    on<SubmitTaskEvent>(_onSubmitTask);
    on<LoadExistingSubmissionEvent>(_onLoadExisting);
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
        status: event.status,
      ),
    );

    if (result.failure != null) {
      emit(SubmissionFailure(result.failure!.message));
    } else {
      emit(SubmissionGradedSuccess(result.data!));
    }
  }

  Future<void> _onGetSubmissionsByStudent(
    GetSubmissionsByStudentEvent event,
    Emitter<SubmissionState> emit,
  ) async {
    emit(SubmissionLoading());
    final result = await getSubmissionsByStudentUseCase(event.studentId);

    if (result.failure != null) {
      emit(SubmissionFailure(result.failure!.message));
    } else {
      emit(SubmissionSuccess(result.data ?? []));
    }
  }

  Future<void> _onSubmitTask(
    SubmitTaskEvent event,
    Emitter<SubmissionState> emit,
  ) async {
    emit(SubmissionLoading());
    final result = await submitTaskUseCase(event.submission);

    if (result.failure != null) {
      emit(SubmissionFailure(result.failure!.message));
    } else {
      emit(SubmissionSaved(result.data!));
    }
  }

  Future<void> _onLoadExisting(
    LoadExistingSubmissionEvent event,
    Emitter<SubmissionState> emit,
  ) async {
    emit(SubmissionLoading());
    final result = await getSubmissionsByStudentUseCase(event.studentId);

    if (result.failure != null) {
      emit(SubmissionFailure(result.failure!.message));
    } else {
      final submissions = result.data ?? [];
      try {
        final existing = submissions.firstWhere(
          (s) => s.assignmentId == event.assignmentId,
        );
        emit(ExistingSubmissionLoaded(existing));
      } catch (_) {
        // Not found, do nothing, just empty canvas
      }
    }
  }
}
