class CheckinModel {
  final String id;
  final String userId;
  final DateTime checkinDate;
  final int consecutiveDays;
  final int pointsEarned;
  final DateTime createdAt;

  CheckinModel({
    required this.id,
    required this.userId,
    required this.checkinDate,
    required this.consecutiveDays,
    required this.pointsEarned,
    required this.createdAt,
  });

  factory CheckinModel.fromJson(Map<String, dynamic> json) {
    return CheckinModel(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      checkinDate: DateTime.parse(json['checkin_date']),
      consecutiveDays: json['consecutive_days'] ?? 0,
      pointsEarned: json['points_earned'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'checkin_date': checkinDate.toIso8601String(),
      'consecutive_days': consecutiveDays,
      'points_earned': pointsEarned,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class CheckinStatus {
  final bool hasCheckedInToday;
  final int consecutiveDays;
  final int totalCheckinDays;
  final int todayPoints;
  final int tomorrowPoints;
  final DateTime? lastCheckinDate;
  final DateTime? nextCheckinDate;

  CheckinStatus({
    required this.hasCheckedInToday,
    required this.consecutiveDays,
    required this.totalCheckinDays,
    required this.todayPoints,
    required this.tomorrowPoints,
    this.lastCheckinDate,
    this.nextCheckinDate,
  });

  factory CheckinStatus.fromJson(Map<String, dynamic> json) {
    return CheckinStatus(
      hasCheckedInToday: json['has_checked_in_today'] ?? false,
      consecutiveDays: json['consecutive_days'] ?? 0,
      totalCheckinDays: json['total_checkin_days'] ?? 0,
      todayPoints: json['today_points'] ?? 0,
      tomorrowPoints: json['tomorrow_points'] ?? 0,
      lastCheckinDate: json['last_checkin_date'] != null
          ? DateTime.parse(json['last_checkin_date'])
          : null,
      nextCheckinDate: json['next_checkin_date'] != null
          ? DateTime.parse(json['next_checkin_date'])
          : null,
    );
  }
}

class CheckinRule {
  final int day;
  final int points;
  final String description;
  final bool isBonus;

  CheckinRule({
    required this.day,
    required this.points,
    required this.description,
    this.isBonus = false,
  });

  factory CheckinRule.fromJson(Map<String, dynamic> json) {
    return CheckinRule(
      day: json['day'] ?? 0,
      points: json['points'] ?? 0,
      description: json['description'] ?? '',
      isBonus: json['is_bonus'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'points': points,
      'description': description,
      'is_bonus': isBonus,
    };
  }
}