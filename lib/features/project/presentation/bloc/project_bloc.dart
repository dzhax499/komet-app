import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/models/project_model.dart';
import '../../domain/repositories/project_repository.dart';

abstract class ProjectEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchProjects extends ProjectEvent {
  final String ownerId;
  FetchProjects(this.ownerId);

  @override
  List<Object?> get props => [ownerId];
}

class CreateProject extends ProjectEvent {
  final String title;
  final String ownerId;
  CreateProject(this.title, this.ownerId);

  @override
  List<Object?> get props => [title, ownerId];
}

class SyncProject extends ProjectEvent {
  final String projectId;
  SyncProject(this.projectId);

  @override
  List<Object?> get props => [projectId];
}

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

class ProjectCreatedSuccess extends ProjectState {
  final String projectId;
  ProjectCreatedSuccess(this.projectId);
  @override
  List<Object?> get props => [projectId];
}

class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  final ProjectRepository repository;

  ProjectBloc({required this.repository}) : super(ProjectInitial()) {
    on<FetchProjects>(_onFetchProjects);
    on<CreateProject>(_onCreateProject);
    on<SyncProject>(_onSyncProject);
  }

  Future<void> _onFetchProjects(FetchProjects event, Emitter<ProjectState> emit) async {
    emit(ProjectLoading());
    final result = await repository.getProjectsByUser(event.ownerId);
    if (result.data != null) {
      emit(ProjectLoaded(result.data!));
    } else {
      emit(ProjectError(result.failure?.message ?? 'Gagal memuat project'));
    }
  }

  Future<void> _onCreateProject(CreateProject event, Emitter<ProjectState> emit) async {
    final currentState = state;
    emit(ProjectLoading());
    
    final newProject = ProjectModel(
      id: '', // Will be generated in repository
      ownerId: event.ownerId,
      title: event.title,
      projectData: '{}',
      createdAt: DateTime.now(),
      lastEditedAt: DateTime.now(),
      isSubmitted: false,
    );

    final result = await repository.saveProject(newProject);
    if (result.data != null) {
      emit(ProjectCreatedSuccess(result.data!.id));
      add(FetchProjects(event.ownerId));
    } else {
      emit(ProjectError(result.failure?.message ?? 'Gagal membuat project'));
      if (currentState is ProjectLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onSyncProject(SyncProject event, Emitter<ProjectState> emit) async {
    final currentState = state;
    emit(ProjectLoading());
    final result = await repository.syncProject(event.projectId);
    if (result.data != null) {
      emit(ProjectActionSuccess('Project berhasil disinkronisasi'));
      // If we need to refetch, we would need ownerId, but let's assume it's updated.
      if (currentState is ProjectLoaded) {
        final updatedList = currentState.projects.map((p) => p.id == result.data!.id ? result.data! : p).toList();
        emit(ProjectLoaded(updatedList));
      }
    } else {
      emit(ProjectError(result.failure?.message ?? 'Gagal sinkronisasi'));
      if (currentState is ProjectLoaded) {
        emit(currentState);
      }
    }
  }
}
