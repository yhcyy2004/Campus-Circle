import 'dart:developer' as developer;
import '../models/points_transaction.dart';
import '../managers/points_manager.dart';
import '../core/logger.dart';

/// 积分系统测试类
class PointsSystemTest {
  static const String _tag = 'PointsSystemTest';

  /// 运行所有测试
  static Future<void> runAllTests() async {
    AppLogger.info(_tag, '开始运行积分系统测试');

    try {
      await _testPointsTransactionModel();
      await _testPointsFilter();
      await _testPointsStatistics();
      await _testPointsManager();
      await _testLogger();

      AppLogger.info(_tag, '所有测试完成！');
      developer.log('✅ 积分系统测试全部通过！', name: _tag);
    } catch (e) {
      AppLogger.error(_tag, '测试失败', {'error': e.toString()});
      developer.log('❌ 积分系统测试失败: $e', name: _tag);
      rethrow;
    }
  }

  /// 测试积分交易模型
  static Future<void> _testPointsTransactionModel() async {
    AppLogger.info(_tag, '测试积分交易模型');

    // 测试创建交易记录
    final transaction = PointsTransaction(
      id: 'test_id_001',
      userId: 'user_123',
      type: PointsTransactionType.earned,
      source: PointsSource.dailyCheckin,
      amount: 10,
      balanceAfter: 100,
      title: '每日签到',
      description: '连续签到第1天',
      createdAt: DateTime.now(),
    );

    // 测试属性
    assert(transaction.isIncome == true, '应该是收入类型');
    assert(transaction.isExpense == false, '不应该是支出类型');
    assert(transaction.displayText == '+10', '显示文本应该是+10');
    assert(transaction.colorHex == '#4CAF50', '收入颜色应该是绿色');

    // 测试序列化
    final json = transaction.toJson();
    final fromJson = PointsTransaction.fromJson(json);
    assert(fromJson.id == transaction.id, 'ID应该相等');
    assert(fromJson.amount == transaction.amount, '金额应该相等');

    AppLogger.info(_tag, '积分交易模型测试通过');
  }

  /// 测试积分过滤器
  static Future<void> _testPointsFilter() async {
    AppLogger.info(_tag, '测试积分过滤器');

    final filter = PointsFilter(
      type: PointsTransactionType.earned,
      source: PointsSource.dailyCheckin,
      startDate: DateTime(2024, 1, 1),
      endDate: DateTime(2024, 12, 31),
      page: 2,
      limit: 30,
    );

    final params = filter.toQueryParams();
    assert(params['type'] == '1', '类型参数应该正确');
    assert(params['source_type'] == 'daily_checkin', '来源类型参数应该正确');
    assert(params['page'] == '2', '页码参数应该正确');
    assert(params['limit'] == '30', '每页数量参数应该正确');

    AppLogger.info(_tag, '积分过滤器测试通过');
  }

  /// 测试积分统计
  static Future<void> _testPointsStatistics() async {
    AppLogger.info(_tag, '测试积分统计');

    final mockData = {
      'total_earned': 1000,
      'total_spent': 300,
      'current_balance': 700,
      'today_earned': 20,
      'week_earned': 100,
      'month_earned': 500,
      'earned_by_source': {
        'daily_checkin': 200,
        'post_publish': 300,
        'comment_publish': 100,
      },
      'spent_by_source': {
        'purchase': 200,
        'exchange': 100,
      },
      'daily_history': [
        {
          'date': '2024-01-01',
          'earned': 10,
          'spent': 5,
          'balance': 705,
        }
      ],
    };

    final statistics = PointsStatisticsData.fromJson(mockData);
    assert(statistics.totalIncome == 1000, '总收入应该正确');
    assert(statistics.totalExpense == 300, '总支出应该正确');
    assert(statistics.netIncome == 700, '净收入应该正确');
    assert(statistics.incomeExpenseRatio == 1000 / 300, '收支比例应该正确');
    assert(statistics.incomeBySource[PointsSource.dailyCheckin] == 200, '按来源收入统计应该正确');

    AppLogger.info(_tag, '积分统计测试通过');
  }

