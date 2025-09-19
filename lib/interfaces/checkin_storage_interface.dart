/// 签到存储接口 - 遵循依赖倒置原则
abstract class ICheckinStorage {
  /// 获取用户最后签到日期
  Future<String?> getLastCheckinDate(String userId);

  /// 保存用户签到日期
  Future<void> setLastCheckinDate(String userId, String date);

  /// 获取连续签到天数
  Future<int> getConsecutiveDays(String userId);

  /// 保存连续签到天数
  Future<void> setConsecutiveDays(String userId, int days);

  /// 保存签到历史记录
  Future<void> saveCheckinHistory(String userId, Map<String, dynamic> record);

  /// 获取签到历史记录
  Future<List<Map<String, dynamic>>> getCheckinHistory(String userId);
}