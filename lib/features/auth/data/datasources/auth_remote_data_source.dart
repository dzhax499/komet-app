import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/database/mongo_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/error/failures.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> registerGuru(UserModel user);
  Future<UserModel> registerSiswa(UserModel user, String? kodeKelas);
  Future<UserModel> login(String email, String password);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final MongoService mongoService;

  AuthRemoteDataSourceImpl({required this.mongoService});

  @override
  Future<UserModel> registerGuru(UserModel user) async {
    return _registerUser(user);
  }

  @override
  Future<UserModel> registerSiswa(UserModel user, String? kodeKelas) async {

    return _registerUser(user);
  }

  Future<UserModel> _registerUser(UserModel user) async {
    try {
      final collection = await mongoService.userCollection;

      // 1. Cek apakah email sudah terdaftar
      final existingUser = await collection.findOne(where.eq('email', user.email));
      if (existingUser != null) {
        throw Exception("Email sudah terdaftar. Silakan gunakan email lain.");
      }

      // 2. Insert user ke MongoDB
      final userMap = user.toMap();
      await collection.insertOne(userMap);

      return user;
    } catch (e) {
      throw Exception("Gagal register di server: ${e.toString()}");
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final collection = await mongoService.userCollection;

      final userMap = await collection.findOne(
        where.eq('email', email).eq('password', password)
      );

      if (userMap == null) {
        throw Exception("Email atau password salah.");
      }

      return UserModel.fromMap(userMap);
    } catch (e) {
      throw Exception("Gagal login: ${e.toString()}");
    }
  }
}
