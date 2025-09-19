import 'dart:convert';
import '../utils/http_utils.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';

/// 改进的签到服务 - 使用安全的JSON解析
class ImprovedCheckinService {
  static final String _baseUrl = AppConstants.baseUrl;

  /// 获取用户签到状态 (改进版)
  static Future<Map<String, dynamic>> getCheckinStatus() async {
    try {
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null) {
        return {
          'success': false,
          'message': '用户未登录',
        };
      }

      final result = await HttpUtils.safeGet(
        '$_baseUrl/checkin/status',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return HttpUtils.buildApiResponse(result);
    } catch (e) {
      return {
        'success': false,
        'message': '获取签到状态失败: $e',
      };
    }
  }

  /// 执行签到 (改进版)
  static Future<Map<String, dynamic>> performCheckin() async {
    try {
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null) {
        return {
          'success': false,
          'message': '用户未登录',
        };
      }

      final result = await HttpUtils.safePost(
        '$_baseUrl/checkin',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final response = HttpUtils.buildApiResponse(result);

      // 如果不是JSON解析错误，则返回标准响应
      if (result.success || !result.message!.contains('JSON解析失败')) {
        return response;
      }

      // 特殊处理：如果服务器返回了非JSON格式的成功响应
      if (result.statusCode == 200) {
        return {
          'success': true,
          'message': '签到成功',
          'data': {
            'raw_response': result.rawBody,
          },
        };
      }

      return response;
    } catch (e) {
      return {
        'success': false,
        'message': '签到操作失败: $e',
      };
    }
  }

  /// 获取签到历史记录 (改进版)
  static Future<Map<String, dynamic>> getCheckinHistory({
    int page = 1,
    int limit = 30,
  }) async {
    try {
      final token = StorageService.getString(AppConstants.keyToken);
      if (token == null) {
        return {
          'success': false,
          'message': '用户未登录',
        };
      }

      final result = await HttpUtils.safeGet(
        '$_baseUrl/checkin/history?page=$page&limit=$limit',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      return HttpUtils.buildApiResponse(result);
    } catch (e) {
      return {
        'success': false,
        'message': '获取签到历史失败: $e',
      };
    }
  }

  /// 获取签到规则配置 (改进版)
  static Future<Map<String, dynamic>> getCheckinRules() async {
    try {
      final result = await HttpUtils.safeGet(
        '$_baseUrl/checkin/rules',
        headers: {
          'Content-Type': 'application/json',
        },
      );

      return HttpUtils.buildApiResponse(result);
    } catch (e) {
      return {
        'success': false,
        'message': '获取签到规则失败: $e',
      };
    }
  }
}