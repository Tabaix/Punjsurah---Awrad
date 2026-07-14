import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class QuranDownloadService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _getLocalFile(int surahNumber) async {
    final path = await _localPath;
    return File('$path/surah_$surahNumber.json');
  }

  static Future<bool> isSurahDownloaded(int surahNumber) async {
    final file = await _getLocalFile(surahNumber);
    return await file.exists();
  }

  static Future<Map<String, dynamic>?> getDownloadedSurah(int surahNumber) async {
    try {
      final file = await _getLocalFile(surahNumber);
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content);
      }
    } catch (e) {
      print('Error reading downloaded surah: $e');
    }
    return null;
  }

  static Future<bool> downloadSurah(int surahNumber) async {
    try {
      final url = 'https://api.alquran.cloud/v1/surah/$surahNumber/editions/quran-uthmani,ur.jalandhry';
      final res = await http.get(Uri.parse(url));
      
      if (res.statusCode == 200) {
        final file = await _getLocalFile(surahNumber);
        await file.writeAsString(res.body);
        return true;
      }
    } catch (e) {
      print('Error downloading surah: $e');
    }
    return false;
  }

  static Future<void> deleteSurah(int surahNumber) async {
    final file = await _getLocalFile(surahNumber);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
