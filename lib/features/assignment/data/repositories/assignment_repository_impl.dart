import 'package:uuid/uuid.dart';
import '../../../../core/base/base_use_case.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/models/assignment_model.dart';
import '../../../../features/kelas/data/datasources/kelas_local_data_source.dart';
import '../../domain/repositories/assignment_repository.dart';
import '../datasources/assignment_local_data_source.dart';
import '../datasources/assignment_remote_data_source.dart';

class AssignmentRepositoryImpl implements AssignmentRepository {
  final AssignmentLocalDataSource localDataSource;
  final AssignmentRemoteDataSource remoteDataSource;
  final KelasLocalDataSource kelasLocalDataSource;
  final Uuid uuid;

  AssignmentRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
    required this.kelasLocalDataSource,
    required this.uuid,
  });

  @override
  KometResult<AssignmentModel> createAssignment(AssignmentModel assignment) async {
    try {
      final newAssignment = assignment.copyWith(
        id: uuid.v4(),
        status: AssignmentStatus.aktif,
        dibuatPada: DateTime.now(),
      );

      final remoteAssignment = await remoteDataSource.createAssignment(newAssignment);

      final result = await localDataSource.createAssignment(remoteAssignment);
      
      try {
        final currentKelas = await kelasLocalDataSource.getKelasById(assignment.kelasId);
        final updatedAssignments = List<String>.from(currentKelas.assignmentIds)..add(remoteAssignment.id);
        await kelasLocalDataSource.createKelas(currentKelas.copyWith(assignmentIds: updatedAssignments));
      } catch (e) {
        // Silently fail if local kelas update fails as assignment is already created
      }
      
      return kometSuccess(result);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<void> deleteAssignment(String assignmentId) async {
    try {
      await remoteDataSource.deleteAssignment(assignmentId);
      await localDataSource.deleteAssignment(assignmentId);
      return kometSuccess(null);
    } catch (e) {
      return kometFailure(LocalStorageFailure(e.toString()));
    }
  }

  @override
  KometResult<List<AssignmentModel>> getAssignmentsByClass(String kelasId) async {
    try {
      // Ambil dari server
      final remoteData = await remoteDataSource.getAssignmentsByClass(kelasId);
      
      for (final assignment in remoteData) {
        await localDataSource.createAssignment(assignment);
      }
      
      return kometSuccess(remoteData);
    } catch (e) {
      // Fallback lokal jika offline
      try {
        final localData = await localDataSource.getAssignmentsByClass(kelasId);
        return kometSuccess(localData);
      } catch (e2) {
        return kometFailure(LocalStorageFailure(e2.toString()));
      }
    }
  }
}
