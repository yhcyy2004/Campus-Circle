import '../utils/constants.dart';

/// URL验证工具 - 检查API端点是否正确配置
class UrlValidator {
  static void validateApiUrls() {
    final baseUrl = AppConstants.baseUrl;
    print('=== API URL 验证 ===');
    print('Base URL: $baseUrl');
    print('');

    // 积分相关API
    print('积分API端点:');
    print('  - 获取积分概况: $baseUrl/points/profile');
    print('  - 获取积分历史: $baseUrl/points/history');
    print('  - 获取积分统计: $baseUrl/points/statistics');
    print('  - 获取获取方式: $baseUrl/points/earn-ways');
    print('  - 添加积分记录: $baseUrl/points/add [POST]');
    print('');

    // 签到相关API
    print('签到API端点:');
    print('  - 获取签到状态: $baseUrl/checkin/status');
    print('  - 执行签到: $baseUrl/checkin [POST]');
    print('  - 获取签到历史: $baseUrl/checkin/history');
    print('  - 获取签到规则: $baseUrl/checkin/rules');
    print('');

    // 验证URL格式
    final expectedUrls = [
      'http://43.138.4.157:8080/api/v1/points/add',
      'http://43.138.4.157:8080/api/v1/checkin',
    ];

    print('预期的完整URL:');
    for (final url in expectedUrls) {
      print('  - $url');
    }

    print('');
    print('⚠️  注意: baseUrl 已包含 /api/v1，服务中不应再添加');
  }

  /// 检查URL冲突
  static List<String> checkUrlConflicts() {
    final conflicts = <String>[];
    final baseUrl = AppConstants.baseUrl;

    // 检查是否有重复的 /api/v1
    if (baseUrl.contains('/api/v1') && baseUrl.endsWith('/api/v1')) {
      // 这是正确的格式
    } else if (baseUrl.contains('/api/v1')) {
      conflicts.add('baseUrl 包含 /api/v1 但格式可能不正确');
    }

    return conflicts;
  }

  /// 生成正确的API URL
  static String buildApiUrl(String endpoint) {
    final baseUrl = AppConstants.baseUrl;

    // 确保端点以 / 开头
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint.substring(1) : endpoint;

    // 如果 baseUrl 已经包含 /api/v1，直接拼接
    if (baseUrl.contains('/api/v1')) {
      return '$baseUrl/$cleanEndpoint';
    } else {
      // 如果 baseUrl 不包含 /api/v1，需要添加
      return '$baseUrl/api/v1/$cleanEndpoint';
    }
  }

  /// 测试URL构建
  static void testUrlBuilding() {
    print('=== URL 构建测试 ===');

    final testEndpoints = [
      'points/add',
      'checkin',
      'checkin/status',
      'points/profile',
    ];

    for (final endpoint in testEndpoints) {
      final url = buildApiUrl(endpoint);
      print('$endpoint -> $url');
    }
  }
}