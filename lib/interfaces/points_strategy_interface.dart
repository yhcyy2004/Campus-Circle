/// 积分计算策略接口 - 遵循策略模式
abstract class IPointsStrategy {
  int calculatePoints(int consecutiveDays);
  String getDescription(int consecutiveDays);
}