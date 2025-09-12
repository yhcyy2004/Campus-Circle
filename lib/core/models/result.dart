import '../../models/user_model.dart';

/// API调用结果封装类
class ApiResult<T> {
  final bool isSuccess;
  final T? data;
  final String? error;
  final int? code;

  const ApiResult({
    required this.isSuccess,
    this.data,
    this.error,
    this.code,
  });

  /// 成功结果
  factory ApiResult.success(T data) {
    return ApiResult(
      isSuccess: true,
      data: data,
    );
  }

  /// 失败结果
  factory ApiResult.failure(String error, [int? code]) {
    return ApiResult(
      isSuccess: false,
      error: error,
      code: code,
    );
  }

  /// 获取用户（用于向后兼容）
  User? get user => data is User ? data as User : null;
}