import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../components/points_detail_components.dart';
import '../../core/logger.dart';
import '../../core/points_detail_viewmodel.dart';
import '../../data/points_detail_datasource.dart';
import '../../models/points_transaction.dart';

/// 积分明细页面 - 遵循面向对象设计原则
class ObjectOrientedPointsDetailPage extends StatefulWidget {
  const ObjectOrientedPointsDetailPage({super.key});

  @override
  State<ObjectOrientedPointsDetailPage> createState() => _ObjectOrientedPointsDetailPageState();
}

class _ObjectOrientedPointsDetailPageState extends State<ObjectOrientedPointsDetailPage>
    with TickerProviderStateMixin {

  // 核心组件 - 依赖注入
  late PointsDetailViewModel _viewModel;
  late TabController _tabController;
  late ScrollController _scrollController;

  // UI状态
  int _selectedTabIndex = 0;
  static const String _tag = 'PointsDetailPage';

  // 筛选标签配置
  final List<FilterTab> _filterTabs = const [
    FilterTab(title: '全部', type: null),
    FilterTab(title: '收入', type: PointsTransactionType.earned),
    FilterTab(title: '支出', type: PointsTransactionType.spent),
  ];

  @override
  void initState() {
    super.initState();
    _initializeComponents();
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _viewModel.dispose();
    super.dispose();
  }

  /// 初始化组件 - 依赖注入
  void _initializeComponents() {
    // 创建数据源
    final dataSource = PointsDetailDataSourceFactory.createNetworkDataSource();

    // 创建视图模型
    _viewModel = PointsDetailViewModel(dataSource);

    // 创建UI控制器
    _tabController = TabController(length: _filterTabs.length, vsync: this);
    _scrollController = ScrollController()..addListener(_onScroll);

    AppLogger.info(_tag, '组件初始化完成');
  }

  /// 加载初始数据
  void _loadInitialData() async {
    try {
      await _viewModel.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      AppLogger.error(_tag, '初始化数据失败', {'error': e.toString()});
    }
  }

  /// 滚动监听 - 实现分页加载
  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreData();
    }
  }

  /// 加载更多数据
  void _loadMoreData() async {
    if (_viewModel.hasMoreData && !_viewModel.isLoading && !_viewModel.isLoadingMore) {
      await _viewModel.loadMore();
      if (mounted) {
        setState(() {});
      }
    }
  }

  /// 刷新数据
  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await _viewModel.refresh();
    if (mounted) {
      setState(() {});
    }
  }

  /// 标签切换处理
  void _onTabChanged(int index) {
    if (index != _selectedTabIndex) {
      setState(() {
        _selectedTabIndex = index;
      });

      final selectedTab = _filterTabs[index];
      _viewModel.applyFilter(selectedTab.type);

      AppLogger.debug(_tag, '切换筛选标签', {
        'index': index,
        'type': selectedTab.type?.name ?? 'all'
      });
    }
  }

  /// 交易项点击处理
  void _onTransactionTap(PointsTransaction transaction) {
    AppLogger.debug(_tag, '点击交易记录', {
      'transaction_id': transaction.id,
      'title': transaction.title
    });

    // 可以在这里添加详情页面导航
    _showTransactionDetail(transaction);
  }

  /// 显示交易详情
  void _showTransactionDetail(PointsTransaction transaction) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailBottomSheet(transaction: transaction),
    );
  }

  /// 统计卡片点击处理
  void _onStatisticsCardTap() {
    AppLogger.debug(_tag, '点击统计卡片');
    // 可以导航到详细统计页面
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  /// 构建应用栏
  PreferredSizeWidget _buildAppBar() {
    final filterTabsComponent = FilterTabsComponent(
      tabs: _filterTabs,
      selectedIndex: _selectedTabIndex,
      onTabChanged: _onTabChanged,
      controller: _tabController,
    );

    return AppBar(
      title: const Text('积分明细'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      bottom: filterTabsComponent.buildPreferredSizeWidget(context),
    );
  }

  /// 构建主体内容
  Widget _buildBody() {
    return Column(
      children: [
        // 统计卡片
        PointsStatisticsCard(
          statistics: _viewModel.statistics,
          onTap: _onStatisticsCardTap,
        ).build(context),

        // 交易列表
        Expanded(
          child: _buildTransactionList(),
        ),
      ],
    );
  }

  /// 构建交易列表
  Widget _buildTransactionList() {
    switch (_viewModel.state) {
      case PointsDetailState.initial:
      case PointsDetailState.loading:
        return LoadingStateComponent(message: '加载中...').build(context);

      case PointsDetailState.error:
        return ErrorStateComponent(
          message: _viewModel.errorMessage ?? '加载失败',
          onRetry: _loadInitialData,
        ).build(context);

      case PointsDetailState.loaded:
      case PointsDetailState.refreshing:
      case PointsDetailState.loadingMore:
        return _buildLoadedContent();
    }
  }

  /// 构建已加载内容
  Widget _buildLoadedContent() {
    final transactions = _viewModel.transactions;

    if (transactions.isEmpty) {
      return EmptyStateComponent(
        title: '暂无积分记录',
        subtitle: '完成任务开始赚取积分吧！',
        icon: Icons.receipt_long_outlined,
      ).build(context);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: transactions.length + (_viewModel.hasMoreData ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == transactions.length) {
            return _buildLoadingMoreIndicator();
          }

          return PointsTransactionItem(
            transaction: transactions[index],
            onTap: () => _onTransactionTap(transactions[index]),
          ).build(context);
        },
      ),
    );
  }

  /// 构建加载更多指示器
  Widget _buildLoadingMoreIndicator() {
    if (_viewModel.isLoadingMore) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: const Center(child: CircularProgressIndicator()),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}

/// 交易详情底部弹窗
class TransactionDetailBottomSheet extends StatelessWidget {
  const TransactionDetailBottomSheet({
    super.key,
    required this.transaction,
  });

  final PointsTransaction transaction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖拽指示器
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // 标题
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              '交易详情',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          // 详情内容
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailItem('交易ID', transaction.id),
                _buildDetailItem('标题', transaction.title),
                if (transaction.description != null)
                  _buildDetailItem('描述', transaction.description!),
                _buildDetailItem('积分变化', transaction.displayText),
                _buildDetailItem('交易后余额', '${transaction.balanceAfter}积分'),
                _buildDetailItem('来源', '${transaction.source.icon} ${transaction.source.displayName}'),
                _buildDetailItem('时间', _formatFullDateTime(transaction.createdAt)),
              ],
            ),
          ),

          // 关闭按钮
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('关闭'),
              ),
            ),
          ),

          // 底部安全区域
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDateTime(DateTime dateTime) {
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} '
           '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
  }
}