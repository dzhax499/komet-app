import 'package:hive_flutter/hive_flutter.dart';
import '../models/user_model.dart';
import '../models/kelas_model.dart';
import '../models/assignment_model.dart';
import '../models/submission_model.dart';
import '../models/notification_model.dart';
import '../models/sync_queue_item_model.dart';

class HiveService {
  static const String userBox = 'userBox';
  static const String kelasBox = 'kelasBox';
  static const String assignmentBox = 'assignmentBox';
  static const String submissionBox = 'submissionBox';
  static const String notificationBox = 'notificationBox';
  static const String syncQueueBox = 'syncQueueBox';
  static const String authBox = 'authBox'; // Untuk simpan session/token

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

  Future<void> logout() async {
    await Hive.box(authBox).delete('currentUser');
  }
}
