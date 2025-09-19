import '../interfaces/points_strategy_interface.dart';

/// 默认积分计算策略 - 遵循开闭原则，保持简单实用
class DefaultPointsStrategy implements IPointsStrategy {
  @override
  int calculatePoints(int consecutiveDays) {
    if (consecutiveDays % 7 == 0) return 50; // 第7天奖励
    if (consecutiveDays % 3 == 0) return 20; // 第3、6天奖励
    return 10; // 基础积分
  }

  @override
  String getDescription(int consecutiveDays) {
    final points = calculatePoints(consecutiveDays);
    if (consecutiveDays % 7 == 0) {
      return '连续签到第${consecutiveDays}天，获得周奖励${points}积分！';
    } else if (consecutiveDays % 3 == 0) {
      return '连续签到第${consecutiveDays}天，获得特别奖励${points}积分！';
    }
    return '签到成功，获得${points}积分';
  }
}