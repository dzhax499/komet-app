import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TFLiteHelper {
  static Interpreter? _interpreter;
  static const int _inputSize = 300; // Typical input size for SSD MobileNet
  
  static Future<void> loadModel() async {
    try {
      _interpreter ??= await Interpreter.fromAsset('assets/models/detect.tflite');
      debugPrint("Model TFLite berhasil dimuat.");
    } catch (e) {
      debugPrint("Gagal memuat model TFLite: $e");
    }
  }

  /// Menjalankan model object detection TFLite dan mereturn koordinat crop.
  /// Jika tidak ada objek yang terdeteksi dengan skor > 0.5, return null.
  static Future<math.Rectangle<int>?> getBoundingBox(img.Image image) async {
    if (_interpreter == null) {
      await loadModel();
    }
    
    if (_interpreter == null) return null;

    try {
      // 1. Pre-processing: Resize gambar sesuai ukuran input model
      img.Image resizedImage = img.copyResize(image, width: _inputSize, height: _inputSize);

      // Buat Tensor Input: [1, 300, 300, 3]
      // Model SSD MobileNet (quantized) umumnya menggunakan input uint8.
      var input = List.generate(
        1, 
        (i) => List.generate(
          _inputSize, 
          (y) => List.generate(
            _inputSize, 
            (x) {
              final pixel = resizedImage.getPixel(x, y);
              return [pixel.r.toInt(), pixel.g.toInt(), pixel.b.toInt()];
            }
          )
        )
      );

      // 2. Output Tensor:
      // TFLite SSD MobileNet output format:
      // 0: [1, 10, 4] - Bounding Box (ymin, xmin, ymax, xmax)
      // 1: [1, 10] - Classes
      // 2: [1, 10] - Scores
      // 3: [1] - Number of detections
      
      var outputLocations = List.generate(1, (i) => List.generate(10, (j) => List.filled(4, 0.0)));
      var outputClasses = List.generate(1, (i) => List.filled(10, 0.0));
      var outputScores = List.generate(1, (i) => List.filled(10, 0.0));
      var numDetections = List.filled(1, 0.0);

      Map<int, Object> outputs = {
        0: outputLocations,
        1: outputClasses,
        2: outputScores,
        3: numDetections,
      };

      // 3. Inferensi
      _interpreter!.runForMultipleInputs([input], outputs);

      // 4. Post-processing: Ambil bounding box dengan score tertinggi
      double maxScore = outputScores[0][0];
      if (maxScore > 0.3) {
        // Lokasi dalam skala 0.0 - 1.0
        double ymin = outputLocations[0][0][0];
        double xmin = outputLocations[0][0][1];
        double ymax = outputLocations[0][0][2];
        double xmax = outputLocations[0][0][3];

        // Konversi ke piksel asli
        int x = (xmin * image.width).toInt();
        int y = (ymin * image.height).toInt();
        int w = ((xmax - xmin) * image.width).toInt();
        int h = ((ymax - ymin) * image.height).toInt();
        
        // Pastikan tidak out-of-bounds
        x = math.max(0, x);
        y = math.max(0, y);
        w = math.min(image.width - x, w);
        h = math.min(image.height - y, h);

        return math.Rectangle<int>(x, y, w, h);
      }
      return null;
    } catch (e) {
      debugPrint("Error saat inferensi TFLite: $e");
      return null;
    }
  }
}
