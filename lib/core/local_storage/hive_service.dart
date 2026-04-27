import 'package:hive_flutter/hive_flutter.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';
import '../models/kelas_model.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../models/notification_model.dart';
import '../models/sync_queue_item_model.dart';
import '../models/project_model.dart';

class HiveService {
  static const String userBox = KometBoxNames.users;
  static const String kelasBox = KometBoxNames.kelas;
  static const String assignmentBox = KometBoxNames.assignments;
  static const String submissionBox = KometBoxNames.submissions;
  static const String notificationBox = KometBoxNames.notifications;
  static const String syncQueueBox = KometBoxNames.syncQueue;
  static const String projectBox = KometBoxNames.storyProjects;
  static const String authBox = KometBoxNames.settings; 

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    _registerAdapters();

    // Open Boxes
    await Future.wait([
      Hive.openBox<UserModel>(userBox),
      Hive.openBox<KelasModel>(kelasBox),
      Hive.openBox<AssignmentModel>(assignmentBox),
      Hive.openBox<SubmissionModel>(submissionBox),
      Hive.openBox<NotificationModel>(notificationBox),
      Hive.openBox<SyncQueueItemModel>(syncQueueBox),
      Hive.openBox<ProjectModel>(projectBox), 
      Hive.openBox(authBox),
    ]);
  }

  void _registerAdapters() {
    Hive.registerAdapter(UserModelAdapter()); // id 0
    Hive.registerAdapter(KelasModelAdapter()); // id 1
    Hive.registerAdapter(AssignmentStatusAdapter()); // id 2
    Hive.registerAdapter(AssignmentModelAdapter()); // id 3
    Hive.registerAdapter(SubmissionStatusAdapter()); // id 4
    Hive.registerAdapter(PageCommentModelAdapter()); // id 5
    Hive.registerAdapter(SubmissionModelAdapter()); // id 6
    Hive.registerAdapter(NotificationTypeAdapter()); // id 7
    Hive.registerAdapter(NotificationModelAdapter()); // id 8
    Hive.registerAdapter(SyncDataTypeAdapter()); // id 9
    Hive.registerAdapter(SyncOperationAdapter()); // id 10
    Hive.registerAdapter(SyncQueueItemModelAdapter()); // id 11
    Hive.registerAdapter(ProjectModelAdapter()); // id 12
  }

  // Helper methods untuk Auth 
  Future<void> persistUser(UserModel user) async {
    final box = Hive.box(authBox);
    await box.put('currentUser', user.id);
    await Hive.box<UserModel>(userBox).put(user.id, user);
  }

  UserModel? getCurrentUser() {
    final userId = Hive.box(authBox).get('currentUser') as String?;
    if (userId == null) return null;
    return Hive.box<UserModel>(userBox).get(userId);
  }

  UserModel? getUserByEmail(String email) {
    final box = Hive.box<UserModel>(userBox);
    try {
      return box.values.firstWhere((user) => user.email == email);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveUser(UserModel user) async {
    await Hive.box<UserModel>(userBox).put(user.id, user);
  }

  Future<void> saveKelas(KelasModel kelas) async {
    await Hive.box<KelasModel>(kelasBox).put(kelas.id, kelas);
  }

  Future<void> deleteKelas(String kelasId) async {
    await Hive.box<KelasModel>(kelasBox).delete(kelasId);
  }

  // Helper methods untuk Sync Queue
  Future<void> addSyncItem(SyncQueueItemModel item) async {
    await Hive.box<SyncQueueItemModel>(syncQueueBox).put(item.id, item);
  }

  List<SyncQueueItemModel> getSyncQueue() {
    return Hive.box<SyncQueueItemModel>(syncQueueBox).values.toList()
      ..sort((a, b) => a.dibuatPada.compareTo(b.dibuatPada));
  }

  Future<void> removeSyncItem(String id) async {
    await Hive.box<SyncQueueItemModel>(syncQueueBox).delete(id);
  }

  KelasModel? getKelasById(String kelasId) {
    try {
      return Hive.box<KelasModel>(kelasBox).get(kelasId);
    } catch (_) {
      return null;
    }
  } 

  List<KelasModel> getKelasByGuruId(String guruId) {
    return Hive.box<KelasModel>(kelasBox).values.where((k) => k.guruId == guruId).toList();
  }

  List<KelasModel> getKelasBySiswaId(String siswaId) {
    return Hive.box<KelasModel>(kelasBox).values.where((k) => k.siswaIds.contains(siswaId)).toList();
  }

  KelasModel? getKelasByKode(String kode) {
    try {
      return Hive.box<KelasModel>(kelasBox).values.firstWhere((k) => k.kodeKelas == kode);
    } catch (_) {
      return null;
    }
  }

  List<UserModel> getUsersByIds(List<String> ids) {
    final box = Hive.box<UserModel>(userBox);
    return ids.map((id) => box.get(id)).whereType<UserModel>().toList();
  }

  Future<void> logout() async {
    await Hive.box(authBox).delete('currentUser');
  }

  // Assignment Methods 
  Future<void> saveAssignment(AssignmentModel assignment) async {
    await Hive.box<AssignmentModel>(assignmentBox).put(assignment.id, assignment);
  }

  List<AssignmentModel> getAssignmentsByKelasId(String kelasId) {
    return Hive.box<AssignmentModel>(assignmentBox)
        .values
        .where((a) => a.kelasId == kelasId)
        .toList();
  }

  Future<void> deleteAssignment(String assignmentId) async {
    await Hive.box<AssignmentModel>(assignmentBox).delete(assignmentId);
  }

  // Submission Methods 
  Future<void> saveSubmission(SubmissionModel submission) async {
    await Hive.box<SubmissionModel>(submissionBox).put(submission.id, submission);
  }

  List<SubmissionModel> getSubmissionsByAssignmentId(String assignmentId) {
    return Hive.box<SubmissionModel>(submissionBox)
        .values
        .where((s) => s.assignmentId == assignmentId)
        .toList();
  }

  SubmissionModel? getSubmissionById(String submissionId) {
    return Hive.box<SubmissionModel>(submissionBox).get(submissionId);
  }

  List<SubmissionModel> getSubmissionsByStudentId(String studentId) {
    return Hive.box<SubmissionModel>(submissionBox)
        .values
        .where((s) => s.siswaId == studentId)
        .toList();
  }

  List<SubmissionModel> getAllSubmissions() {
    return Hive.box<SubmissionModel>(submissionBox).values.toList();
  }

  List<SubmissionModel> getSubmissionsByClassId(String classId) {
    final kelas = getKelasById(classId);
    if (kelas == null) return [];
    
    final assignmentIds = kelas.assignmentIds;
    return Hive.box<SubmissionModel>(submissionBox)
        .values
        .where((s) => assignmentIds.contains(s.assignmentId))
        .toList();
  }

  // Project Methods 
  Future<void> saveProject(ProjectModel project) async {
    await Hive.box<ProjectModel>(projectBox).put(project.id, project);
  }

  ProjectModel? getProjectById(String projectId) {
    return Hive.box<ProjectModel>(projectBox).get(projectId);
  }

  List<ProjectModel> getProjectsByOwnerId(String ownerId) {
    return Hive.box<ProjectModel>(projectBox)
        .values
        .where((p) => p.ownerId == ownerId)
        .toList();
  }
}