  /// 测试积分管理器（模拟）
  static Future<void> _testPointsManager() async {
    AppLogger.info(_tag, '测试积分管理器（模拟）');

    // 创建模拟的积分管理器
    final mockManager = MockPointsManager();

    // 测试获取交易历史
    final filter = PointsFilter(page: 1, limit: 10);
    final historyResult = await mockManager.getTransactionHistory(filter);
    assert(historyResult.success == true, '获取交易历史应该成功');

    // 测试获取统计数据
    final statsResult = await mockManager.getStatistics();
    assert(statsResult.success == true, '获取统计数据应该成功');

    // 测试添加交易记录
    final request = PointsTransactionRequest(
      amount: 10,
      source: PointsSource.dailyCheckin,
      title: '测试签到',
      description: '测试描述',
    );
    final addResult = await mockManager.addTransaction(request);
    assert(addResult.success == true, '添加交易记录应该成功');

    AppLogger.info(_tag, '积分管理器测试通过');
  }

  /// 测试日志系统
  static Future<void> _testLogger() async {
    AppLogger.info(_tag, '测试日志系统');

    // 清空日志
    AppLogger.clearLogs();
    assert(AppLogger.getLogs().isEmpty, '日志应该为空');

    // 测试不同级别的日志
    AppLogger.debug(_tag, '调试日志', {'test': 'debug'});
    AppLogger.info(_tag, '信息日志', {'test': 'info'});
    AppLogger.warning(_tag, '警告日志', {'test': 'warning'});
    AppLogger.error(_tag, '错误日志', {'test': 'error'});

    final logs = AppLogger.getLogs();
    assert(logs.length >= 4, '应该有至少4条日志');

    // 测试积分交易专用日志
    AppLogger.logPointsTransaction(
      operation: '测试积分操作',
      userId: 'test_user',
      amount: 10,
      source: 'test_source',
      success: true,
    );

    // 测试签到专用日志
    AppLogger.logCheckinAction(
      action: '测试签到',
      userId: 'test_user',
      consecutiveDays: 5,
      pointsEarned: 10,
      success: true,
    );

    AppLogger.info(_tag, '日志系统测试通过');
  }
}

/// 模拟积分管理器（用于测试）
class MockPointsManager implements IPointsManager {
  @override
  Future<PointsOperationResult> getTransactionHistory(PointsFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 100));

    final mockTransactions = [
      PointsTransaction(
        id: 'mock_1',
        userId: 'test_user',
        type: PointsTransactionType.earned,
        source: PointsSource.dailyCheckin,
        amount: 10,
        balanceAfter: 110,
        title: '每日签到',
        description: '连续签到第1天',
        createdAt: DateTime.now(),
      ),
      PointsTransaction(
        id: 'mock_2',
        userId: 'test_user',
        type: PointsTransactionType.spent,
        source: PointsSource.purchase,
        amount: 50,
        balanceAfter: 60,
        title: '商城购买',
        description: '购买道具',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];

    return PointsOperationResult.success({
      'transactions': mockTransactions,
      'total': mockTransactions.length,
      'page': filter.page,
      'limit': filter.limit,
    });
  }

  @override
  Future<PointsOperationResult> getStatistics() async {
    await Future.delayed(const Duration(milliseconds: 100));

    final mockStats = PointsStatisticsData(
      totalIncome: 1000,
      totalExpense: 300,
      currentBalance: 700,
      todayIncome: 20,
      weekIncome: 100,
      monthIncome: 500,
      incomeBySource: {
        PointsSource.dailyCheckin: 200,
        PointsSource.posting: 300,
      },
      expenseBySource: {
        PointsSource.purchase: 200,
        PointsSource.exchange: 100,
      },
      dailyHistory: [],
    );

    return PointsOperationResult.success(mockStats);
  }

  @override
  Future<PointsOperationResult> getUserProfile() async {
    await Future.delayed(const Duration(milliseconds: 100));

    return PointsOperationResult.success({
      'total_points': 700,
      'level': 5,
      'today_earned': 20,
      'week_earned': 100,
      'month_earned': 500,
    });
  }

  @override
  Future<PointsOperationResult> addTransaction(PointsTransactionRequest request) async {
    await Future.delayed(const Duration(milliseconds: 100));

    return PointsOperationResult.success({
      'id': 'new_transaction_id',
      'points': request.amount,
      'total_points': 710,
    }, '积分添加成功');
  }
}