import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class QuranDownloadService {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  // --- TEXT DOWNLOAD LOGIC ---

  static Future<File> _getTextFile(int number, String translation, {bool isJuz = false}) async {
    final path = await _localPath;
    final prefix = isJuz ? 'juz' : 'surah';
    return File('$path/${prefix}_${number}_$translation.json');
  }

  static Future<bool> isSurahDownloaded(int surahNumber, String translation) async {
    final file = await _getTextFile(surahNumber, translation);
    return await file.exists();
  }

  static Future<bool> isJuzDownloaded(int juzNumber, String translation) async {
    final file = await _getTextFile(juzNumber, translation, isJuz: true);
    return await file.exists();
  }

  static Future<Map<String, dynamic>?> getDownloadedSurah(int surahNumber, String translation) async {
    try {
      final file = await _getTextFile(surahNumber, translation);
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content);
      }
    } catch (e) {
      debugPrint('Error reading downloaded surah: $e');
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getDownloadedJuz(int juzNumber, String translation) async {
    try {
      final file = await _getTextFile(juzNumber, translation, isJuz: true);
      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content);
      }
    } catch (e) {
      debugPrint('Error reading downloaded juz: $e');
    }
    return null;
  }

  static Future<bool> downloadSurahText(int surahNumber, String translation) async {
    try {
      final url = 'https://api.alquran.cloud/v1/surah/$surahNumber/editions/quran-uthmani,$translation,quran-wordbyword-2';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final file = await _getTextFile(surahNumber, translation);
        await file.writeAsString(res.body);
        return true;
      }
    } catch (e) {
      debugPrint('Error downloading surah: $e');
    }
    return false;
  }

  static Future<bool> downloadJuzText(int juzNumber, String translation) async {
    try {
      final url = 'https://api.alquran.cloud/v1/juz/$juzNumber/editions/quran-uthmani,$translation,quran-wordbyword-2';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final file = await _getTextFile(juzNumber, translation, isJuz: true);
        await file.writeAsString(res.body);
        return true;
      }
    } catch (e) {
      debugPrint('Error downloading juz: $e');
    }
    return false;
  }

  // --- AUDIO DOWNLOAD LOGIC ---

  static Future<String> getAudioPath(int ayahNumber, String reciter) async {
    final path = await _localPath;
    final dir = Directory('$path/audio/$reciter');
    if (!await dir.exists()) await dir.create(recursive: true);
    return '${dir.path}/$ayahNumber.mp3';
  }

  static Future<bool> isAyahAudioDownloaded(int ayahNumber, String reciter) async {
    final path = await getAudioPath(ayahNumber, reciter);
    return await File(path).exists();
  }

  static Future<bool> downloadAyahAudio(int ayahNumber, String reciter) async {
    try {
      final filePath = await getAudioPath(ayahNumber, reciter);
      final file = File(filePath);
      if (await file.exists()) return true;

      final url = 'https://cdn.islamic.network/quran/audio/128/$reciter/$ayahNumber.mp3';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        await file.writeAsBytes(res.bodyBytes);
        return true;
      }
    } catch (e) {
      debugPrint('Audio download error: $e');
    }
    return false;
  }

  static Future<void> deleteSurah(int surahNumber, String translation) async {
    final file = await _getTextFile(surahNumber, translation);
    if (await file.exists()) await file.delete();
  }
}
