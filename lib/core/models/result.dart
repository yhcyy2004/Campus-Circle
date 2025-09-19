import '../../models/user_model.dart';

/// API响应结果统一封装 - 与server.js返回格式保持一致
class ApiResult<T> {
  final bool success; // 与server.js的success字段保持一致
  final T? data;
  final String? message; // server.js的消息字段
  final String? error; // server.js的错误字段
  final int? code;

  const ApiResult({
    required this.success,
    this.data,
    this.message,
    this.error,
    this.code,
  });

  /// 成功结果
  factory ApiResult.success(T data, [String? message]) {
    return ApiResult<T>(
      success: true,
      data: data,
      message: message,
    );
  }

  /// 失败结果
  factory ApiResult.failure(String error, {int? code}) {
    return ApiResult<T>(
      success: false,
      error: error,
      code: code,
    );
  }

  /// 从server.js JSON响应创建
  factory ApiResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>)? fromJsonT,
  ) {
    final success = json['success'] as bool? ?? false;
    final message = json['message'] as String?;
    final error = json['error'] as String?;
    final code = json['code'] as int?;

    T? data;
    if (success && json['data'] != null && fromJsonT != null) {
      try {
        if (json['data'] is Map<String, dynamic>) {
          data = fromJsonT(json['data'] as Map<String, dynamic>);
        }
      } catch (e) {
        return ApiResult<T>(
          success: false,
          error: '数据解析失败: $e',
        );
      }
    }

    return ApiResult<T>(
      success: success,
      data: data,
      message: message,
      error: error,
      code: code,
    );
  }

  /// 兼容原有的isSuccess字段
  bool get isSuccess => success;

  /// 是否失败
  bool get isFailure => !success;

  /// 获取错误信息
  String get errorMessage => error ?? message ?? '未知错误';

  /// 获取用户（用于向后兼容）
  User? get user => data is User ? data as User : null;

  /// 转换数据类型
  ApiResult<R> map<R>(R Function(T) transform) {
    if (success && data != null) {
      try {
        return ApiResult.success(transform(data!), message);
      } catch (e) {
        return ApiResult.failure('数据转换失败: $e');
      }
    }
    return ApiResult.failure(errorMessage, code: code);
  }

  @override
  String toString() {
    if (success) {
      return 'ApiResult.success(data: $data, message: $message)';
    } else {
      return 'ApiResult.failure(error: $errorMessage, code: $code)';
    }
  }
}