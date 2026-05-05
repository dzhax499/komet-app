import 'package:mongo_dart/mongo_dart.dart';
import '../../../../core/database/mongo_service.dart';
import '../../../../core/models/kelas_model.dart';
import '../../../../core/models/user_model.dart';

abstract class KelasRemoteDataSource {
  Future<KelasModel> createKelas(KelasModel kelas);
  Future<List<KelasModel>> getKelasGuru(String guruId);
  Future<List<KelasModel>> getKelasSiswa(String siswaId);
  Future<KelasModel> joinKelas(String kodeKelas, String siswaId);
  Future<KelasModel> getKelasById(String kelasId);
  Future<KelasModel> updateKelas(String kelasId, String newNama);
  Future<void> deleteKelas(String kelasId);
  Future<void> removeStudent(String kelasId, String siswaId);
  Future<List<UserModel>> getSiswaInKelas(String kelasId);
  Future<bool> isKodeKelasAvailable(String kodeKelas);
  Future<void> leaveKelas(String kelasId, String siswaId);
}

class KelasRemoteDataSourceImpl implements KelasRemoteDataSource {
  final MongoService mongoService;

  KelasRemoteDataSourceImpl({required this.mongoService});

  @override
  Future<KelasModel> createKelas(KelasModel kelas) async {
    final collection = await mongoService.classCollection;

    await collection.insertOne(kelas.toMap());
    return kelas;
  }

  @override
  Future<List<KelasModel>> getKelasGuru(String guruId) async {
    final collection = await mongoService.classCollection;
    final assignmentCol = await mongoService.assignmentCollection;

    final result = await collection.find(
      where.eq('teacherId', guruId).eq('deletedAt', null)
    ).toList();

    List<KelasModel> kelasList = [];
    for (var map in result) {
      // Sync jumlah tugas secara realtime dari koleksi assignments
      final assignments = await assignmentCol.find(
        where.eq('classId', map['_id']).eq('deletedAt', null)
      ).toList();
      
      final assignmentIds = assignments.map((a) => a['_id'].toString()).toList();

      final List<dynamic> currentAssignments = map['assignments'] ?? [];
      if (currentAssignments.length != assignmentIds.length) {
        await collection.updateOne(
          where.eq('_id', map['_id']),
          modify.set('assignments', assignmentIds)
        );
      }

      // Perbarui data map sebelum dikonversi ke model
      map['assignments'] = assignmentIds;
      kelasList.add(KelasModel.fromMap(map));
    }

    return kelasList;
  }

  @override
  Future<List<KelasModel>> getKelasSiswa(String siswaId) async {
    if (siswaId.isEmpty) return [];

    final collection = await mongoService.classCollection;
    final assignmentCol = await mongoService.assignmentCollection;

    // Mencari kelas di mana siswaId ada di dalam array students
    // Gunakan raw query untuk memastikan array membership check benar
    final result = await collection.find(
      where.raw({
        'students': siswaId,
        'deletedAt': null,
      })
    ).toList();

    List<KelasModel> kelasList = [];
    for (var map in result) {
      // Sync jumlah tugas secara realtime
      final assignments = await assignmentCol.find(
        where.eq('classId', map['_id']).eq('deletedAt', null)
      ).toList();
      
      final assignmentIds = assignments.map((a) => a['_id'].toString()).toList();

      // AUTO-HEAL: Sync balik ke DB
      final List<dynamic> currentAssignments = map['assignments'] ?? [];
      if (currentAssignments.length != assignmentIds.length) {
        await collection.updateOne(
          where.eq('_id', map['_id']),
          modify.set('assignments', assignmentIds)
        );
      }

      map['assignments'] = assignmentIds;
      kelasList.add(KelasModel.fromMap(map));
    }

    return kelasList;
  }

