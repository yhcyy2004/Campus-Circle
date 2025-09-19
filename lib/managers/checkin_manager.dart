import '../interfaces/checkin_storage_interface.dart';
import '../interfaces/points_strategy_interface.dart';
import '../models/points_transaction.dart';
import '../core/logger.dart';
import 'points_manager.dart';

/// 签到状态数据类
class CheckinStatus {
  final bool hasCheckedInToday;
  final int consecutiveDays;
  final int todayPoints;
  final String message;

  CheckinStatus({
    required this.hasCheckedInToday,
    required this.consecutiveDays,
    required this.todayPoints,
    required this.message,
  });
}

/// 签到结果数据类
class CheckinResult {
  final bool success;
  final String message;
  final int earnedPoints;
  final int consecutiveDays;
  final String? transactionId;

  CheckinResult({
    required this.success,
    required this.message,
    required this.earnedPoints,
    required this.consecutiveDays,
    this.transactionId,
  });
}

/// 签到管理器接口
abstract class ICheckinManager {
  Future<CheckinStatus> getCheckinStatus(String userId);
  Future<CheckinResult> performCheckin(String userId);
  Future<List<Map<String, dynamic>>> getCheckinHistory(String userId);
}

/// 签到管理器 - 遵循单一职责原则，集成积分系统
class CheckinManager implements ICheckinManager {
  final ICheckinStorage _storage;
  final IPointsStrategy _pointsStrategy;
  final IPointsManager _pointsManager;
  static const String _tag = 'CheckinManager';

  CheckinManager(this._storage, this._pointsStrategy, this._pointsManager);

  /// 获取用户签到状态
  @override
  Future<CheckinStatus> getCheckinStatus(String userId) async {
    try {
      AppLogger.debug(_tag, '获取用户签到状态', {'userId': userId});

      final today = DateTime.now().toIso8601String().split('T')[0];
      final lastCheckinDate = await _storage.getLastCheckinDate(userId);
      final consecutiveDays = await _storage.getConsecutiveDays(userId);

      final hasCheckedInToday = lastCheckinDate == today;
      final nextDays = consecutiveDays + 1;
      final todayPoints = _pointsStrategy.calculatePoints(nextDays);

      final message = hasCheckedInToday
          ? '今日已签到 · 连续${consecutiveDays}天'
          : '今日可获得${todayPoints}积分';

      AppLogger.info(_tag, '获取签到状态成功', {
        'userId': userId,
        'hasCheckedInToday': hasCheckedInToday,
        'consecutiveDays': consecutiveDays,
        'todayPoints': todayPoints,
      });

      return CheckinStatus(
        hasCheckedInToday: hasCheckedInToday,
        consecutiveDays: consecutiveDays,
        todayPoints: todayPoints,
        message: message,
      );
    } catch (e) {
      AppLogger.error(_tag, '获取签到状态失败', {'userId': userId, 'error': e.toString()});
      rethrow;
    }
  }

  /// 执行签到
  @override
  Future<CheckinResult> performCheckin(String userId) async {
    try {
      AppLogger.info(_tag, '开始执行签到', {'userId': userId});

      final today = DateTime.now().toIso8601String().split('T')[0];
      final yesterday = DateTime.now().subtract(const Duration(days: 1)).toIso8601String().split('T')[0];

      // 检查是否已经签到
      final lastCheckinDate = await _storage.getLastCheckinDate(userId);
      if (lastCheckinDate == today) {
        AppLogger.warning(_tag, '今日已签到', {'userId': userId, 'lastCheckinDate': lastCheckinDate});
        return CheckinResult(
          success: false,
          message: '今日已签到',
          earnedPoints: 0,
          consecutiveDays: await _storage.getConsecutiveDays(userId),
        );
      }

      // 计算连续签到天数
      final currentConsecutive = await _storage.getConsecutiveDays(userId);
      final newConsecutiveDays = (lastCheckinDate == yesterday) ? currentConsecutive + 1 : 1;

      // 计算积分
      final earnedPoints = _pointsStrategy.calculatePoints(newConsecutiveDays);

      AppLogger.info(_tag, '计算签到积分', {
        'userId': userId,
        'consecutiveDays': newConsecutiveDays,
        'earnedPoints': earnedPoints,
      });

      // 添加积分记录
      String? transactionId;
      final pointsRequest = PointsTransactionRequest(
        amount: earnedPoints,
        source: PointsSource.dailyCheckin,
        sourceId: today,
        title: '每日签到',
        description: '连续签到第${newConsecutiveDays}天',
        metadata: {
          'consecutive_days': newConsecutiveDays,
          'checkin_date': today,
        },
      );

      final pointsResult = await _pointsManager.addTransaction(pointsRequest);
      if (pointsResult.success) {
        transactionId = pointsResult.data?['id'];
        AppLogger.logPointsTransaction(
          operation: '签到获得积分',
          userId: userId,
          amount: earnedPoints,
          source: PointsSource.dailyCheckin.value,
          success: true,
          extra: {
            'consecutive_days': newConsecutiveDays,
            'transaction_id': transactionId,
          },
        );
      } else {
        AppLogger.logPointsTransaction(
          operation: '签到获得积分',
          userId: userId,
          amount: earnedPoints,
          source: PointsSource.dailyCheckin.value,
          success: false,
          errorMessage: pointsResult.message,
        );
        return CheckinResult(
          success: false,
          message: pointsResult.message ?? '积分添加失败',
          earnedPoints: 0,
          consecutiveDays: currentConsecutive,
        );
      }

      // 保存签到数据
      await _storage.setLastCheckinDate(userId, today);
      await _storage.setConsecutiveDays(userId, newConsecutiveDays);

      // 保存历史记录
      await _storage.saveCheckinHistory(userId, {
        'date': today,
        'points': earnedPoints,
        'consecutiveDays': newConsecutiveDays,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'transaction_id': transactionId,
      });

      final message = _pointsStrategy.getDescription(newConsecutiveDays);

      AppLogger.logCheckinAction(
        action: '签到成功',
        userId: userId,
        consecutiveDays: newConsecutiveDays,
        pointsEarned: earnedPoints,
        success: true,
        extra: {
          'transaction_id': transactionId,
          'checkin_date': today,
        },
      );

      return CheckinResult(
        success: true,
        message: message,
        earnedPoints: earnedPoints,
        consecutiveDays: newConsecutiveDays,
        transactionId: transactionId,
      );
    } catch (e) {
      AppLogger.logCheckinAction(
        action: '签到失败',
        userId: userId,
        success: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  /// 获取签到历史
  @override
  Future<List<Map<String, dynamic>>> getCheckinHistory(String userId) async {
    try {
      AppLogger.debug(_tag, '获取签到历史', {'userId': userId});
      final history = await _storage.getCheckinHistory(userId);
      AppLogger.info(_tag, '获取签到历史成功', {'userId': userId, 'count': history.length});
      return history;
    } catch (e) {
      AppLogger.error(_tag, '获取签到历史失败', {'userId': userId, 'error': e.toString()});
      rethrow;
    }
  }
}
