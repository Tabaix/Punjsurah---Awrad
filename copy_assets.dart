import 'dart:io';

void main() async {
  final sourceDir = Directory(r'c:\Users\Hp\Downloads\vFlat-20260310T013814Z-3-001\vFlat');
  final destDir = Directory(r'c:\Users\Hp\Downloads\vFlat-20260310T013814Z-3-001\app_files\assets\pages');
  
  if (!destDir.existsSync()) {
    destDir.createSync(recursive: true);
  }
  
  final files = sourceDir.listSync().whereType<File>().where((f) => f.path.toLowerCase().endsWith('.jpg')).toList();
  files.sort((a, b) => a.path.compareTo(b.path));
  
  int i = 1;
  for (var file in files) {
    var destPath = '${destDir.path}\\$i.jpg';
    file.copySync(destPath);
    i++;
  }
  print('Copied ${i-1} files to pages.');
}
