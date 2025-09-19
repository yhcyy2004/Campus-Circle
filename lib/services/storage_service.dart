import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _preferences;
  
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }
  
  static SharedPreferences get prefs {
    if (_preferences == null) {
      throw Exception('StorageService not initialized. Call StorageService.init() first.');
    }
    return _preferences!;
  }
  
  // 存储字符串
  static Future<bool> setString(String key, String value) {
    return prefs.setString(key, value);
  }
  
  // 获取字符串
  static String? getString(String key, [String? defaultValue]) {
    return prefs.getString(key) ?? defaultValue;
  }
  
  // 存储整数
  static Future<bool> setInt(String key, int value) {
    return prefs.setInt(key, value);
  }
  
  // 获取整数
  static int? getInt(String key, [int? defaultValue]) {
    return prefs.getInt(key) ?? defaultValue;
  }
  
  // 存储布尔值
  static Future<bool> setBool(String key, bool value) {
    return prefs.setBool(key, value);
  }
  
  // 获取布尔值
  static bool? getBool(String key, [bool? defaultValue]) {
    return prefs.getBool(key) ?? defaultValue;
  }
  
  // 存储JSON对象
  static Future<bool> setJson(String key, Map<String, dynamic> value) {
    return setString(key, json.encode(value));
  }
  
  // 获取JSON对象
  static Map<String, dynamic>? getJson(String key) {
    final jsonString = getString(key);
    if (jsonString == null) return null;
    try {
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
  
  // 存储列表
  static Future<bool> setStringList(String key, List<String> value) {
    return prefs.setStringList(key, value);
  }
  
  // 获取列表
  static List<String>? getStringList(String key) {
    return prefs.getStringList(key);
  }
  
  // 删除键
  static Future<bool> remove(String key) {
    return prefs.remove(key);
  }
  
  // 清空所有数据
  static Future<bool> clear() {
    return prefs.clear();
  }
  
  // 检查键是否存在
  static bool containsKey(String key) {
    return prefs.containsKey(key);
  }
  
  // 获取所有键
  static Set<String> getKeys() {
    return prefs.getKeys();
  }
}