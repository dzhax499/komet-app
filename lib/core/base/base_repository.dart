// lib/core/base/base_repository.dart
// PIC D — Dzakir Tsabit Asy Syafiq
// Abstract interface untuk repository. PIC B akan mengimplementasikan
// repository konkret di lib/data/ menggunakan interface ini sebagai kontrak.

/// Marker interface untuk semua repository di KOMET.
/// Tidak memaksakan method tertentu — setiap repository mendefinisikan
/// contract-nya sendiri sesuai domain yang dilayaninya.
///
/// Contoh (milik PIC B):
/// ```dart
/// abstract class SubmissionRepository extends BaseRepository {
///   Future<SubmissionModel?> getById(String id);
///   Future<void> save(SubmissionModel submission);
///   Future<List<SubmissionModel>> getByAssignmentId(String assignmentId);
/// }
/// ```
abstract class BaseRepository {
  const BaseRepository();
}
