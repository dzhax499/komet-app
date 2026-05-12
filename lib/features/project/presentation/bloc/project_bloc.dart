import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/project_model.dart';
import '../../domain/usecases/save_project_use_case.dart';
import '../../domain/usecases/get_projects_by_user_use_case.dart';

// ── EVENTS ──────────────────────────────────────────────────────────────────
abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectFetchRequested extends ProjectEvent {
  final String ownerId;
  ProjectFetchRequested(this.ownerId);
  @override
  List<Object?> get props => [ownerId];
}

class ProjectCreateRequested extends ProjectEvent {
  final String title;
  final String ownerId;
  ProjectCreateRequested({required this.title, required this.ownerId});
  @override
  List<Object?> get props => [title, ownerId];
}

// ── STATES ──────────────────────────────────────────────────────────────────
abstract class ProjectState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProjectInitial extends ProjectState {}

class ProjectLoading extends ProjectState {}

class ProjectLoaded extends ProjectState {
  final List<ProjectModel> projects;
  ProjectLoaded(this.projects);
  @override
  List<Object?> get props => [projects];
}

class ProjectError extends ProjectState {
  final String message;
  ProjectError(this.message);
  @override
  List<Object?> get props => [message];
}

class ProjectActionSuccess extends ProjectState {
  final String message;
  ProjectActionSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// ── BLOC ────────────────────────────────────────────────────────────────────
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final SaveProjectUseCase saveProjectUseCase;
  final GetProjectsByUserUseCase getProjectsByUserUseCase;

  ProjectBloc({
    required this.saveProjectUseCase,
    required this.getProjectsByUserUseCase,
  }) : super(ProjectInitial()) {
    on<ProjectFetchRequested>(_onFetchProjects);
    on<ProjectCreateRequested>(_onCreateProject);
  }

  Future<void> _onFetchProjects(
    ProjectFetchRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    final result = await getProjectsByUserUseCase(event.ownerId);
    if (result.data != null) {
      // Urutkan dari yang terbaru diubah/dibuat
      final sortedProjects = List<ProjectModel>.from(result.data!)
        ..sort((a, b) => b.lastEditedAt.compareTo(a.lastEditedAt));
      emit(ProjectLoaded(sortedProjects));
    } else {
      emit(
        ProjectError(
          result.failure?.message ?? 'Gagal memuat daftar project',
        ),
      );
    }
  }

  Future<void> _onCreateProject(
    ProjectCreateRequested event,
    Emitter<ProjectState> emit,
  ) async {
    emit(ProjectLoading());
    final newProject = ProjectModel(
      id: '',
      ownerId: event.ownerId,
      title: event.title,
      projectData: '{}',
      lastEditedAt: DateTime.now(),
      createdAt: DateTime.now(),
    );

    final result = await saveProjectUseCase(newProject);
    if (result.data != null) {
      emit(ProjectActionSuccess('Project "${event.title}" berhasil dibuat'));
      add(ProjectFetchRequested(event.ownerId));
    } else {
      emit(ProjectError(result.failure?.message ?? 'Gagal membuat project'));
    }
  }
}