  @override
  Future<KelasModel> joinKelas(String kodeKelas, String siswaId) async {
    final collection = await mongoService.classCollection;

    final kelasMap = await collection.findOne(
      where.eq('classCode', kodeKelas).eq('deletedAt', null)
    );

    if (kelasMap == null) {
      throw Exception("Kode kelas tidak valid atau tidak ditemukan.");
    }

    await collection.updateOne(
      where.eq('classCode', kodeKelas),
      modify.addToSet('students', siswaId)
    );

    final updatedMap = await collection.findOne(where.eq('classCode', kodeKelas));
    return KelasModel.fromMap(updatedMap!);
  }

  @override
  Future<KelasModel> updateKelas(String kelasId, String newNama) async {
    final collection = await mongoService.classCollection;

    await collection.updateOne(
      where.eq('_id', kelasId),
      modify.set('className', newNama)
    );

    final updatedMap = await collection.findOne(where.eq('_id', kelasId));
    if (updatedMap == null) throw Exception("Gagal memperbarui kelas");
    return KelasModel.fromMap(updatedMap);
  }

  @override
  Future<void> deleteKelas(String kelasId) async {
    final classCol = await mongoService.classCollection;
    final assignmentCol = await mongoService.assignmentCollection;
    final submissionCol = await mongoService.submissionCollection;

    // 1. Cari semua tugas yang ada di dalam kelas ini
    final assignments = await assignmentCol.find(where.eq('classId', kelasId)).toList();
    final assignmentIds = assignments.map((a) => a['_id'].toString()).toList();

    // 2. Hapus semua jawaban (submissions) milik tugas-tugas di kelas ini
    if (assignmentIds.isNotEmpty) {
      await submissionCol.deleteMany(where.oneFrom('assignmentId', assignmentIds));
    }

    // 3. Hapus semua tugas (assignments) di kelas ini
    await assignmentCol.deleteMany(where.eq('classId', kelasId));

    // 4. Hapus data kelas itu sendiri
    await classCol.deleteOne(where.eq('_id', kelasId));
  }

  @override
  Future<void> removeStudent(String kelasId, String siswaId) async {
    final collection = await mongoService.classCollection;

    await collection.updateOne(
      where.eq('_id', kelasId),
      modify.pull('students', siswaId)
    );
  }

  @override
  Future<List<UserModel>> getSiswaInKelas(String kelasId) async {
    final classCollection = await mongoService.classCollection;
    final userCollection = await mongoService.userCollection;

    final kelasMap = await classCollection.findOne(where.eq('_id', kelasId));
    if (kelasMap == null) return [];

    final List<dynamic> studentsRaw = kelasMap['students'] ?? [];
    final List<String> studentIds = studentsRaw.map((e) => e.toString()).toList();

    if (studentIds.isEmpty) return [];

    // Cari user yang aktif (belum dihapus)
    final usersMap = await userCollection.find(
      where.oneFrom('_id', studentIds).eq('deletedAt', null)
    ).toList();

    final List<UserModel> activeStudents = usersMap.map((map) => UserModel.fromMap(map)).toList();
    final List<String> activeStudentIds = activeStudents.map((u) => u.id).toList();

    // OTOMATIS BERSIHKAN: Jika ada ID di kelas tapi user-nya sudah dihapus/tidak ada
    if (activeStudentIds.length < studentIds.length) {
      await classCollection.updateOne(
        where.eq('_id', kelasId),
        modify.set('students', activeStudentIds)
      );
    }

    return activeStudents;
  }

  @override
  Future<KelasModel> getKelasById(String kelasId) async {
    final collection = await mongoService.classCollection;
    final map = await collection.findOne(where.eq('_id', kelasId).eq('deletedAt', null));
    if (map == null) throw Exception("Kelas tidak ditemukan di remote");
    return KelasModel.fromMap(map);
  }

  @override
  Future<bool> isKodeKelasAvailable(String kodeKelas) async {
    final collection = await mongoService.classCollection;
    final map = await collection.findOne(where.eq('classCode', kodeKelas));
    return map == null;
  }

  @override
  Future<void> leaveKelas(String kelasId, String siswaId) async {
    final collection = await mongoService.classCollection;
    await collection.updateOne(
      where.eq('_id', kelasId),
      modify.pull('students', siswaId),
    );
  }
}
