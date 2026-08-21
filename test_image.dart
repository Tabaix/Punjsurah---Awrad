import 'package:image/image.dart' as img;

void main() {
  final image = img.Image(width: 10, height: 10);
  try {
    // Testing encodeJpg as encodeWebP is not supported in image 4.8.0
    final bytes = img.encodeJpg(image);
    // ignore: avoid_print
    print('Success: encodeJpg worked, length: ${bytes.length}');
  } catch (e) {
    // ignore: avoid_print
    print('Error: $e');
  }
}
