import 'package:image_picker/image_picker.dart';

class CameraHelper {
  static final ImagePicker _picker = ImagePicker();
  static Future<String?> takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      return photo?.path;
    } catch (e) {
      print('Gagal membuka kamera: $e');
      return null;
    }
  }
}
