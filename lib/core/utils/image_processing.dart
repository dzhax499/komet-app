import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'dart:math' as math;
import 'tflite_helper.dart';

class ImageProcessing {
  static Future<String?> removeWhiteBackground(String inputPath, String outputPath, {bool blackAndWhite = false}) async {
    try {
      final file = File(inputPath);
      final bytes = file.readAsBytesSync();
      var rawImage = img.decodeImage(bytes);
      
      if (rawImage == null) return null;
      img.Image finalImage = rawImage;

      // 1. Lokalisasi Objek dengan TFLite (Agar mematuhi requirement penggunaan tflite_flutter)
      // TFLite mencari lokasi kasar dari karakter (Bounding Box),
      // sehingga kita bisa membuang background di luar kotak tersebut sejak awal.
      try {
        final bbox = await TFLiteHelper.getBoundingBox(finalImage);
        if (bbox != null) {
          debugPrint('TFLite menemukan objek di: ${bbox.left}, ${bbox.top}, ${bbox.width}x${bbox.height}');
          final padding = 40.0;
          final cropX = math.max(0, (bbox.left - padding).toInt());
          final cropY = math.max(0, (bbox.top - padding).toInt());
          final cropW = math.min(finalImage.width - cropX, (bbox.width + padding * 2).toInt());
          final cropH = math.min(finalImage.height - cropY, (bbox.height + padding * 2).toInt());
          
          // Potong gambar menggunakan koordinat dari TFLite
          finalImage = img.copyCrop(finalImage, x: cropX, y: cropY, width: cropW, height: cropH);
        }
      } catch (e) {
        debugPrint('TFLite error: $e');
      }

      // 2. Resize untuk performa (Max 800px) agar memori aman
      if (finalImage.width > 800 || finalImage.height > 800) {
        if (finalImage.width > finalImage.height) {
          finalImage = img.copyResize(finalImage, width: 800);
        } else {
          finalImage = img.copyResize(finalImage, height: 800);
        }
      }

      // 3. Jalankan pengolahan Flood-Fill Berbasis Spatial di Isolate
      final isolateResult = await compute(_processImageIsolate, {
        'width': finalImage.width,
        'height': finalImage.height,
        'imageBytes': finalImage.getBytes(order: img.ChannelOrder.rgba),
        'blackAndWhite': blackAndWhite,
        'outputPath': outputPath,
      });

      return isolateResult ? outputPath : null;
    } catch (e) {
      debugPrint('Error memproses gambar: $e');
      return null;
    }
  }

  static bool _processImageIsolate(Map<String, dynamic> args) {
    try {
      final width = args['width'] as int;
      final height = args['height'] as int;
      final imageBytes = args['imageBytes'] as Uint8List;
      final isBlackAndWhite = args['blackAndWhite'] as bool;
      final outputPath = args['outputPath'] as String;

      var image = img.Image.fromBytes(
        width: width,
        height: height,
        bytes: imageBytes.buffer,
        order: img.ChannelOrder.rgba,
      );

      if (image.numChannels != 4) {
        image = image.convert(numChannels: 4);
      }

      // ==========================================
      // SPATIAL FLOOD-FILL ALGORITHM
      // ==========================================
      // Mengambil palet warna background dari pinggir gambar
      final List<List<int>> bgPalette = [];
      void addColorToPalette(int r, int g, int b) {
        for (final c in bgPalette) {
          if (math.sqrt(math.pow(r - c[0], 2) + math.pow(g - c[1], 2) + math.pow(b - c[2], 2)) < 20) return;
        }
        if (bgPalette.length < 50) bgPalette.add([r, g, b]);
      }

      for (int x = 0; x < width; x += 3) {
        final p1 = image.getPixel(x, 0); addColorToPalette(p1.r.toInt(), p1.g.toInt(), p1.b.toInt());
        final p2 = image.getPixel(x, height - 1); addColorToPalette(p2.r.toInt(), p2.g.toInt(), p2.b.toInt());
      }
      for (int y = 0; y < height; y += 3) {
        final p1 = image.getPixel(0, y); addColorToPalette(p1.r.toInt(), p1.g.toInt(), p1.b.toInt());
        final p2 = image.getPixel(width - 1, y); addColorToPalette(p2.r.toInt(), p2.g.toInt(), p2.b.toInt());
      }

      final queue = <math.Point<int>>[];
      final visited = List<bool>.filled(width * height, false);

      for (int x = 0; x < width; x++) {
        queue.add(math.Point(x, 0)); visited[x] = true;
        queue.add(math.Point(x, height - 1)); visited[x + (height - 1) * width] = true;
      }
      for (int y = 0; y < height; y++) {
        queue.add(math.Point(0, y)); visited[y * width] = true;
        queue.add(math.Point(width - 1, y)); visited[(width - 1) + y * width] = true;
      }

      int head = 0;
      while (head < queue.length) {
        final p = queue[head++];
        final pixel = image.getPixel(p.x, p.y);
        
        // Spatial Tolerance: Lebih ketat di bagian tengah gambar (melindungi objek)
        final depthX = math.min(p.x, width - p.x);
        final depthY = math.min(p.y, height - p.y);
        final distToEdge = math.min(depthX, depthY);
        final dynamicTolerance = math.max(15, 60 - distToEdge); // Tepi luar = 60 (mudah terhapus), Tengah = 15 (sangat ketat)

        bool isBg = false;
        for (final c in bgPalette) {
          final dist = math.sqrt(math.pow(pixel.r - c[0], 2) + math.pow(pixel.g - c[1], 2) + math.pow(pixel.b - c[2], 2));
          if (dist < dynamicTolerance) {
            isBg = true;
            break;
          }
        }

        if (isBg) {
          pixel.a = 0;
          final neighbors = [
            math.Point(p.x + 1, p.y), math.Point(p.x - 1, p.y),
            math.Point(p.x, p.y + 1), math.Point(p.x, p.y - 1),
          ];
          for (final n in neighbors) {
            if (n.x >= 0 && n.x < width && n.y >= 0 && n.y < height) {
              final idx = n.x + n.y * width;
              if (!visited[idx]) {
                visited[idx] = true;
                queue.add(n);
              }
            }
          }
        }
      }

      // Filter Hitam Putih (opsional)
      if (isBlackAndWhite) {
        for (final pixel in image) {
          if (pixel.a > 0) { // Hanya ubah pixel yang tidak transparan
            final lum = pixel.luminance;
            if (lum < 150) {
              pixel.r = 0; pixel.g = 0; pixel.b = 0;
            } else {
              pixel.r = 255; pixel.g = 255; pixel.b = 255;
            }
          }
        }
      }

      // Auto-Crop Bounding Box (hilangkan area transparan berlebih)
      int minX = image.width, minY = image.height, maxX = 0, maxY = 0;
      bool hasVisiblePixels = false;

      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          if (image.getPixel(x, y).a > 0) {
            if (x < minX) minX = x;
            if (x > maxX) maxX = x;
            if (y < minY) minY = y;
            if (y > maxY) maxY = y;
            hasVisiblePixels = true;
          }
        }
      }

      if (hasVisiblePixels) {
        final padding = 10;
        minX = math.max(0, minX - padding);
        minY = math.max(0, minY - padding);
        maxX = math.min(image.width - 1, maxX + padding);
        maxY = math.min(image.height - 1, maxY + padding);
        image = img.copyCrop(image, x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1);
      }

      final pngBytes = img.encodePng(image);
      File(outputPath).writeAsBytesSync(pngBytes);

      return true;
    } catch (e) {
      debugPrint('Isolate error: $e');
      return false;
    }
  }
}
