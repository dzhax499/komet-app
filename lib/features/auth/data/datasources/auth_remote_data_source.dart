import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/database/mongo_service.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/error/failures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../../firebase_options.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> registerGuru(UserModel user);
  Future<UserModel> registerSiswa(UserModel user, String? kodeKelas);
  Future<UserModel> login(String email, String password);
  Future<UserModel> signInWithGoogle();
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
      print("DEBUG: Menjalankan registerUser untuk ${user.email}");
      final hashedUser = user.copyWith(password: _hashPassword(user.password));
      print("DEBUG: Password setelah di-hash: ${hashedUser.password}");
      await collection.insertOne(hashedUser.toMap());

      return user;
    } catch (e) {
      throw Exception("Gagal register di server: ${e.toString()}");
    }
  }

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      final collection = await mongoService.userCollection;

      final hashedLocalPassword = _hashPassword(password);
      final userMap = await collection.findOne(
        where.eq('email', email).eq('password', hashedLocalPassword)
      );

      if (userMap == null) {
        throw Exception("Email atau password salah.");
      }

      return UserModel.fromMap(userMap);
    } catch (e) {
      throw Exception("Gagal login: ${e.toString()}");
    }
  }
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: kIsWeb ? DefaultFirebaseOptions.webClientId : null,
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw Exception("Login dibatalkan");

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final User? firebaseUser = userCredential.user;

      if (firebaseUser == null) throw Exception("Gagal mendapatkan data user dari Firebase");

      // Cek di MongoDB
      final collection = await mongoService.userCollection;
      final existingUserMap = await collection.findOne(where.eq('email', firebaseUser.email));

      if (existingUserMap != null) {
        return UserModel.fromMap(existingUserMap);
      } else {
        return UserModel(
          id: firebaseUser.uid,
          nama: firebaseUser.displayName ?? "User Google",
          email: firebaseUser.email ?? "",
          password: "GOOGLE_AUTH",
          role: 'NEW_USER',
          kelasIds: [],
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
      }
    } catch (e) {
      throw Exception("Gagal Login Google: ${e.toString()}");
    }
  }

  String _hashPassword(String password) {
    if (password == "GOOGLE_AUTH") return password; 
    print("DEBUG: Sedang me-hash password...");
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
