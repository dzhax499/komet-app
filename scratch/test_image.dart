import 'package:image/image.dart' as img;

void main() async {
  var image = img.Image(width: 10, height: 10, numChannels: 3);
  if (!image.hasAlpha) {
    image = image.convert(numChannels: 4);
  }
  print(image.hasAlpha);
}
