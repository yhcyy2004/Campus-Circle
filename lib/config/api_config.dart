/// API配置类 - 与server.js保持一致
class ApiConfig {
  // 服务器配置
  static const String baseUrl = 'http://localhost:8080';
  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // 完整的API基础URL
  static const String fullBaseUrl = '$baseUrl$apiPrefix';

  // 请求超时配置
  static const int connectTimeout = 30000; // 30秒
  static const int receiveTimeout = 30000; // 30秒

  // 认证相关
  static const String authHeaderKey = 'Authorization';
  static const String authTokenPrefix = 'Bearer ';

  // API端点 - 与server.js路由保持一致
  static const String auth = '/auth';
  static const String user = '/user';
  static const String sections = '/sections';
  static const String tasks = '/tasks';
  static const String checkin = '/checkin';
  static const String points = '/points';
  static const String health = '/health';

  // 认证端点
  static const String loginEndpoint = '$auth/login';
  static const String registerEndpoint = '$auth/register';
  static const String logoutEndpoint = '$auth/logout';
  static const String checkStudentNumberEndpoint = '$auth/check-student-number';
  static const String checkEmailEndpoint = '$auth/check-email';

  // 用户端点
  static const String userProfileEndpoint = '$user/profile';

  // 分区端点
  static const String sectionsListEndpoint = sections;
  static const String createSectionEndpoint = sections;
  static String sectionDetailEndpoint(String sectionId) => '$sections/$sectionId';
  static String joinSectionEndpoint(String sectionId) => '$sections/$sectionId/join';
  static String leaveSectionEndpoint(String sectionId) => '$sections/$sectionId/leave';

  // 分区帖子端点
  static String sectionPostsEndpoint(String sectionId) => '$sections/$sectionId/posts';
  static String sectionPostDetailEndpoint(String sectionId, String postId) =>
      '$sections/$sectionId/posts/$postId';
  static String createSectionPostEndpoint(String sectionId) => '$sections/$sectionId/posts';
  static String likeSectionPostEndpoint(String sectionId, String postId) =>
      '$sections/$sectionId/posts/$postId/like';
  static String commentSectionPostEndpoint(String sectionId, String postId) =>
      '$sections/$sectionId/posts/$postId/comments';

  // 任务端点
  static const String tasksListEndpoint = tasks;
  static const String createTaskEndpoint = tasks;
  static const String taskCategoriesEndpoint = '/task-categories';
  static String taskDetailEndpoint(String taskId) => '$tasks/$taskId';
  static String joinTaskEndpoint(String taskId) => '$tasks/$taskId/join';

  // 签到端点
  static const String checkinStatusEndpoint = '$checkin/status';
  static const String performCheckinEndpoint = checkin;
  static const String checkinHistoryEndpoint = '$checkin/history';
  static const String checkinRulesEndpoint = '$checkin/rules';

  // 积分端点
  static const String pointsProfileEndpoint = '$points/profile';
  static const String pointsHistoryEndpoint = '$points/history';
  static const String pointsStatisticsEndpoint = '$points/statistics';
  static const String pointsEarnWaysEndpoint = '$points/earn-ways';
  static const String addPointsEndpoint = '$points/add';

  // 健康检查端点
  static const String healthCheckEndpoint = health;

  // 分页默认参数
  static const int defaultPage = 1;
  static const int defaultLimit = 20;

  // 内容类型
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 环境配置
  static const bool isProduction = false;
  static const bool enableLogging = !isProduction;

  /// 获取完整的API URL
  static String getFullUrl(String endpoint) {
    return '$fullBaseUrl$endpoint';
  }

  /// 获取带认证头的Headers
  static Map<String, String> getAuthHeaders(String? token) {
    final headers = Map<String, String>.from(jsonHeaders);
    if (token != null && token.isNotEmpty) {
      headers[authHeaderKey] = '$authTokenPrefix$token';
    }
    return headers;
  }
}