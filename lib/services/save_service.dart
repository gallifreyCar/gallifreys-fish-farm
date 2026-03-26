import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/player.dart';

/// 存档服务
class SaveService {
  static const String _saveKey = 'gallifreys_fish_farm_save';

  /// 保存游戏数据
  static Future<void> save(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_saveKey, jsonEncode(data));
  }

  /// 加载游戏数据
  static Future<Player?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_saveKey);
    if (jsonStr == null) return null;

    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      return Player.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  /// 清除存档
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }

  /// 检查是否有存档
  static Future<bool> hasSave() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_saveKey);
  }
}
