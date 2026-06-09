// lib/features/editor_engine/presentation/bloc/editor_bloc.dart
// PIC D — Dzakir Tsabit Asy Syafiq

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import '../../../../core/di/service_locator.dart';
import '../../../../core/local_storage/hive_service.dart';
import '../../../../core/models/project_model.dart';
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
  final bool isGuest;

  EditorLoadRequested(
    this.submissionId, {
    this.assignmentId = '',
    this.namaPenulis = '',
    this.isGuest = false,
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

    // Load dari Hive dulu
    try {
      final savedProject = sl<HiveService>().getProjectById(event.submissionId);
      if (savedProject != null) {
        final Map<String, dynamic> data = jsonDecode(savedProject.projectData);
        final List<PageModel> pages = (data['pages'] as List).map((p) {
          return PageModel(
            id: p['id'],
            judul: p['judul'],
            tipe: PageTipe.values.firstWhere(
              (e) => e.name == p['tipe'],
              orElse: () => PageTipe.normal,
            ),
            blocks: (p['blocks'] as List).map((b) => BlockData.fromJson(b)).toList(),
            connections: Map<String, String>.from(p['connections'] ?? {}),
          );
        }).toList();

        final projectData = StoryProjectData(
          id: data['id'],
          assignmentId: data['assignmentId'] ?? '',
          judulCerita: data['judulCerita'] ?? 'Untitled Story',
          namaPenulis: data['namaPenulis'] ?? '',
          halamanPembuka: data['halamanPembuka'] ?? pages.first.id,
          pages: pages,
          variabelKarakter: Map<String, int>.from(data['variabelKarakter'] ?? {}),
          createdAt: savedProject.createdAt,
          updatedAt: savedProject.lastEditedAt,
        );

        emit(EditorLoaded(
          project: projectData,
          activePageId: projectData.halamanPembuka,
        ));
        return;
      }
    } catch (e) {
      debugPrint('EditorBloc: Failed to load project from Hive: $e');
    }

    // Kalau tidak ada atau gagal load, buat baru
    final now = DateTime.now();
    final openingPageId = _uuid.v4();

    final halamanPembuka = PageModel(
      id: openingPageId,
      judul: 'Opening Page',
      tipe: PageTipe.pembuka,
      blocks: const [],
      connections: const {},
    );

    final initialProject = StoryProjectData(
      id: event.submissionId,
      assignmentId: event.assignmentId,
      judulCerita: 'Untitled Story',
      namaPenulis: event.isGuest ? 'guest' : event.namaPenulis,
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
      judul: 'Page ${curr.project.pages.length + 1}',
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
    if (state is! EditorLoaded) return;
    final curr = state as EditorLoaded;
    try {
      final projectDataJson = jsonEncode({
        'id': curr.project.id,
        'assignmentId': curr.project.assignmentId,
        'judulCerita': curr.project.judulCerita,
        'namaPenulis': curr.project.namaPenulis,
        'halamanPembuka': curr.project.halamanPembuka,
        'pages': curr.project.pages.map((p) => {
          'id': p.id,
          'judul': p.judul,
          'tipe': p.tipe.name,
          'blocks': p.blocks.map((b) => b.toJson()).toList(),
          'connections': p.connections,
        }).toList(),
        'variabelKarakter': curr.project.variabelKarakter,
      });
      
      final projectModel = ProjectModel(
        id: curr.project.id,
        ownerId: curr.project.namaPenulis,
        title: curr.project.judulCerita,
        projectData: projectDataJson,
        lastEditedAt: DateTime.now(),
        createdAt: curr.project.createdAt,
      );
      await sl<HiveService>().saveProject(projectModel);
      debugPrint('EditorBloc: Project saved to Hive');
    } catch (e) {
      debugPrint('EditorBloc: Failed to save project: $e');
    }
  }
}