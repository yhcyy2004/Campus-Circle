import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../services/storage_service.dart';

class CheckinService {
  static final String _baseUrl = AppConstants.baseUrl;

  /// 获取用户签到状态
  static Future<Map<String, dynamic>> getCheckinStatus() async {
    try {
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/checkin/status'),
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
          'message': responseData['message'] ?? '获取签到状态失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    }
  }

  /// 执行签到
  static Future<Map<String, dynamic>> performCheckin() async {
    try {
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/checkin'),
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
          'message': responseData['message'],
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? '签到失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    }
  }

  /// 获取签到历史记录
  static Future<Map<String, dynamic>> getCheckinHistory({
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null) {
        throw Exception('未登录');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/checkin/history?page=$page&limit=$limit'),
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
          'message': responseData['message'] ?? '获取签到历史失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    }
  }

  /// 获取签到规则配置
  static Future<Map<String, dynamic>> getCheckinRules() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/checkin/rules'),
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
          'message': responseData['message'] ?? '获取签到规则失败',
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