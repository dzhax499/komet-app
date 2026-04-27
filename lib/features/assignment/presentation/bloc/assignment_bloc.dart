import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/create_assignment_use_case.dart';
import '../../domain/usecases/get_assignments_by_class_use_case.dart';
import 'assignment_event.dart';
import 'assignment_state.dart';

class AssignmentBloc extends Bloc<AssignmentEvent, AssignmentState> {
  final CreateAssignmentUseCase createAssignmentUseCase;
  final GetAssignmentsByClassUseCase getAssignmentsByClassUseCase;

  AssignmentBloc({
    required this.createAssignmentUseCase,
    required this.getAssignmentsByClassUseCase,
  }) : super(AssignmentInitial()) {
    on<CreateAssignmentEvent>(_onCreateAssignment);
    on<GetAssignmentsByClassEvent>(_onGetAssignmentsByClass);
  }

  Future<void> _onCreateAssignment(
    CreateAssignmentEvent event,
    Emitter<AssignmentState> emit,
  ) async {
    emit(AssignmentLoading());
    final result = await createAssignmentUseCase(event.assignment);
    
    if (result.failure != null) {
      emit(AssignmentFailure(result.failure!.message));
    } else {
      emit(AssignmentCreatedSuccess(result.data!));
    }
  }

  Future<void> _onGetAssignmentsByClass(
    GetAssignmentsByClassEvent event,
    Emitter<AssignmentState> emit,
  ) async {
    emit(AssignmentLoading());
    final result = await getAssignmentsByClassUseCase(event.kelasId);
    
    if (result.failure != null) {
      emit(AssignmentFailure(result.failure!.message));
    } else {
      emit(AssignmentSuccess(result.data ?? []));
    }
  }
}
