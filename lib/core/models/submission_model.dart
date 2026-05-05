import 'package:hive/hive.dart';

part 'submission_model.g.dart';

@HiveType(typeId: 4)
enum SubmissionStatus {
  @HiveField(0)
  draft,
  @HiveField(1)
  submitted,
  @HiveField(2)
  reviewed,
  @HiveField(3)
  needsRevision
}

@HiveType(typeId: 5)
class PageCommentModel extends HiveObject {
  @HiveField(0)
  final String pageId;

  @HiveField(1)
  final String komentar;

  @HiveField(2)
  final DateTime dibuatPada;

  PageCommentModel({
    required this.pageId,
    required this.komentar,
    required this.dibuatPada,
  });
}

@HiveType(typeId: 6)
class SubmissionModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String assignmentId;

  @HiveField(2)
  final String siswaId;

  @HiveField(3)
  final String storyDataJson;

  @HiveField(4)
  final SubmissionStatus status;

  @HiveField(5)
  final bool sudahSync;

  @HiveField(6)
  final DateTime? submittedAt;

  @HiveField(7)
  final DateTime? reviewedAt;

  @HiveField(8)
  final DateTime updatedAt;

  @HiveField(9)
  final int? nilai;

  @HiveField(10)
  final String? komentarUmum;

  @HiveField(11)
  final List<PageCommentModel> komentarHalaman;

  @HiveField(12)
  final int revisiCount;

  @HiveField(13)
  final String? projectId; 

  @HiveField(14)
  final DateTime? deletedAt; 

  SubmissionModel({
    required this.id,
    required this.assignmentId,
    required this.siswaId,
    required this.storyDataJson,
    required this.status,
    required this.sudahSync,
    this.submittedAt,
    this.reviewedAt,
    required this.updatedAt,
    this.nilai,
    this.komentarUmum,
    required this.komentarHalaman,
    this.revisiCount = 0,
    this.projectId,
    this.deletedAt,
  });

  SubmissionModel copyWith({
    String? id,
    String? assignmentId,
    String? siswaId,
    String? storyDataJson,
    SubmissionStatus? status,
    bool? sudahSync,
    DateTime? submittedAt,
    DateTime? reviewedAt,
    DateTime? updatedAt,
    int? nilai,
    String? komentarUmum,
    List<PageCommentModel>? komentarHalaman,
    int? revisiCount,
    String? projectId,
    DateTime? deletedAt,
  }) {
    return SubmissionModel(
      id: id ?? this.id,
      assignmentId: assignmentId ?? this.assignmentId,
      siswaId: siswaId ?? this.siswaId,
      storyDataJson: storyDataJson ?? this.storyDataJson,
      status: status ?? this.status,
      sudahSync: sudahSync ?? this.sudahSync,
      submittedAt: submittedAt ?? this.submittedAt,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      nilai: nilai ?? this.nilai,
      komentarUmum: komentarUmum ?? this.komentarUmum,
      komentarHalaman: komentarHalaman ?? this.komentarHalaman,
      revisiCount: revisiCount ?? this.revisiCount,
      projectId: projectId ?? this.projectId,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // ── Konversi ke MongoDB Map ──────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'assignmentId': assignmentId,
      'studentId': siswaId,
      'projectId': projectId,
      'storyDataJson': storyDataJson,
      'grade': nilai,
      'teacherComment': komentarUmum,
      'feedbackHistory': komentarHalaman.map((k) => {
        'comment': k.komentar,
        'statusGiven': status.name,
        'createdAt': k.dibuatPada.toIso8601String(),
      }).toList(),
      'status': status.name,
      'submittedAt': submittedAt?.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      // sudahSync & revisiCount → lokal saja
    };
  }

  // ── Buat SubmissionModel dari data MongoDB ─────────────────────────────
  factory SubmissionModel.fromMap(Map<String, dynamic> map) {
    // Parse feedbackHistory → komentarHalaman
    final feedbackRaw = map['feedbackHistory'] as List<dynamic>? ?? [];
    final komentarHalaman = feedbackRaw.map((f) => PageCommentModel(
      pageId: '',
      komentar: f['comment']?.toString() ?? '',
      dibuatPada: f['createdAt'] != null
          ? DateTime.parse(f['createdAt'].toString())
          : DateTime.now(),
    )).toList();

    return SubmissionModel(
      id: map['_id']?.toString() ?? '',
      assignmentId: map['assignmentId']?.toString() ?? '',
      siswaId: map['studentId']?.toString() ?? '',
      projectId: map['projectId']?.toString(),
      nilai: map['grade'] as int?,
      komentarUmum: map['teacherComment'] as String?,
      komentarHalaman: komentarHalaman,
      status: SubmissionStatus.values.firstWhere(
        (s) => s.name == map['status'],
        orElse: () => SubmissionStatus.submitted,
      ),
      submittedAt: map['submittedAt'] != null
          ? DateTime.parse(map['submittedAt'].toString())
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'].toString())
          : DateTime.now(),
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'].toString())
          : null,
      // Default nilai lokal
      storyDataJson: map['storyDataJson']?.toString() ?? '',
      sudahSync: true,
      revisiCount: 0,
    );
  }
}
