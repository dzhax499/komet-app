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
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> registerGuru(UserModel user);
  Future<UserModel> registerSiswa(UserModel user, String? kodeKelas);
  Future<UserModel> login(String email, String password);
  Future<UserModel> signInWithGoogle();
  Future<void> updateProfile(UserModel user);
  Future<void> sendPasswordResetOtp(String email);
  Future<void> verifyResetOtp(String email, String otp);
  Future<void> resetPassword(String email, String newPassword);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final MongoService mongoService;
  final Map<String, String> _otpStorage = {}; // Penyimpanan OTP sementara untuk simulasi

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

  @override
  Future<void> updateProfile(UserModel user) async {
    try {
      final collection = await mongoService.userCollection;
      await collection.update(
        where.eq('_id', user.id),
        modify.set('name', user.nama).set('photoUrl', user.photoUrl),
      );
    } catch (e) {
      throw Exception("Gagal update profile di server: ${e.toString()}");
    }
  }

  String _hashPassword(String password) {
    if (password == "GOOGLE_AUTH") return password; 
    print("DEBUG: Sedang me-hash password...");
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<void> sendPasswordResetOtp(String email) async {
    try {
      final collection = await mongoService.userCollection;
      final user = await collection.findOne(where.eq('email', email));
      
      if (user == null) {
        throw Exception("Email tidak terdaftar.");
      }
      
      if (user['password'] == 'GOOGLE_AUTH') {
        throw Exception("Gunakan login Google untuk akun ini.");
      }

      // Generate random 6 digit OTP
      final otp = (100000 + DateTime.now().microsecondsSinceEpoch % 900000).toString();
      _otpStorage[email] = otp;

      print("==================================================");
      print("MENGIRIM EMAIL OTP");
      print("Ke: $email");
      print("Kode OTP: $otp");
      print("==================================================");

      final smtpEmail = dotenv.env['SMTP_EMAIL'];
      final smtpPassword = dotenv.env['SMTP_PASSWORD'];

      if (smtpEmail == null || smtpPassword == null || smtpEmail.isEmpty || smtpPassword.isEmpty || smtpEmail == 'your_email@gmail.com') {
        print("WARNING: Kredensial SMTP belum diatur di .env. Menggunakan mode simulasi.");
        return; // Fallback ke mode simulasi jika belum ada di .env
      }

      final smtpServer = gmail(smtpEmail, smtpPassword);

      final message = Message()
        ..from = Address(smtpEmail, 'Komet App')
        ..recipients.add(email)
        ..subject = 'Kode Verifikasi Lupa Password Komet'
        ..html = '''
          <div style="font-family: sans-serif; padding: 20px; text-align: center;">
            <h2>Reset Password Anda</h2>
            <p>Anda menerima email ini karena Anda meminta untuk mengatur ulang kata sandi akun Komet Anda.</p>
            <p>Berikut adalah kode OTP Anda:</p>
            <h1 style="color: #4A7473; letter-spacing: 5px;">$otp</h1>
            <p>Kode ini hanya berlaku sementara. Jangan bagikan kode ini kepada siapa pun.</p>
          </div>
        ''';

      final sendReport = await send(message, smtpServer);
      print('Email terkirim: ${sendReport.toString()}');

    } catch (e) {
      print("Error mengirim email: ${e.toString()}");
      throw Exception("Gagal mengirim OTP: ${e.toString()}");
    }
  }

  @override
  Future<void> verifyResetOtp(String email, String otp) async {
    if (_otpStorage[email] != otp) {
      throw Exception("Kode OTP salah atau sudah kadaluarsa.");
    }
  }

  @override
  Future<void> resetPassword(String email, String newPassword) async {
    try {
      final collection = await mongoService.userCollection;
      final hashedNewPassword = _hashPassword(newPassword);
      
      await collection.update(
        where.eq('email', email),
        modify.set('password', hashedNewPassword),
      );

      _otpStorage.remove(email);
    } catch (e) {
      throw Exception("Gagal mereset password: \${e.toString()}");
    }
  }
}
