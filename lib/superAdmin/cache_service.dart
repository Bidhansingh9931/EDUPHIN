import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SuperAdminCacheService {
  static const String _prefix = 'super_admin_cache_';

  static Future<void> save(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefix + key, json.encode(data));
  }

  static Future<void> saveList(String key, List<dynamic> data) async {
    await save(key, data);
  }

  static Future<dynamic> load(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_prefix + key);
    if (cached != null) {
      try {
        return json.decode(cached);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  static Future<List<dynamic>?> loadList(String key) async {
    final data = await load(key);
    return data is List ? data : null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }
}
