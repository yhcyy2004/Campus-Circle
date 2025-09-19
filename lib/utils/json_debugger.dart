import 'dart:convert';
import '../core/logger.dart';

/// JSON调试工具 - 帮助诊断JSON解析问题
class JsonDebugger {
  static const String _tag = 'JsonDebugger';

  /// 安全解析JSON并提供详细的错误信息
  static Map<String, dynamic>? safeParseJson(String jsonString) {
    try {
      // 记录原始字符串
      AppLogger.debug(_tag, '尝试解析JSON', {
        'length': jsonString.length,
        'first_100_chars': jsonString.length > 100
            ? jsonString.substring(0, 100) + '...'
            : jsonString,
      });

      final result = json.decode(jsonString);

      if (result is Map<String, dynamic>) {
        AppLogger.info(_tag, 'JSON解析成功', {
          'type': 'Map<String, dynamic>',
          'keys': result.keys.toList(),
        });
        return result;
      } else {
        AppLogger.warning(_tag, 'JSON解析结果不是Map类型', {
          'actual_type': result.runtimeType.toString(),
          'value': result.toString(),
        });
        return null;
      }
    } catch (e) {
      AppLogger.error(_tag, 'JSON解析失败', {
        'error': e.toString(),
        'json_string': jsonString,
        'analysis': _analyzeJsonString(jsonString),
      });
      return null;
    }
  }

  /// 分析JSON字符串的常见问题
  static Map<String, dynamic> _analyzeJsonString(String jsonString) {
    final analysis = <String, dynamic>{};

    // 检查是否为空
    if (jsonString.isEmpty) {
      analysis['issue'] = 'empty_string';
      return analysis;
    }

    // 检查长度
    analysis['length'] = jsonString.length;

    // 检查首尾字符
    analysis['first_char'] = jsonString[0];
    analysis['last_char'] = jsonString[jsonString.length - 1];

    // 检查是否看起来像JSON
    final trimmed = jsonString.trim();
    analysis['starts_with_brace'] = trimmed.startsWith('{');
    analysis['ends_with_brace'] = trimmed.endsWith('}');
    analysis['starts_with_bracket'] = trimmed.startsWith('[');
    analysis['ends_with_bracket'] = trimmed.endsWith(']');

    // 检查是否包含HTML
    analysis['contains_html'] = jsonString.contains('<html>') ||
                               jsonString.contains('<!DOCTYPE');

    // 检查是否是错误页面
    analysis['looks_like_error_page'] = jsonString.contains('<title>') &&
                                       (jsonString.contains('error') ||
                                        jsonString.contains('404') ||
                                        jsonString.contains('500'));

    // 检查是否包含JavaScript
    analysis['contains_javascript'] = jsonString.contains('<script>') ||
                                     jsonString.contains('function(');

    // 检查常见的非JSON响应
    if (jsonString.toLowerCase().contains('unauthorized')) {
      analysis['suspected_issue'] = 'authentication_required';
    } else if (jsonString.toLowerCase().contains('not found')) {
      analysis['suspected_issue'] = 'endpoint_not_found';
    } else if (jsonString.toLowerCase().contains('internal server error')) {
      analysis['suspected_issue'] = 'server_error';
    } else if (jsonString.contains('<html>')) {
      analysis['suspected_issue'] = 'html_response_instead_of_json';
    }

    return analysis;
  }

  /// 验证API响应格式
  static bool validateApiResponse(Map<String, dynamic>? data) {
    if (data == null) {
      AppLogger.warning(_tag, 'API响应为null');
      return false;
    }

    // 检查是否包含必要的字段
    final hasSuccess = data.containsKey('success');
    final hasData = data.containsKey('data');
    final hasMessage = data.containsKey('message');

    AppLogger.debug(_tag, 'API响应格式验证', {
      'has_success': hasSuccess,
      'has_data': hasData,
      'has_message': hasMessage,
      'keys': data.keys.toList(),
    });

    return hasSuccess;
  }

  /// 格式化输出API响应用于调试
  static void debugApiResponse(String apiName, Map<String, dynamic>? response) {
    AppLogger.info(_tag, '=== API响应调试: $apiName ===');

    if (response == null) {
      AppLogger.error(_tag, 'API响应为null');
      return;
    }

    AppLogger.info(_tag, 'API响应内容', {
      'success': response['success'],
      'message': response['message'],
      'data_type': response['data']?.runtimeType.toString(),
      'data_keys': response['data'] is Map
          ? (response['data'] as Map).keys.toList()
          : null,
      'full_response': response,
    });
  }

  /// 测试JSON解析功能
  static void runJsonTests() {
    AppLogger.info(_tag, '开始JSON解析测试');

    // 测试正常JSON
    final validJson = '{"success": true, "message": "测试成功"}';
    final result1 = safeParseJson(validJson);
    assert(result1 != null, '正常JSON解析失败');

    // 测试无效JSON
    final invalidJson = '{"success": true, "message": "测试成功"'; // 缺少结束括号
    final result2 = safeParseJson(invalidJson);
    assert(result2 == null, '无效JSON应该返回null');

    // 测试HTML响应
    final htmlResponse = '<html><body>Error 404</body></html>';
    final result3 = safeParseJson(htmlResponse);
    assert(result3 == null, 'HTML响应应该返回null');

    // 测试空字符串
    final emptyString = '';
    final result4 = safeParseJson(emptyString);
    assert(result4 == null, '空字符串应该返回null');

    AppLogger.info(_tag, 'JSON解析测试完成');
  }
}