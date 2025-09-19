import 'package:flutter/material.dart';
import '../models/points_transaction.dart';
import 'tab_controller_factory.dart';

/// 积分明细UI组件接口 - 使用mixin更符合Flutter设计原则
mixin PointsDetailComponentMixin {
  Widget build(BuildContext context);
}

/// 统计卡片组件
class PointsStatisticsCard with PointsDetailComponentMixin {
  const PointsStatisticsCard({
    required this.statistics,
    this.onTap,
  });

  final PointsStatisticsData? statistics;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    if (statistics == null) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('当前余额', statistics!.currentBalance.toString(), '积分'),
                _buildStatItem('总收入', statistics!.totalIncome.toString(), '积分'),
                _buildStatItem('总支出', statistics!.totalExpense.toString(), '积分'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('今日收入', statistics!.todayIncome.toString(), '积分'),
                _buildStatItem('本周收入', statistics!.weekIncome.toString(), '积分'),
                _buildStatItem('本月收入', statistics!.monthIncome.toString(), '积分'),
              ],
            ),
          ],
        ),
      ),
    );
  }

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
}

/// 交易记录项组件
class PointsTransactionItem with PointsDetailComponentMixin {
  const PointsTransactionItem({
    required this.transaction,
    this.onTap,
  });

  final PointsTransaction transaction;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            // 来源图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Color(int.parse(transaction.colorHex.substring(1), radix: 16) + 0xFF000000)
                    .withValues(alpha: 0.1),
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
      ),
    );
  }

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

/// 空状态组件
class EmptyStateComponent with PointsDetailComponentMixin {
  const EmptyStateComponent({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onRefresh,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          if (onRefresh != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('重新加载'),
            ),
          ],
        ],
      ),
    );
  }
}

/// 加载状态组件
class LoadingStateComponent with PointsDetailComponentMixin {
  const LoadingStateComponent({this.message});

  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 16),
            Text(
              message!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 错误状态组件
class ErrorStateComponent with PointsDetailComponentMixin {
  const ErrorStateComponent({
    required this.message,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
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
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ],
        ],
      ),
    );
  }
}

/// 增强的筛选标签栏组件 - 遵循面向对象原则
class FilterTabsComponent with PointsDetailComponentMixin {
  const FilterTabsComponent({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
    this.controller,
    this.builder,
  });

  final List<FilterTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;
  final TabController? controller;
  final TabBarBuilder? builder;

  @override
  Widget build(BuildContext context) {
    // 如果没有提供controller，则使用DefaultTabController包装
    if (controller == null) {
      return DefaultTabController(
        length: tabs.length,
        initialIndex: selectedIndex,
        child: Container(
          color: Colors.white,
          child: _buildTabBar(context),
        ),
      );
    }

    return Container(
      color: Colors.white,
      child: _buildTabBar(context),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    final tabConfigs = tabs.map((tab) => DefaultTabConfig(title: tab.title)).toList();
    final tabBuilder = builder ?? ThemedTabBarBuilder();

    // 如果有controller，直接使用
    if (controller != null) {
      return tabBuilder.buildTabBar(
        controller: controller!,
        tabs: tabConfigs,
        context: context,
      );
    }

    // 否则使用DefaultTabController.of
    return TabBar(
      tabs: tabs.map((tab) => Tab(text: tab.title)).toList(),
      labelColor: Theme.of(context).primaryColor,
      unselectedLabelColor: Colors.grey[600],
      indicatorColor: Theme.of(context).primaryColor,
      onTap: onTabChanged,
    );
  }

  /// 创建适用于AppBar.bottom的PreferredSizeWidget
  PreferredSizeWidget buildPreferredSizeWidget(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(48),
      child: build(context),
    );
  }
}

/// 筛选标签数据类
class FilterTab {
  const FilterTab({
    required this.title,
    this.type,
  });

  final String title;
  final PointsTransactionType? type;
}