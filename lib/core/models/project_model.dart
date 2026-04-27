import 'package:hive/hive.dart';

part 'project_model.g.dart';

@HiveType(typeId: 12)
class ProjectModel extends HiveObject {
  @HiveField(0)
  final String id; 

  @HiveField(1)
  final String? mongoId;

  @HiveField(2)
  final String ownerId;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String projectData; 

  @HiveField(5)
  final bool isSubmitted;

  @HiveField(6)
  final DateTime lastEditedAt;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final DateTime? lastSyncedAt;

  @HiveField(9)
  final DateTime? deletedAt;

  ProjectModel({
    required this.id,
    this.mongoId,
    required this.ownerId,
    required this.title,
    required this.projectData,
    this.isSubmitted = false,
    required this.lastEditedAt,
    required this.createdAt,
    this.lastSyncedAt,
    this.deletedAt,
  });

  ProjectModel copyWith({
    String? id,
    String? mongoId,
    String? ownerId,
    String? title,
    String? projectData,
    bool? isSubmitted,
    DateTime? lastEditedAt,
    DateTime? createdAt,
    DateTime? lastSyncedAt,
    DateTime? deletedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      mongoId: mongoId ?? this.mongoId,
      ownerId: ownerId ?? this.ownerId,
      title: title ?? this.title,
      projectData: projectData ?? this.projectData,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      lastEditedAt: lastEditedAt ?? this.lastEditedAt,
      createdAt: createdAt ?? this.createdAt,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  // Konversi ke MongoDB Map
  Map<String, dynamic> toMap() {
    return {
      '_id': mongoId ?? id, 
      'ownerId': ownerId,
      'title': title,
      'projectData': projectData,
      'isSubmitted': isSubmitted,
      'lastEditedAt': lastEditedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
      'localId': id, 
      'deletedAt': deletedAt?.toIso8601String(),
    };
  }

  // Buat ProjectModel dari data MongoDB
  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['localId']?.toString() ?? map['_id']?.toString() ?? '',
      mongoId: map['_id']?.toString(),
      ownerId: map['ownerId']?.toString() ?? '',
      title: map['title'] ?? '',
      projectData: map['projectData']?.toString() ?? '{}',
      isSubmitted: map['isSubmitted'] ?? false,
      lastEditedAt: map['lastEditedAt'] != null
          ? DateTime.parse(map['lastEditedAt'].toString())
          : DateTime.now(),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      lastSyncedAt: map['lastSyncedAt'] != null
          ? DateTime.parse(map['lastSyncedAt'].toString())
          : null,
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'].toString())
          : null,
    );
  }
}
