import '../managers/checkin_manager.dart';
import '../managers/points_manager.dart';
import '../services/auth_service.dart';
import '../storage/local_checkin_storage.dart';
import '../strategies/points_strategy.dart';

/// 依赖注入容器 - 简化版本，遵循依赖倒置原则
class DIContainer {
  DIContainer._internal();

  factory DIContainer() => _instance;

  static final DIContainer _instance = DIContainer._internal();

  // 懒加载单例
  CheckinManager? _checkinManager;
  PointsManager? _pointsManager;

  /// 获取签到管理器
  CheckinManager get checkinManager {
    _checkinManager ??= CheckinManager(
      LocalCheckinStorage(),
      DefaultPointsStrategy(),
      pointsManager,
    );
    return _checkinManager!;
  }

  /// 获取积分管理器
  PointsManager get pointsManager {
    _pointsManager ??= PointsManager(AuthService());
    return _pointsManager!;
  }

  /// 清理实例（用于测试或重置）
  void reset() {
    _checkinManager = null;
    _pointsManager = null;
  }
}