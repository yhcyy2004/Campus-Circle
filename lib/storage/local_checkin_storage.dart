import 'dart:convert';
import '../interfaces/checkin_storage_interface.dart';
import '../services/storage_service.dart';

/// 本地存储实现 - 遵循开闭原则，可扩展为其他存储方式
class LocalCheckinStorage implements ICheckinStorage {
  @override
  Future<String?> getLastCheckinDate(String userId) async {
    return StorageService.getString('last_checkin_date_$userId');
  }

  @override
  Future<void> setLastCheckinDate(String userId, String date) async {
    await StorageService.setString('last_checkin_date_$userId', date);
  }

  @override
  Future<int> getConsecutiveDays(String userId) async {
    return StorageService.getInt('consecutive_checkin_days_$userId') ?? 0;
  }

  @override
  Future<void> setConsecutiveDays(String userId, int days) async {
    await StorageService.setInt('consecutive_checkin_days_$userId', days);
  }

  @override
  Future<void> saveCheckinHistory(String userId, Map<String, dynamic> record) async {
    final historyKey = 'checkin_history_$userId';
    final existingHistory = StorageService.getString(historyKey);

    List<Map<String, dynamic>> history = [];
    if (existingHistory != null && existingHistory.isNotEmpty) {
      final decoded = json.decode(existingHistory);
      if (decoded is List) {
        history = List<Map<String, dynamic>>.from(decoded);
      }
    }

    // 检查是否已经有今天的记录
    final existingIndex = history.indexWhere((item) => item['date'] == record['date']);
    if (existingIndex == -1) {
      history.insert(0, record);

      // 只保留最近30天的记录
      if (history.length > 30) {
        history = history.take(30).toList();
      }

      await StorageService.setString(historyKey, json.encode(history));
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getCheckinHistory(String userId) async {
    final historyKey = 'checkin_history_$userId';
    final existingHistory = StorageService.getString(historyKey);

    if (existingHistory != null && existingHistory.isNotEmpty) {
      final decoded = json.decode(existingHistory);
      if (decoded is List) {
        return List<Map<String, dynamic>>.from(decoded);
      }
    }
    return [];
  }
}