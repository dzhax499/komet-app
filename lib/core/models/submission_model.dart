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
    );
  }
}
