import '../models/points_transaction.dart';

/// 积分明细数据接口 - 抽象数据源
abstract class IPointsDetailDataSource {
  Future<PointsDetailResult> getTransactions(PointsFilter filter);
  Future<PointsDetailResult> getStatistics();
  Future<PointsDetailResult> refreshData(PointsFilter filter);
}

/// 积分明细结果包装类
class PointsDetailResult {
  final bool success;
  final String? message;
  final dynamic data;
  final String? errorCode;

  PointsDetailResult({
    required this.success,
    this.message,
    this.data,
    this.errorCode,
  });

  factory PointsDetailResult.success(dynamic data, [String? message]) {
    return PointsDetailResult(success: true, data: data, message: message);
  }

  factory PointsDetailResult.failure(String message, [String? errorCode]) {
    return PointsDetailResult(success: false, message: message, errorCode: errorCode);
  }
}

/// 积分明细状态枚举
enum PointsDetailState {
  initial,
  loading,
  loaded,
  error,
  refreshing,
  loadingMore,
}

/// 积分明细视图模型 - 业务逻辑层
class PointsDetailViewModel {
  final IPointsDetailDataSource _dataSource;

  // 状态管理
  PointsDetailState _state = PointsDetailState.initial;
  String? _errorMessage;

  // 数据管理
  List<PointsTransaction> _allTransactions = [];
  List<PointsTransaction> _filteredTransactions = [];
  PointsStatisticsData? _statistics;

  // 分页管理
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;

  // 过滤器
  PointsFilter _currentFilter = PointsFilter();

  PointsDetailViewModel(this._dataSource);

  // Getters
  PointsDetailState get state => _state;
  String? get errorMessage => _errorMessage;
  List<PointsTransaction> get transactions => _filteredTransactions;
  PointsStatisticsData? get statistics => _statistics;
  bool get hasMoreData => _hasMoreData;
  bool get isLoading => _state == PointsDetailState.loading || _state == PointsDetailState.refreshing;
  bool get isLoadingMore => _state == PointsDetailState.loadingMore;

  /// 初始化数据
  Future<void> initialize() async {
    await _loadInitialData();
  }

  /// 刷新数据
  Future<void> refresh() async {
    _setState(PointsDetailState.refreshing);
    _currentPage = 1;
    _hasMoreData = true;
    await _loadInitialData();
  }

  /// 加载更多数据
  Future<void> loadMore() async {
    if (!_hasMoreData || isLoading || isLoadingMore) return;

    _setState(PointsDetailState.loadingMore);
    _currentPage++;

    final filter = _currentFilter.copyWith(page: _currentPage);
    final result = await _dataSource.getTransactions(filter);

    if (result.success) {
      final newTransactions = result.data['transactions'] as List<PointsTransaction>;
      final total = result.data['total'] as int;

      _allTransactions.addAll(newTransactions);
      _applyFilter();
      _hasMoreData = _allTransactions.length < total;
      _setState(PointsDetailState.loaded);
    } else {
      _currentPage--; // 回滚页码
      _setError(result.message ?? '加载更多失败');
    }
  }

  /// 应用过滤器
  void applyFilter(PointsTransactionType? type) {
    _currentFilter = _currentFilter.copyWith(type: type);
    _applyFilter();
  }

  /// 内部方法 - 加载初始数据
  Future<void> _loadInitialData() async {
    _setState(PointsDetailState.loading);

    try {
      // 并行加载统计数据和交易记录
      final results = await Future.wait([
        _dataSource.getStatistics(),
        _dataSource.getTransactions(_currentFilter.copyWith(page: 1)),
      ]);

      final statisticsResult = results[0];
      final transactionsResult = results[1];

      if (statisticsResult.success) {
        _statistics = statisticsResult.data;
      }

      if (transactionsResult.success) {
        final data = transactionsResult.data;
        _allTransactions = data['transactions'] as List<PointsTransaction>;
        final total = data['total'] as int;
        _hasMoreData = _allTransactions.length < total;
        _applyFilter();
        _setState(PointsDetailState.loaded);
      } else {
        _setError(transactionsResult.message ?? '加载数据失败');
      }
    } catch (e) {
      _setError('加载数据异常: $e');
    }
  }

  /// 应用过滤条件
  void _applyFilter() {
    if (_currentFilter.type == null) {
      _filteredTransactions = List.from(_allTransactions);
    } else {
      _filteredTransactions = _allTransactions
          .where((t) => t.type == _currentFilter.type)
          .toList();
    }
  }

  /// 设置状态
  void _setState(PointsDetailState newState) {
    _state = newState;
    _errorMessage = null;
  }

  /// 设置错误状态
  void _setError(String message) {
    _state = PointsDetailState.error;
    _errorMessage = message;
  }

  /// 释放资源
  void dispose() {
    _allTransactions.clear();
    _filteredTransactions.clear();
    _statistics = null;
  }
}

/// PointsFilter 扩展方法
extension PointsFilterExtension on PointsFilter {
  PointsFilter copyWith({
    PointsTransactionType? type,
    PointsSource? source,
    DateTime? startDate,
    DateTime? endDate,
    int? page,
    int? limit,
  }) {
    return PointsFilter(
      type: type ?? this.type,
      source: source ?? this.source,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }
}