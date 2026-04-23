import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _prefix = 'cache_';

  static Future<void> setCache(String key, dynamic data) async {
    final prefs = await SharedPreferences.getInstance();
    String jsonString = jsonEncode(data);
    await prefs.setString(_prefix + key, jsonString);
  }

  static Future<dynamic> getCache(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String? jsonString = prefs.getString(_prefix + key);
    if (jsonString != null) {
      return jsonDecode(jsonString);
    }
    return null;
  }

  static Future<void> saveData(String key, dynamic data) => setCache(key, data);
  static Future<dynamic> getData(String key) => getCache(key);

  static Future<void> removeData(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefix + key);
  }

  static Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys();
    for (String key in keys) {
      if (key.startsWith(_prefix)) {
        await prefs.remove(key);
      }
    }
  }

  static Future<void> clearAll() => clearCache();
}

class CachingService extends CacheService {
  static Future<void> setCache(String key, dynamic data) => CacheService.setCache(key, data);
  static Future<dynamic> getCache(String key) => CacheService.getCache(key);
  static Future<void> saveData(String key, dynamic data) => CacheService.saveData(key, data);
  static Future<dynamic> getData(String key) => CacheService.getData(key);
}
