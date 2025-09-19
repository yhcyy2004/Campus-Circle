class PointsModel {
  final String id;
  final String userId;
  final int type; // 1-获得, 2-消费
  final String sourceType;
  final String? sourceId;
  final int points;
  final int balanceAfter;
  final String title;
  final String? description;
  final String? operatorId;
  final DateTime createdAt;

  PointsModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.sourceType,
    this.sourceId,
    required this.points,
    required this.balanceAfter,
    required this.title,
    this.description,
    this.operatorId,
    required this.createdAt,
  });

  factory PointsModel.fromJson(Map<String, dynamic> json) {
    return PointsModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      type: json['type'] ?? 1,
      sourceType: json['source_type'] ?? '',
      sourceId: json['source_id'],
      points: json['points'] ?? 0,
      balanceAfter: json['balance_after'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      operatorId: json['operator_id'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'source_type': sourceType,
      'source_id': sourceId,
      'points': points,
      'balance_after': balanceAfter,
      'title': title,
      'description': description,
      'operator_id': operatorId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  bool get isEarned => type == 1;
  bool get isSpent => type == 2;

  String get typeText => isEarned ? '获得' : '消费';
  String get pointsText => '${isEarned ? '+' : '-'}$points';
}

class PointsProfile {
  final int totalPoints;
  final int todayEarned;
  final int weekEarned;
  final int monthEarned;
  final int level;
  final int levelProgress;
  final int nextLevelPoints;

  PointsProfile({
    required this.totalPoints,
    required this.todayEarned,
    required this.weekEarned,
    required this.monthEarned,
    required this.level,
    required this.levelProgress,
    required this.nextLevelPoints,
  });

  factory PointsProfile.fromJson(Map<String, dynamic> json) {
    return PointsProfile(
      totalPoints: json['total_points'] ?? 0,
      todayEarned: json['today_earned'] ?? 0,
      weekEarned: json['week_earned'] ?? 0,
      monthEarned: json['month_earned'] ?? 0,
      level: json['level'] ?? 1,
      levelProgress: json['level_progress'] ?? 0,
      nextLevelPoints: json['next_level_points'] ?? 0,
    );
  }
}

class PointsStatistics {
  final int totalEarned;
  final int totalSpent;
  final int currentBalance;
  final Map<String, int> earnedBySource;
  final Map<String, int> spentBySource;
  final List<DailyPoints> dailyHistory;

  PointsStatistics({
    required this.totalEarned,
    required this.totalSpent,
    required this.currentBalance,
    required this.earnedBySource,
    required this.spentBySource,
    required this.dailyHistory,
  });

  factory PointsStatistics.fromJson(Map<String, dynamic> json) {
    return PointsStatistics(
      totalEarned: json['total_earned'] ?? 0,
      totalSpent: json['total_spent'] ?? 0,
      currentBalance: json['current_balance'] ?? 0,
      earnedBySource: Map<String, int>.from(json['earned_by_source'] ?? {}),
      spentBySource: Map<String, int>.from(json['spent_by_source'] ?? {}),
      dailyHistory: (json['daily_history'] as List<dynamic>?)
              ?.map((item) => DailyPoints.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class DailyPoints {
  final DateTime date;
  final int earned;
  final int spent;
  final int balance;

  DailyPoints({
    required this.date,
    required this.earned,
    required this.spent,
    required this.balance,
  });

  factory DailyPoints.fromJson(Map<String, dynamic> json) {
    return DailyPoints(
      date: DateTime.parse(json['date']),
      earned: json['earned'] ?? 0,
      spent: json['spent'] ?? 0,
      balance: json['balance'] ?? 0,
    );
  }
}

class PointsEarnWay {
  final String sourceType;
  final String title;
  final String description;
  final int points;
  final String? conditions;
  final int? dailyLimit;
  final bool isActive;

  PointsEarnWay({
    required this.sourceType,
    required this.title,
    required this.description,
    required this.points,
    this.conditions,
    this.dailyLimit,
    this.isActive = true,
  });

  factory PointsEarnWay.fromJson(Map<String, dynamic> json) {
    return PointsEarnWay(
      sourceType: json['source_type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      points: json['points'] ?? 0,
      conditions: json['conditions'],
      dailyLimit: json['daily_limit'],
      isActive: json['is_active'] ?? true,
    );
  }
}