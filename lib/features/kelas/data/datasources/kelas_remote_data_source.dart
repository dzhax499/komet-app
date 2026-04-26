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
  Future<void> deleteKelas(String kelasId);
  Future<List<UserModel>> getSiswaInKelas(String kelasId);
  Future<bool> isKodeKelasAvailable(String kodeKelas);
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
    final collection = await mongoService.classCollection;
    final assignmentCol = await mongoService.assignmentCollection;

    // Mencari siswaId di dalam array students
    final result = await collection.find(
      where.eq('students', siswaId).eq('deletedAt', null)
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
  Future<void> deleteKelas(String kelasId) async {
    final collection = await mongoService.classCollection;

    await collection.updateOne(
      where.eq('_id', kelasId),
      modify.set('deletedAt', DateTime.now().toIso8601String())
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

    final usersMap = await userCollection.find(
      where.oneFrom('_id', studentIds).eq('deletedAt', null)
    ).toList();

    return usersMap.map((map) => UserModel.fromMap(map)).toList();
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
}
