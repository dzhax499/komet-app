import 'package:mongo_dart/mongo_dart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/foundation.dart';

class MongoService {
  MongoService._internal();
  static final MongoService _instance = MongoService._internal();
  factory MongoService() => _instance;

  Db? _db;
  final String _source = "mongo_service.dart";

  // --- KOLEKSI KOMET ---
  Future<DbCollection> get userCollection async => 
      await _getCollection("users");
  Future<DbCollection> get classCollection async => 
      await _getCollection("classes");
  Future<DbCollection> get assignmentCollection async => 
      await _getCollection("assignments");
  Future<DbCollection> get submissionCollection async => 
      await _getCollection("submissions");
  Future<DbCollection> get projectCollection async => 
      await _getCollection("projects");

  Future<DbCollection> _getCollection(String name) async {
    try {
      if (_db == null || !_db!.isConnected) {
        await connect();
      }
      if (_db == null || !_db!.isConnected) {
        throw "Koneksi database tidak aktif.";
      }
      return _db!.collection(name);
    } catch (e) {
      throw "Database Error: $e";
    }
  }

  // --- FUNGSI LOGGING BERWARNA ---
  void _kometLog(String message, {String level = 'INFO', String? source}) {
    final time = DateTime.now().toString().substring(11, 19);
    final src = source ?? _source;

    // Kode Warna ANSI
    const reset = '\x1B[0m';
    const red = '\x1B[31m';
    const green = '\x1B[32m';
    const yellow = '\x1B[33m';
    const cyan = '\x1B[36m';
    const gray = '\x1B[90m';

    String color;
    switch (level) {
      case 'ERROR':
        color = red;
        break;
      case 'WARNING':
        color = yellow;
        break;
      case 'INFO':
        color = green;
        break;
      case 'VERBOSE':
        color = cyan;
        break;
      default:
        color = gray;
    }

    // Format: [TIME][LEVEL][SOURCE] -> MESSAGE
    debugPrint('$color[$time][$level][$src] -> $message$reset');
  }

  Db get db {
    if (_db == null) {
      throw Exception(
        "DATABASE: Belum diinisialisasi! Panggil connect() dulu.",
      );
    }
    return _db!;
  }

  // Inisialisasi Koneksi
  Future<void> connect() async {
    if (_db != null && _db!.isConnected) return;

    try {
      _kometLog(
        "Koneksi belum siap, mencoba menghubungkan...",
        level: "VERBOSE",
      );

      final mongoUri = dotenv.env['MONGODB_URI'];
      if (mongoUri == null || mongoUri.isEmpty) {
        throw "MONGODB_URI tidak ditemukan di file .env!";
      }

      _db = await Db.create(mongoUri);

      // TIMEOUT: Mencegah layar hitam
      await _db!.open().timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw "Koneksi ke MongoDB Atlas Timeout (Cek Whitelist IP/Sinyal)";
        },
      );

      _kometLog(
        "DATABASE: Terhubung & Koleksi Siap",
        level: "INFO",
      );
    } catch (e) {
      _kometLog(
        "DATABASE: Gagal Koneksi - $e ",
        level: "ERROR",
      );
      rethrow;
    }
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
      _kometLog(
        "DATABASE: Koneksi ditutup",
        level: "INFO",
      );
    }
  }
}