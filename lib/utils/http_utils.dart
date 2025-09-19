import 'dart:convert';
import 'package:http/http.dart' as http;

/// HTTP请求响应结果
class HttpResult {
  HttpResult({
    required this.success,
    this.data,
    this.message,
    required this.statusCode,
    this.rawBody,
  });

  final bool success;
  final Map<String, dynamic>? data;
  final String? message;
  final int statusCode;
  final String? rawBody;
}

/// HTTP请求工具类 - 统一处理JSON解析和错误
class HttpUtils {
  /// 安全的GET请求
  static Future<HttpResult> safeGet(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      return _processResponse(response);
    } catch (e) {
      return HttpResult(
        success: false,
        message: '网络请求失败: $e',
        statusCode: -1,
      );
    }
  }

  /// 安全的POST请求
  static Future<HttpResult> safePost(
    String url, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      return _processResponse(response);
    } catch (e) {
      return HttpResult(
        success: false,
        message: '网络请求失败: $e',
        statusCode: -1,
      );
    }
  }

  /// 处理HTTP响应
  static HttpResult _processResponse(http.Response response) {
    // 检查响应状态码
    final isSuccess = response.statusCode >= 200 && response.statusCode < 300;

    // 尝试解析JSON
    Map<String, dynamic>? responseData;
    String? parseError;

    try {
      if (response.body.isNotEmpty) {
        responseData = json.decode(response.body);
      }
    } catch (e) {
      parseError = 'JSON解析失败: $e';
    }

    // 如果JSON解析失败
    if (parseError != null) {
      return HttpResult(
        success: false,
        message: '$parseError\n原始响应: ${response.body}',
        statusCode: response.statusCode,
        rawBody: response.body,
      );
    }

    // 如果状态码表示成功
    if (isSuccess) {
      return HttpResult(
        success: true,
        data: responseData,
        statusCode: response.statusCode,
        rawBody: response.body,
      );
    } else {
      // 状态码表示失败
      final errorMessage = responseData?['message'] ??
                          responseData?['error'] ??
                          'HTTP ${response.statusCode} 错误';

      return HttpResult(
        success: false,
        data: responseData,
        message: errorMessage,
        statusCode: response.statusCode,
        rawBody: response.body,
      );
    }
  }

  /// 构建标准API响应格式
  static Map<String, dynamic> buildApiResponse(HttpResult result) {
    if (result.success) {
      return {
        'success': true,
        'data': result.data?['data'] ?? result.data,
        'message': result.data?['message'],
      };
    } else {
      return {
        'success': false,
        'message': result.message,
        'statusCode': result.statusCode,
        'rawBody': result.rawBody,
      };
    }
  }
}