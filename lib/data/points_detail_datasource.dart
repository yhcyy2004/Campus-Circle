import '../core/points_detail_viewmodel.dart';
import '../managers/points_manager.dart';
import '../models/points_transaction.dart';

/// 积分明细数据源实现 - 网络数据源
class NetworkPointsDetailDataSource implements IPointsDetailDataSource {
  const NetworkPointsDetailDataSource(this._pointsManager);

  final IPointsManager _pointsManager;

  @override
  Future<PointsDetailResult> getTransactions(PointsFilter filter) async {
    try {
      final result = await _pointsManager.getTransactionHistory(filter);
      if (result.success) {
        return PointsDetailResult.success(result.data);
      } else {
        return PointsDetailResult.failure(
          result.message ?? '获取交易记录失败',
          result.errorCode,
        );
      }
    } catch (e) {
      return PointsDetailResult.failure('网络异常: $e', 'NETWORK_ERROR');
    }
  }

  @override
  Future<PointsDetailResult> getStatistics() async {
    try {
      final result = await _pointsManager.getStatistics();
      if (result.success) {
        return PointsDetailResult.success(result.data);
      } else {
        return PointsDetailResult.failure(
          result.message ?? '获取统计数据失败',
          result.errorCode,
        );
      }
    } catch (e) {
      return PointsDetailResult.failure('网络异常: $e', 'NETWORK_ERROR');
    }
  }

  @override
  Future<PointsDetailResult> refreshData(PointsFilter filter) async {
    // 刷新时重新获取数据
    return await getTransactions(filter);
  }
}

/// 积分明细数据源工厂
class PointsDetailDataSourceFactory {
  static IPointsDetailDataSource createNetworkDataSource() {
    final pointsManager = PointsManagerFactory.getInstance();
    return NetworkPointsDetailDataSource(pointsManager);
  }

  static IPointsDetailDataSource createMockDataSource() {
    return MockPointsDetailDataSource();
  }
}

/// 模拟数据源 - 用于测试和开发
class MockPointsDetailDataSource implements IPointsDetailDataSource {
  const MockPointsDetailDataSource();
  @override
  Future<PointsDetailResult> getTransactions(PointsFilter filter) async {
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟网络延迟

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
      PointsTransaction(
        id: 'mock_3',
        userId: 'test_user',
        type: PointsTransactionType.earned,
        source: PointsSource.posting,
        amount: 3,
        balanceAfter: 113,
        title: '发布动态',
        description: '发布动态获得积分奖励',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      ),
    ];

    // 根据过滤器筛选数据
    List<PointsTransaction> filteredTransactions = mockTransactions;
    if (filter.type != null) {
      filteredTransactions = mockTransactions
          .where((t) => t.type == filter.type)
          .toList();
    }

    return PointsDetailResult.success({
      'transactions': filteredTransactions,
      'total': filteredTransactions.length,
      'page': filter.page,
      'limit': filter.limit,
    });
  }

  @override
  Future<PointsDetailResult> getStatistics() async {
    await Future.delayed(const Duration(milliseconds: 300));

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
        PointsSource.commenting: 100,
      },
      expenseBySource: {
        PointsSource.purchase: 200,
        PointsSource.exchange: 100,
      },
      dailyHistory: [],
    );

    return PointsDetailResult.success(mockStats);
  }

  @override
  Future<PointsDetailResult> refreshData(PointsFilter filter) async {
    return await getTransactions(filter);
  }
}