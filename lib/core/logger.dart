import 'dart:convert';
import 'dart:developer' as developer;

/// 日志级别枚举
enum LogLevel {
  debug(0, 'DEBUG', '🐛'),
  info(1, 'INFO', 'ℹ️'),
  warning(2, 'WARNING', '⚠️'),
  error(3, 'ERROR', '❌'),
  fatal(4, 'FATAL', '💀');

  const LogLevel(this.value, this.name, this.icon);

  final int value;
  final String name;
  final String icon;
}

/// 应用日志记录器
class AppLogger {
  static LogLevel _minLevel = LogLevel.debug;
  static bool _enabled = true;
  static final List<LogEntry> _logs = [];
  static const int _maxLogs = 1000;

  /// 设置最小日志级别
  static void setMinLevel(LogLevel level) {
    _minLevel = level;
  }

  /// 启用/禁用日志
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// 获取所有日志
  static List<LogEntry> getLogs() => List.unmodifiable(_logs);

  /// 清空日志
  static void clearLogs() {
    _logs.clear();
  }

  /// 调试日志
  static void debug(String tag, String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.debug, tag, message, data);
  }

  /// 信息日志
  static void info(String tag, String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.info, tag, message, data);
  }

  /// 警告日志
  static void warning(String tag, String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.warning, tag, message, data);
  }

  /// 错误日志
  static void error(String tag, String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.error, tag, message, data);
  }

  /// 致命错误日志
  static void fatal(String tag, String message, [Map<String, dynamic>? data]) {
    _log(LogLevel.fatal, tag, message, data);
  }

  /// 内部日志记录方法
  static void _log(LogLevel level, String tag, String message, Map<String, dynamic>? data) {
    if (!_enabled || level.value < _minLevel.value) {
      return;
    }

    final timestamp = DateTime.now();
    final logEntry = LogEntry(
      level: level,
      tag: tag,
      message: message,
      data: data,
      timestamp: timestamp,
    );

    // 添加到内存中的日志列表
    _logs.add(logEntry);
    if (_logs.length > _maxLogs) {
      _logs.removeAt(0);
    }

    // 输出到控制台
    final formattedMessage = _formatMessage(logEntry);
    developer.log(
      formattedMessage,
      name: tag,
      level: _getDeveloperLogLevel(level),
      time: timestamp,
    );
  }

  /// 格式化日志消息
  static String _formatMessage(LogEntry entry) {
    final buffer = StringBuffer();
    buffer.write('${entry.level.icon} [${entry.level.name}] ');
    buffer.write(entry.message);

    if (entry.data != null && entry.data!.isNotEmpty) {
      try {
        final dataJson = jsonEncode(entry.data);
        buffer.write(' | Data: $dataJson');
      } catch (e) {
        buffer.write(' | Data: ${entry.data.toString()}');
      }
    }

    return buffer.toString();
  }

  /// 转换为开发者日志级别
  static int _getDeveloperLogLevel(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
      case LogLevel.fatal:
        return 1200;
    }
  }

  /// 积分操作专用日志方法
  static void logPointsTransaction({
    required String operation,
    required String userId,
    int? amount,
    String? source,
    bool? success,
    String? errorMessage,
    Map<String, dynamic>? extra,
  }) {
    final data = <String, dynamic>{
      'operation': operation,
      'user_id': userId,
      if (amount != null) 'amount': amount,
      if (source != null) 'source': source,
      if (success != null) 'success': success,
      if (errorMessage != null) 'error': errorMessage,
      if (extra != null) ...extra,
    };

    if (success == false || errorMessage != null) {
      error('PointsTransaction', '积分操作失败: $operation', data);
    } else {
      info('PointsTransaction', '积分操作: $operation', data);
    }
  }

  /// 签到操作专用日志方法
  static void logCheckinAction({
    required String action,
    required String userId,
    int? consecutiveDays,
    int? pointsEarned,
    bool? success,
    String? errorMessage,
    Map<String, dynamic>? extra,
  }) {
    final data = <String, dynamic>{
      'action': action,
      'user_id': userId,
      if (consecutiveDays != null) 'consecutive_days': consecutiveDays,
      if (pointsEarned != null) 'points_earned': pointsEarned,
      if (success != null) 'success': success,
      if (errorMessage != null) 'error': errorMessage,
      if (extra != null) ...extra,
    };

    if (success == false || errorMessage != null) {
      error('CheckinAction', '签到操作失败: $action', data);
    } else {
      info('CheckinAction', '签到操作: $action', data);
    }
  }
}

/// 日志条目
class LogEntry {
  LogEntry({
    required this.level,
    required this.tag,
    required this.message,
    this.data,
    required this.timestamp,
  });

  factory LogEntry.fromJson(Map<String, dynamic> json) {
    return LogEntry(
      level: LogLevel.values.firstWhere(
        (l) => l.name == json['level'],
        orElse: () => LogLevel.info,
      ),
      tag: json['tag'] ?? '',
      message: json['message'] ?? '',
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  final LogLevel level;
  final String tag;
  final String message;
  final Map<String, dynamic>? data;
  final DateTime timestamp;

  Map<String, dynamic> toJson() {
    return {
      'level': level.name,
      'tag': tag,
      'message': message,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  @override
  String toString() {
    return '${timestamp.toIso8601String()} [${level.name}] $tag: $message';
  }
}