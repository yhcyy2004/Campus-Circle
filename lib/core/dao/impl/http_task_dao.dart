import 'dart:convert';
import 'package:http/http.dart' as http;
import '../task_dao.dart';
import '../../../models/task_model.dart';
import '../../models/result.dart';
import '../../../config/api_config.dart';
import '../../../utils/auth_manager.dart';

/// 任务DAO的HTTP实现
class HttpTaskDAO implements TaskDAO {
  static const String baseUrl = ApiConfig.baseUrl;

  /// 获取认证头
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthManager.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// 处理HTTP响应
  ApiResult<T> _handleResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return ApiResult.success(fromJson(data['data']));
        } else {
          return ApiResult.failure(data['message'] ?? '请求失败');
        }
      } catch (e) {
        return ApiResult.failure('响应解析失败: $e');
      }
    } else {
      try {
        final data = json.decode(response.body);
        return ApiResult.failure(data['message'] ?? 'HTTP ${response.statusCode}');
      } catch (e) {
        return ApiResult.failure('HTTP ${response.statusCode}');
      }
    }
  }

  /// 处理列表响应
  ApiResult<List<T>> _handleListResponse<T>(
    http.Response response,
    T Function(Map<String, dynamic>) fromJson,
    String listKey,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          final List<dynamic> items = data['data'][listKey] ?? [];
          final List<T> result = items.map((item) => fromJson(item)).toList();
          return ApiResult.success(result);
        } else {
          return ApiResult.failure(data['message'] ?? '请求失败');
        }
      } catch (e) {
        return ApiResult.failure('响应解析失败: $e');
      }
    } else {
      try {
        final data = json.decode(response.body);
        return ApiResult.failure(data['message'] ?? 'HTTP ${response.statusCode}');
      } catch (e) {
        return ApiResult.failure('HTTP ${response.statusCode}');
      }
    }
  }

  @override
  Future<ApiResult<TaskListResponse>> getTasks({
    int page = 1,
    int limit = 20,
    String? category,
    String? status,
    String? sort,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status;
      if (sort != null) queryParams['sort'] = sort;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse('$baseUrl/api/v1/tasks').replace(queryParameters: queryParams);
      final response = await http.get(uri);

      return _handleResponse(response, (data) => TaskListResponse.fromJson(data));
    } catch (e) {
      return ApiResult.failure('网络请求失败: $e');
    }
  }

  @override
  Future<ApiResult<Task>> getTaskDetail(String taskId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/v1/tasks/$taskId');
      final response = await http.get(uri);

      return _handleResponse(response, (data) => Task.fromJson(data));
    } catch (e) {
      return ApiResult.failure('网络请求失败: $e');
    }
  }

  @override
  Future<ApiResult<Task>> createTask(CreateTaskRequest request) async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('$baseUrl/api/v1/tasks');
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      return _handleResponse(response, (data) => Task.fromJson(data));
    } catch (e) {
      return ApiResult.failure('网络请求失败: $e');
    }
  }

  @override
  Future<ApiResult<TaskApplication>> applyForTask(String taskId, CreateTaskApplicationRequest request) async {
    try {
      final headers = await _getAuthHeaders();
      final uri = Uri.parse('$baseUrl/api/v1/tasks/$taskId/join');
      final response = await http.post(
        uri,
        headers: headers,
        body: json.encode(request.toJson()),
      );

      return _handleResponse(response, (data) => TaskApplication.fromJson(data));
    } catch (e) {
      return ApiResult.failure('网络请求失败: $e');
    }
  }

  // 以下方法在server.js中暂未实现，提供占位符实现
  @override
  Future<ApiResult<Task>> updateTask(String taskId, Map<String, dynamic> updates) async {
    return ApiResult.failure('任务更新功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<void>> deleteTask(String taskId) async {
    return ApiResult.failure('任务删除功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<List<TaskApplication>>> getTaskApplications(String taskId) async {
    return ApiResult.failure('获取任务申请列表功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<TaskApplication>> handleTaskApplication(String applicationId, bool accept, String? reason) async {
    return ApiResult.failure('处理任务申请功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<List<TaskApplication>>> getMyApplications({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    return ApiResult.failure('获取我的申请列表功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<List<Task>>> getMyTasks({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    return ApiResult.failure('获取我的任务列表功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<void>> toggleTaskFavorite(String taskId) async {
    return ApiResult.failure('收藏任务功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<List<Task>>> getFavoriteTasks({
    int page = 1,
    int limit = 20,
  }) async {
    return ApiResult.failure('获取收藏任务列表功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<TaskExecution>> updateTaskProgress(String taskId, int progress, String? notes) async {
    return ApiResult.failure('更新任务进度功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<TaskExecution>> submitTaskCompletion(
    String taskId,
    List<String>? proofImages,
    String? notes,
  ) async {
    return ApiResult.failure('提交任务完成功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<List<TaskComment>>> getTaskComments(String taskId, {int page = 1, int limit = 50}) async {
    return ApiResult.failure('获取任务评论功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<TaskComment>> addTaskComment(String taskId, String content, {String? parentId, List<String>? images}) async {
    return ApiResult.failure('添加任务评论功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<List<TaskExecution>>> getTaskExecutions(String taskId) async {
    return ApiResult.failure('获取任务执行记录功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<TaskExecution>> rateTaskExecution(String executionId, int rating, String? feedback) async {
    return ApiResult.failure('评价任务执行功能暂未在服务端实现');
  }

  @override
  Future<ApiResult<void>> reportTask(String taskId, String reportType, String reason) async {
    return ApiResult.failure('举报任务功能暂未在服务端实现');
  }
}