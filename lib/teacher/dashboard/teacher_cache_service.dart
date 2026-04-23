import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherCacheService {
  static Future<void> save(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('teacher_$key', jsonEncode(data));
  }

  static Future<dynamic> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final String? cached = prefs.getString('teacher_$key');
    if (cached != null) {
      return jsonDecode(cached);
    }
    return null;
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('teacher_$key');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('teacher_'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
