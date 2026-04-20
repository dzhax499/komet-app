// lib/features/editor_engine/presentation/bloc/editor_bloc.dart
// PIC D — Dzakir Tsabit Asy Syafiq

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/story_project_data.dart';
import '../../domain/entities/page_model.dart';
import '../../domain/entities/block_data.dart';

// ── EVENTS ───────────────────────────────────────────────────────────────────
abstract class EditorEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditorLoadRequested extends EditorEvent {
  final String submissionId;
  final String assignmentId;
  final String namaPenulis;

  EditorLoadRequested(
    this.submissionId, {
    this.assignmentId = '',
    this.namaPenulis = '',
  });

  @override
  List<Object?> get props => [submissionId, assignmentId, namaPenulis];
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

// ── STATES ───────────────────────────────────────────────────────────────────
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
  @override
  List<Object?> get props => [message];
}

// ── BLOC ─────────────────────────────────────────────────────────────────────
class EditorBloc extends Bloc<EditorEvent, EditorState> {
  final _uuid = const Uuid();

  EditorBloc() : super(EditorInitial()) {
    on<EditorLoadRequested>(_onLoad);
    on<EditorPageAdded>(_onPageAdded);
    on<EditorBlockAdded>(_onBlockAdded);
    on<EditorSaveRequested>(_onSave);
  }

  Future<void> _onLoad(EditorLoadRequested event, Emitter<EditorState> emit) async {
    emit(EditorLoading());

    // TODO: coba load dari Hive dulu, kalau tidak ada buat baru
    final now = DateTime.now();
    final openingPageId = _uuid.v4();

    // FIX: constructor PageModel sesuai entity
    // required: id, judul, tipe, blocks, connections
    final halamanPembuka = PageModel(
      id: openingPageId,
      judul: 'Halaman Pembuka',
      tipe: PageTipe.pembuka,
      blocks: const [],
      connections: const {},
    );

    // FIX: constructor StoryProjectData sesuai entity
    // required: id, assignmentId, judulCerita, namaPenulis,
    //           halamanPembuka, pages, variabelKarakter, createdAt, updatedAt
    final initialProject = StoryProjectData(
      id: event.submissionId,
      assignmentId: event.assignmentId,
      judulCerita: 'Cerita Tanpa Judul',
      namaPenulis: event.namaPenulis,
      halamanPembuka: openingPageId,
      pages: [halamanPembuka],
      variabelKarakter: const {},
      createdAt: now,
      updatedAt: now,
    );

    emit(EditorLoaded(
      project: initialProject,
      activePageId: openingPageId,
    ));
  }

  void _onPageAdded(EditorPageAdded event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final curr = state as EditorLoaded;

    final newPage = PageModel(
      id: _uuid.v4(),
      judul: 'Halaman ${curr.project.pages.length + 1}',
      tipe: PageTipe.normal,
      blocks: const [],
      connections: const {},
    );

    emit(EditorLoaded(
      project: curr.project.copyWith(
        pages: [...curr.project.pages, newPage],
        updatedAt: DateTime.now(),
      ),
      activePageId: newPage.id,
    ));
  }

  void _onBlockAdded(EditorBlockAdded event, Emitter<EditorState> emit) {
    if (state is! EditorLoaded) return;
    final curr = state as EditorLoaded;

    final updatedPages = curr.project.pages.map((page) {
      if (page.id != event.pageId) return page;
      return page.copyWith(blocks: [...page.blocks, event.block]);
    }).toList();

    emit(EditorLoaded(
      project: curr.project.copyWith(
        pages: updatedPages,
        updatedAt: DateTime.now(),
      ),
      activePageId: curr.activePageId,
    ));
  }

  Future<void> _onSave(EditorSaveRequested event, Emitter<EditorState> emit) async {
    // TODO: simpan ke Hive
  }
}