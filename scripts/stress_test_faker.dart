import 'package:faker/faker.dart';
import 'package:uuid/uuid.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';

int promptInt(String message, int defaultValue) {
  stdout.write("$message (default: $defaultValue): ");
  final input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) {
    return defaultValue;
  }
  return int.tryParse(input.trim()) ?? defaultValue;
}

String promptString(String message, String defaultValue) {
  stdout.write("$message (default: $defaultValue): ");
  final input = stdin.readLineSync();
  if (input == null || input.trim().isEmpty) {
    return defaultValue;
  }
  return input.trim();
}

void main() async {
  print("=== Konfigurasi Stress Test ===");
  final numStudents = promptInt("Jumlah akun siswa yang akan dibuat", 100);
  final numClasses = promptInt("Jumlah kelas yang akan dibuat", 20);
  final studentsPerClass = promptInt("Jumlah siswa per kelas", 50);
  final password = promptString("Password untuk semua akun", "password123");
  print("===============================\n");

  final actualStudentsPerClass = studentsPerClass > numStudents ? numStudents : studentsPerClass;
  if (studentsPerClass > numStudents) {
    print("⚠️ Warning: Jumlah siswa per kelas lebih besar dari total siswa.");
    print("   Menyesuaikan jumlah siswa per kelas menjadi $actualStudentsPerClass.\n");
  }

  // Load .env manual
  final envFile = File('.env');
  String mongoUri = '';
  
  if (await envFile.exists()) {
    final lines = await envFile.readAsLines();
    for (var line in lines) {
      if (line.startsWith('MONGODB_URI=')) {
        mongoUri = line.substring('MONGODB_URI='.length).trim();
        // Remove quotes if any
        if (mongoUri.startsWith('"') && mongoUri.endsWith('"')) {
          mongoUri = mongoUri.substring(1, mongoUri.length - 1);
        } else if (mongoUri.startsWith("'") && mongoUri.endsWith("'")) {
          mongoUri = mongoUri.substring(1, mongoUri.length - 1);
        }
        break;
      }
    }
  }

  if (mongoUri.isEmpty) {
    print("❌ Error: MONGODB_URI tidak ditemukan di file .env!");
    return;
  }

  print("Menghubungkan ke MongoDB...");
  final db = await Db.create(mongoUri);
  await db.open();

  final userCollection = db.collection('users');
  final classCollection = db.collection('classes');

  final faker = Faker();
  final uuid = Uuid();

  // Password hashing logic dari AuthRemoteDataSourceImpl
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes).toString(); // hashed password

  print("Membuat $numStudents akun siswa...");
  List<String> siswaIds = [];
  List<Map<String, dynamic>> siswaDocs = [];

  for (int i = 0; i < numStudents; i++) {
    final id = uuid.v4();
    siswaIds.add(id);
    
    // Pastikan email unik dengan index + timestamp
    final email = 'siswa${i}_${DateTime.now().millisecondsSinceEpoch}@komet.app';
    
    siswaDocs.add({
      '_id': id,
      'name': faker.person.name(),
      'email': email,
      'password': digest,
      'role': 'siswa',
      'createdAt': DateTime.now().toIso8601String(),
      'photoUrl': null,
    });
  }

  if (siswaDocs.isNotEmpty) {
    await userCollection.insertMany(siswaDocs);
  }
  print("✅ $numStudents akun siswa berhasil dibuat.");

  print("Membuat 1 akun guru...");
  final guruId = uuid.v4();
  final guruEmail = 'guru_stress_${DateTime.now().millisecondsSinceEpoch}@komet.app';
  await userCollection.insertOne({
    '_id': guruId,
    'name': "Guru " + faker.person.name(),
    'email': guruEmail,
    'password': digest,
    'role': 'guru',
    'createdAt': DateTime.now().toIso8601String(),
    'photoUrl': null,
  });
  print("✅ Akun guru berhasil dibuat.");
  print("   📧 Email Guru: $guruEmail");
  print("   🔑 Password  : $password");
  
  print("Membuat $numClasses kelas dengan masing-masing $actualStudentsPerClass akun siswa...");
  List<Map<String, dynamic>> kelasDocs = [];

  for (int i = 0; i < numClasses; i++) {
    final kelasId = uuid.v4();
    
    // Acak daftar siswa, lalu ambil sejumlah actualStudentsPerClass
    siswaIds.shuffle();
    final selectedSiswaIds = siswaIds.take(actualStudentsPerClass).toList();
    
    kelasDocs.add({
      '_id': kelasId,
      'teacherId': guruId,
      'className': 'Kelas ' + faker.company.name(),
      'classCode': faker.randomGenerator.string(6, min: 6).toUpperCase(),
      'isOpen': true,
      'students': selectedSiswaIds,
      'assignments': [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  if (kelasDocs.isNotEmpty) {
    await classCollection.insertMany(kelasDocs);
  }
  print("✅ $numClasses kelas berhasil dibuat dan ditautkan dengan $actualStudentsPerClass siswa (masing-masing).");

  await db.close();
  print("🎉 Stress test data generation selesai.");
  print("==================================================");
  print("ℹ️ Semua akun (Guru & Siswa) menggunakan password: $password");
  print("==================================================");
}
