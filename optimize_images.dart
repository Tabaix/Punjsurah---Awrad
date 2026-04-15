import 'dart:io';
import 'package:image/image.dart' as img;

/// Professional Image Optimizer Script for Awrad App
/// Converts all JPG/PNG pages to WebP to shrink APK size by ~70%
void main() async {
  final List<String> targetDirs = [
    'assets/pages',
    'assets/panjsurah/yaseen',
    'assets/panjsurah/kehf',
    'assets/panjsurah/rehman',
    'assets/panjsurah/waqia',
    'assets/panjsurah/mulk',
    'assets/panjsurah/fatah',
    'assets/panjsurah/muzzamil',
    'assets/panjsurah/deen',
    'assets/panjsurah/baqrah',
    'assets/panjsurah/fatiha',
    'assets/panjsurah/falaq',
    'assets/panjsurah/kursi',
    'assets/panjsurah/hashar',
    'assets/panjsurah/kalma',
    'assets/panjsurah/kalmaastaghfar',
    'assets/panjsurah/darood',
    'assets/panjsurah/dua',
    'assets/panjsurah/nama',
    'assets/panjsurah/nimzazkar',
    'assets/panjsurah/zikar',
    'assets/panjsurah/kafal',
    'assets/panjsurah/hajat',
    'assets/panjsurah/khajgan',
    'assets/panjsurah/kull2',
    'assets/panjsurah/bakhsish',
    'assets/panjsurah/izkar',
    'assets/panjsurah/sawab',
    'assets/panjsurah/shifamahi',
    'assets/panjsurah/tajtunjina',
    'assets/panjsurah/mufassil',
  ];

  print('🚀 Starting Professional Image Optimization...');
  int totalFiles = 0;
  int optimizedFiles = 0;

  for (var dirPath in targetDirs) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) continue;

    final files = dir.listSync().whereType<File>().where((f) {
      final path = f.path.toLowerCase();
      return path.endsWith('.jpg') || path.endsWith('.png');
    }).toList();

    for (var file in files) {
      totalFiles++;
      final bytes = file.readAsBytesSync();
      final image = img.decodeImage(bytes);

      if (image != null) {
        // Optimization: Convert to WebP with 80% quality (best balance)
        final webpBytes = img.encodeWebP(image, quality: 80);
        
        // Create new filename: image.jpg -> image.webp
        final newPath = file.path.replaceAll(RegExp(r'\.(jpg|png)$'), '.webp');
        
        File(newPath).writeAsBytesSync(webpBytes);
        
        // Delete original heavy file
        file.deleteSync();
        optimizedFiles++;
        print('✅ Optimized: ${file.path.split(Platform.pathSeparator).last} -> WebP');
      }
    }
  }

  print('\n✨ Optimization Complete!');
  print('📊 Total images found: $totalFiles');
  print('📦 Total images converted to WebP: $optimizedFiles');
  print('⚠️ IMPORTANT: Now update your chapters_data.dart to look for .webp files.');
}
