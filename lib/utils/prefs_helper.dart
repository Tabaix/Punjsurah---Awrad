// lib/utils/prefs_helper.dart
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class PrefsHelper {
  PrefsHelper._();

  static const String _keyLastChapterId  = 'last_chapter_id';
  static const String _keyLastPage       = 'last_page';
  static const String _keyBrightness     = 'reader_brightness';
  static const String _keyFontScale      = 'font_scale';
  static const String _keyKeepScreenOn   = 'keep_screen_on';
  static const String _keyRtlLayout     = 'rtl_layout';
  static const String _keyHorizontalNav = 'horizontal_nav';
  static const String _keyBookmarks     = 'bookmarks_list';

  // ─── Last-read bookmarking ───────────────────────────────────────────────────
  static Future<void> saveLastRead(String chapterId, int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastChapterId, chapterId);
    await prefs.setInt(_keyLastPage, page);
  }

  static Future<void> clearLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastChapterId);
    await prefs.remove(_keyLastPage);
  }

  // ─── Bookmarks ─────────────────────────────────────────────────────────────
  
  /// Stores bookmarks as a list of JSON strings: '{"chapterId": "...", "page": 1}'
  static Future<void> toggleBookmark(String chapterId, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_keyBookmarks) ?? [];
    final item = jsonEncode({'chapterId': chapterId, 'page': page});
    
    if (bookmarks.contains(item)) {
      bookmarks.remove(item);
    } else {
      bookmarks.add(item);
    }
    await prefs.setStringList(_keyBookmarks, bookmarks);
  }

  static Future<bool> isBookmarked(String chapterId, int page) async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_keyBookmarks) ?? [];
    final item = jsonEncode({'chapterId': chapterId, 'page': page});
    return bookmarks.contains(item);
  }

  static Future<List<Map<String, dynamic>>> getBookmarks() async {
    final prefs = await SharedPreferences.getInstance();
    final bookmarks = prefs.getStringList(_keyBookmarks) ?? [];
    return bookmarks.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  // ─── Reader settings ─────────────────────────────────────────────────────────

  static Future<double> getBrightness() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyBrightness) ?? 1.0;
  }

  static Future<void> setBrightness(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBrightness, value.clamp(0.0, 1.0));
  }

  static Future<double> getFontScale() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_keyFontScale) ?? 1.0;
  }

  static Future<void> setFontScale(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontScale, value.clamp(0.8, 1.6));
  }

  static Future<bool> getKeepScreenOn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyKeepScreenOn) ?? true;
  }

  static Future<void> setKeepScreenOn(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyKeepScreenOn, value);
  }

  static Future<bool> getRtlLayout() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyRtlLayout) ?? true;
  }

  static Future<void> setRtlLayout(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyRtlLayout, value);
  }

  static Future<bool> getHorizontalNav() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHorizontalNav) ?? true;
  }

  static Future<void> setHorizontalNav(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHorizontalNav, value);
  }
}
