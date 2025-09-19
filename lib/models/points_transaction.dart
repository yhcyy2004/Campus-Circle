/// 积分交易记录详细模型
/// 遵循面向对象设计原则，支持扩展而不修改
class PointsTransaction {
  final String id;
  final String userId;
  final PointsTransactionType type;
  final PointsSource source;
  final String? sourceId;
  final int amount;
  final int balanceAfter;
  final String title;
  final String? description;
  final String? operatorId;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  PointsTransaction({
    required this.id,
    required this.userId,
    required this.type,
    required this.source,
    this.sourceId,
    required this.amount,
    required this.balanceAfter,
    required this.title,
    this.description,
    this.operatorId,
    required this.createdAt,
    this.metadata,
  });

  factory PointsTransaction.fromJson(Map<String, dynamic> json) {
    return PointsTransaction(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: PointsTransactionType.fromValue(json['type'] ?? 1),
      source: PointsSource.fromValue(json['source_type'] ?? ''),
      sourceId: json['source_id'],
      amount: json['points'] ?? 0,
      balanceAfter: json['balance_after'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      operatorId: json['operator_id'],
      createdAt: DateTime.parse(json['created_at']),
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type.value,
      'source_type': source.value,
      'source_id': sourceId,
      'points': amount,
      'balance_after': balanceAfter,
      'title': title,
      'description': description,
      'operator_id': operatorId,
      'created_at': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// 获取显示文本
  String get displayText => '${type.displayText}$amount';

  /// 获取颜色标识
  String get colorHex => type.colorHex;

  /// 是否为收入
  bool get isIncome => type == PointsTransactionType.earned;

  /// 是否为支出
  bool get isExpense => type == PointsTransactionType.spent;
}

/// 积分交易类型枚举
enum PointsTransactionType {
  earned(1, '获得', '+', '#4CAF50'),
  spent(2, '消费', '-', '#F44336');

  const PointsTransactionType(this.value, this.displayName, this.displayText, this.colorHex);

  final int value;
  final String displayName;
  final String displayText;
  final String colorHex;

  static PointsTransactionType fromValue(int value) {
    return PointsTransactionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => PointsTransactionType.earned,
    );
  }
}

/// 积分来源枚举
enum PointsSource {
  dailyCheckin('daily_checkin', '每日签到', '📅'),
  posting('post_publish', '发布动态', '📝'),
  commenting('comment_publish', '评论互动', '💬'),
  liking('like_action', '点赞活动', '👍'),
  sharing('share_action', '分享内容', '🔗'),
  eventParticipation('event_join', '活动参与', '🎪'),
  levelUpgrade('level_upgrade', '等级提升', '⭐'),
  systemReward('system_reward', '系统奖励', '🎁'),
  adminGrant('admin_grant', '管理员发放', '👨‍💼'),
  purchase('purchase', '商城消费', '🛒'),
  exchange('exchange', '积分兑换', '🔄'),
  manual('manual', '手动操作', '✋'),
  other('other', '其他', '❓');

  const PointsSource(this.value, this.displayName, this.icon);

  final String value;
  final String displayName;
  final String icon;

  static PointsSource fromValue(String value) {
    return PointsSource.values.firstWhere(
      (source) => source.value == value,
      orElse: () => PointsSource.other,
    );
  }
}

/// 积分统计数据
class PointsStatisticsData {
  final int totalIncome;
  final int totalExpense;
  final int currentBalance;
  final int todayIncome;
  final int weekIncome;
  final int monthIncome;
  final Map<PointsSource, int> incomeBySource;
  final Map<PointsSource, int> expenseBySource;
  final List<DailyPointsData> dailyHistory;

  PointsStatisticsData({
    required this.totalIncome,
    required this.totalExpense,
    required this.currentBalance,
    required this.todayIncome,
    required this.weekIncome,
    required this.monthIncome,
    required this.incomeBySource,
    required this.expenseBySource,
    required this.dailyHistory,
  });

  factory PointsStatisticsData.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> incomeSourceData = json['earned_by_source'] ?? {};
    final Map<String, dynamic> expenseSourceData = json['spent_by_source'] ?? {};

    return PointsStatisticsData(
      totalIncome: json['total_earned'] ?? 0,
      totalExpense: json['total_spent'] ?? 0,
      currentBalance: json['current_balance'] ?? 0,
      todayIncome: json['today_earned'] ?? 0,
      weekIncome: json['week_earned'] ?? 0,
      monthIncome: json['month_earned'] ?? 0,
      incomeBySource: _parseSourceData(incomeSourceData),
      expenseBySource: _parseSourceData(expenseSourceData),
      dailyHistory: (json['daily_history'] as List<dynamic>?)
              ?.map((item) => DailyPointsData.fromJson(item))
              .toList() ??
          [],
    );
  }

  static Map<PointsSource, int> _parseSourceData(Map<String, dynamic> data) {
    final Map<PointsSource, int> result = {};
    data.forEach((key, value) {
      final source = PointsSource.fromValue(key);
      result[source] = value as int;
    });
    return result;
  }

  /// 净收入
  int get netIncome => totalIncome - totalExpense;

  /// 收支比例
  double get incomeExpenseRatio =>
      totalExpense > 0 ? totalIncome / totalExpense : double.infinity;
}

/// 每日积分数据
class DailyPointsData {
  final DateTime date;
  final int income;
  final int expense;
  final int balance;

  DailyPointsData({
    required this.date,
    required this.income,
    required this.expense,
    required this.balance,
  });

  factory DailyPointsData.fromJson(Map<String, dynamic> json) {
    return DailyPointsData(
      date: DateTime.parse(json['date']),
      income: json['earned'] ?? 0,
      expense: json['spent'] ?? 0,
      balance: json['balance'] ?? 0,
    );
  }

  /// 净变化
  int get netChange => income - expense;
}

/// 积分过滤器
class PointsFilter {
  final PointsTransactionType? type;
  final PointsSource? source;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int limit;

  PointsFilter({
    this.type,
    this.source,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 20,
  });

  Map<String, dynamic> toQueryParams() {
    final Map<String, dynamic> params = {
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (type != null) {
      params['type'] = type!.value.toString();
    }
    if (source != null) {
      params['source_type'] = source!.value;
    }
    if (startDate != null) {
      params['start_date'] = startDate!.toIso8601String();
    }
    if (endDate != null) {
      params['end_date'] = endDate!.toIso8601String();
    }

    return params;
  }
}