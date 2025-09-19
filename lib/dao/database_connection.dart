// Database connection using HTTP API instead of direct MySQL connection
import '../config/database_config.dart';
import '../services/api_service.dart';

class DatabaseConnection {
  static DatabaseConnection? _instance;
  final ApiService _apiService = ApiService();

  factory DatabaseConnection() {
    _instance ??= DatabaseConnection._internal();
    return _instance!;
  }

  DatabaseConnection._internal();

  // 执行查询操作 - 通过HTTP API
  Future<Map<String, dynamic>> query(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      print('API查询：$endpoint，参数：$params');
      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: params,
      );
      print('查询结果：${response.statusCode}');
      return response.data ?? {};
    } catch (e) {
      print('API查询失败: $e');
      rethrow;
    }
  }

  // 执行创建/更新操作 - 通过HTTP API
  Future<Map<String, dynamic>> execute(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      print('API执行：$endpoint，数据：$data');
      final response = await _apiService.post<Map<String, dynamic>>(
        endpoint,
        data: data,
      );
      print('执行结果：${response.statusCode}，数据：${response.data}');
      // 确保返回非null的Map
      return response.data ?? {};
    } catch (e) {
      print('API执行失败: $e');
      return {}; // 异常时返回空Map，避免上层处理null
    }
  }

  // 执行更新操作
  Future<Map<String, dynamic>> update(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      print('API更新：$endpoint，数据：$data');
      final response = await _apiService.put<Map<String, dynamic>>(
        endpoint,
        data: data,
      );
      print('更新结果：${response.statusCode}');
      return response.data ?? {};
    } catch (e) {
      print('API更新失败: $e');
      rethrow;
    }
  }

  // 执行删除操作
  Future<Map<String, dynamic>> delete(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      print('API删除：$endpoint，参数：$params');
      final response = await _apiService.delete<Map<String, dynamic>>(
        endpoint,
        queryParameters: params,
      );
      print('删除结果：${response.statusCode}');
      return response.data ?? {};
    } catch (e) {
      print('API删除失败: $e');
      rethrow;
    }
  }

  // 健康检查
  Future<bool> checkConnection() async {
    try {
      final response = await _apiService.get(DatabaseConfig.healthCheckUrl);
      return response.statusCode == 200;
    } catch (e) {
      print('API连接检查失败: $e');
      return false;
    }
  }
}