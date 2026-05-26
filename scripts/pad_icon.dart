import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/images/logo.png');
  final original = img.decodeImage(file.readAsBytesSync());
  if (original == null) {
    print("Gagal membaca logo.png");
    return;
  }
  
  // Adaptive icons in Android need the logo to be within the inner 66% (approx)
  // We will make the canvas 1.8x the size of the maximum dimension of the logo
  int maxDim = original.width > original.height ? original.width : original.height;
  int newCanvasSize = (maxDim * 1.8).toInt();
  
  final padded = img.Image(width: newCanvasSize, height: newCanvasSize, numChannels: 4); 
  // Transparent background
  img.fill(padded, color: img.ColorUint8.rgba(0, 0, 0, 0));
  
  // Center the original image
  int offsetX = (newCanvasSize - original.width) ~/ 2;
  int offsetY = (newCanvasSize - original.height) ~/ 2;
  
  img.compositeImage(padded, original, dstX: offsetX, dstY: offsetY);
  
  final paddedFile = File('assets/images/logo_padded.png');
  paddedFile.writeAsBytesSync(img.encodePng(padded));
  print('Padded image saved to assets/images/logo_padded.png');
}
