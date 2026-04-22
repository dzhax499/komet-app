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

  UserModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.password,
    required this.role,
    required this.kelasIds,
    required this.createdAt,
    required this.lastLoginAt,
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
    );
  }
}
