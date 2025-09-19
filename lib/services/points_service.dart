import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../services/storage_service.dart';

class PointsService {
  static final String _baseUrl = AppConstants.baseUrl;

  /// 获取用户积分信息
  static Future<Map<String, dynamic>> getUserPoints() async {
    try {
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/points/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 安全的JSON解析
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': '服务器返回格式错误: ${response.body}',
        };
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? '获取积分信息失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    }
  }

  /// 获取积分历史记录
  static Future<Map<String, dynamic>> getPointsHistory({
    int page = 1,
    int limit = 20,
    String? type, // 'earned' | 'spent' | null (all)
  }) async {
    try {
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null) {
        throw Exception('未登录');
      }

      String url = '$_baseUrl/points/history?page=$page&limit=$limit';
      if (type != null) {
        url += '&type=$type';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 安全的JSON解析
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': '服务器返回格式错误: ${response.body}',
        };
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? '获取积分历史失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    }
  }

  /// 获取积分统计信息
  static Future<Map<String, dynamic>> getPointsStatistics() async {
    try {
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/points/statistics'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      // 安全的JSON解析
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': '服务器返回格式错误: ${response.body}',
        };
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? '获取积分统计失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    }
  }

  /// 获取积分获取方式列表
  static Future<Map<String, dynamic>> getPointsEarnWays() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/points/earn-ways'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      // 安全的JSON解析
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': '服务器返回格式错误: ${response.body}',
        };
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? '获取积分获取方式失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    }
  }

  /// 手动添加积分记录（用于特殊场景）
  static Future<Map<String, dynamic>> addPointsRecord({
    required int points,
    required String sourceType,
    String? sourceId,
    required String title,
    String? description,
  }) async {
    try {
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/points/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'points': points,
          'source_type': sourceType,
          'source_id': sourceId,
          'title': title,
          'description': description,
        }),
      );

      // 安全的JSON解析
      Map<String, dynamic> responseData;
      try {
        responseData = json.decode(response.body);
      } catch (e) {
        return {
          'success': false,
          'message': '服务器返回格式错误: ${response.body}',
        };
      }

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'],
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? '添加积分失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    }
  }
}