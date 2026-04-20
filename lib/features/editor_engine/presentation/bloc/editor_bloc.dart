import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/story_project_data.dart';
import '../../domain/entities/page_model.dart';
import '../../domain/entities/block_data.dart';

// ── EVENTS ──────────────────────────────────────────────────────────────────
abstract class EditorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditorLoadRequested extends EditorEvent {
  final String submissionId;
  EditorLoadRequested(this.submissionId);
  @override
  List<Object?> get props => [submissionId];
}

class EditorPageAdded extends EditorEvent {}

class EditorBlockAdded extends EditorEvent {
  final String pageId;
  final BlockData block;
  EditorBlockAdded({required this.pageId, required this.block});
  @override
  List<Object?> get props => [pageId, block];
}

class EditorSaveRequested extends EditorEvent {}

// ── STATES ──────────────────────────────────────────────────────────────────
abstract class EditorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditorInitial extends EditorState {}
class EditorLoading extends EditorState {}
class EditorLoaded extends EditorState {
  final StoryProjectData project;
  final String? activePageId;

  EditorLoaded({required this.project, this.activePageId});

  @override
  List<Object?> get props => [project, activePageId];
}
class EditorError extends EditorState {
  final String message;
  EditorError(this.message);
}

// ── BLOC ────────────────────────────────────────────────────────────────────
class EditorBloc extends Bloc<EditorEvent, EditorState> {
  EditorBloc() : super(EditorInitial()) {
    on<EditorLoadRequested>(_onLoad);
    on<EditorPageAdded>(_onPageAdded);
    on<EditorBlockAdded>(_onBlockAdded);
    on<EditorSaveRequested>(_onSave);
  }

  Future<void> _onLoad(EditorLoadRequested event, Emitter<EditorState> emit) async {
    emit(EditorLoading());
    // TODO: Load from Hive/Local Storage
    // Simulasi data baru
    final initialProject = StoryProjectData(
      id: event.submissionId,
      title: 'Cerita Tanpa Judul',
      pages: [],
      variables: {},
      lastModified: DateTime.now(),
    );
    emit(EditorLoaded(project: initialProject));
  }

  void _onPageAdded(EditorPageAdded event, Emitter<EditorState> emit) {
    if (state is EditorLoaded) {
      final curr = state as EditorLoaded;
      final newPage = PageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: 'Halaman ${curr.project.pages.length + 1}',
        blocks: [],
      );
      final updatedProject = curr.project.copyWith(
        pages: [...curr.project.pages, newPage],
      );
      emit(EditorLoaded(project: updatedProject, activePageId: newPage.id));
    }
  }

  void _onBlockAdded(EditorBlockAdded event, Emitter<EditorState> emit) {
    // Logic penambahan blok
  }

  Future<void> _onSave(EditorSaveRequested event, Emitter<EditorState> emit) async {
    // Logic simpan ke Hive
  }
}
