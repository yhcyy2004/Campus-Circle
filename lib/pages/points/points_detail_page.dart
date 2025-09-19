import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/points_transaction.dart';
import '../../managers/points_manager.dart';
import '../../core/logger.dart';
import '../../components/tab_controller_factory.dart';

/// 积分明细页面
class PointsDetailPage extends StatefulWidget {
  const PointsDetailPage({Key? key}) : super(key: key);

  @override
  State<PointsDetailPage> createState() => _PointsDetailPageState();
}

class _PointsDetailPageState extends State<PointsDetailPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late IPointsManager _pointsManager;
  late TabControllerManager _tabControllerManager;

  // 数据状态
  List<PointsTransaction> _allTransactions = [];
  List<PointsTransaction> _incomeTransactions = [];
  List<PointsTransaction> _expenseTransactions = [];
  PointsStatisticsData? _statistics;

  // UI状态
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;
  final int _pageSize = 20;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _initializeManagers();
    _tabController = _tabControllerManager.createController(
      length: 3,
      vsync: this,
    );
    _pointsManager = PointsManagerFactory.getInstance();
    _scrollController.addListener(_onScroll);
    _loadInitialData();
  }

  /// 初始化管理器
  void _initializeManagers() {
    _tabControllerManager = TabControllerManager.instance;
    _tabControllerManager.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// 监听滚动事件，实现分页加载
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMoreData) {
        _loadMoreTransactions();
      }
    }
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      await Future.wait([
        _loadStatistics(),
        _loadTransactions(isRefresh: true),
      ]);
    } catch (e) {
      AppLogger.error('PointsDetailPage', '加载初始数据失败', {'error': e.toString()});
      setState(() {
        _errorMessage = '数据加载失败，请稍后重试';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 加载统计数据
  Future<void> _loadStatistics() async {
    final result = await _pointsManager.getStatistics();
    if (result.success && result.data is PointsStatisticsData) {
      setState(() {
        _statistics = result.data;
      });
    }
  }

  /// 加载交易记录
  Future<void> _loadTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      _currentPage = 1;
      _hasMoreData = true;
    }

    final filter = PointsFilter(
      page: _currentPage,
      limit: _pageSize,
    );

    final result = await _pointsManager.getTransactionHistory(filter);
    if (result.success) {
      final data = result.data;
      final transactions = data['transactions'] as List<PointsTransaction>;
      final total = data['total'] as int;

      setState(() {
        if (isRefresh) {
          _allTransactions = transactions;
        } else {
          _allTransactions.addAll(transactions);
        }

        _incomeTransactions = _allTransactions
            .where((t) => t.type == PointsTransactionType.earned)
            .toList();
        _expenseTransactions = _allTransactions
            .where((t) => t.type == PointsTransactionType.spent)
            .toList();

        _hasMoreData = _allTransactions.length < total;
        _currentPage++;
      });
    }
  }

  /// 加载更多交易记录
  Future<void> _loadMoreTransactions() async {
    await _loadTransactions();
  }

  /// 刷新数据
  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _loadInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('积分明细'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey[600],
          indicatorColor: Theme.of(context).primaryColor,
          tabs: const [
            Tab(text: '全部'),
            Tab(text: '收入'),
            Tab(text: '支出'),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildStatisticsCard(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTransactionList(_allTransactions),
                _buildTransactionList(_incomeTransactions),
                _buildTransactionList(_expenseTransactions),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计卡片
  Widget _buildStatisticsCard() {
    if (_statistics == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('当前余额', _statistics!.currentBalance.toString(), '积分'),
              _buildStatItem('总收入', _statistics!.totalIncome.toString(), '积分'),
              _buildStatItem('总支出', _statistics!.totalExpense.toString(), '积分'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('今日收入', _statistics!.todayIncome.toString(), '积分'),
              _buildStatItem('本周收入', _statistics!.weekIncome.toString(), '积分'),
              _buildStatItem('本月收入', _statistics!.monthIncome.toString(), '积分'),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建统计项
  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          unit,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  /// 构建交易记录列表
  Widget _buildTransactionList(List<PointsTransaction> transactions) {
    if (_isLoading && transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && transactions.isEmpty) {
      return _buildErrorWidget();
    }

    if (transactions.isEmpty) {
      return _buildEmptyWidget();
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: transactions.length + (_hasMoreData ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index == transactions.length) {
            return _buildLoadingMoreWidget();
          }
          return _buildTransactionItem(transactions[index]);
        },
      ),
    );
  }

  /// 构建交易记录项
  Widget _buildTransactionItem(PointsTransaction transaction) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 来源图标
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Color(int.parse(transaction.colorHex.substring(1), radix: 16) + 0xFF000000)
                  .withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                transaction.source.icon,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 交易信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (transaction.description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    transaction.description!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  _formatDateTime(transaction.createdAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // 积分数值
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                transaction.displayText,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(int.parse(transaction.colorHex.substring(1), radix: 16) + 0xFF000000),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '余额: ${transaction.balanceAfter}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 构建加载更多组件
  Widget _buildLoadingMoreWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  /// 构建错误组件
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadInitialData,
            child: const Text('重新加载'),
          ),
        ],
      ),
    );
  }

  /// 构建空数据组件
  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            '暂无积分记录',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '完成任务开始赚取积分吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  /// 格式化日期时间
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return '昨天 ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}