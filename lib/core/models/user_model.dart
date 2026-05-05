import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String nama;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String role; // "guru" atau "siswa"

  @HiveField(5)
  final List<String> kelasIds;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final DateTime lastLoginAt;

  @HiveField(8)
  final DateTime? deletedAt; // ➕ Soft delete

  @HiveField(9)
  final String? photoUrl;

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.role,
    required this.kelasIds,
    required this.createdAt,
    required this.lastLoginAt,
    this.deletedAt,
    this.photoUrl,
  });

  UserModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? password,
    String? role,
    List<String>? kelasIds,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    DateTime? deletedAt,
    String? photoUrl,
  }) {
    return UserModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      kelasIds: kelasIds ?? this.kelasIds,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      deletedAt: deletedAt ?? this.deletedAt,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  // ── Konversi ke MongoDB Map ──────────────────────────────────────────────
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'name': nama,
      'email': email,
      'password': password,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
      'deletedAt': deletedAt?.toIso8601String(),
      'photoUrl': photoUrl,
    };
  }

  // Buat UserModel dari data MongoDB
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id']?.toString() ?? '',
      nama: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      role: map['role'] ?? 'siswa',
      kelasIds: const [], // diisi dari data lokal
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      lastLoginAt: DateTime.now(), // diisi dari data lokal
      deletedAt: map['deletedAt'] != null
          ? DateTime.parse(map['deletedAt'].toString())
          : null,
      photoUrl: map['photoUrl'],
    );
  }
}
