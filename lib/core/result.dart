/// 通用结果类 - 用于包装操作结果
class Result<T> {
  final bool success;
  final T? data;
  final String? message;
  final String? errorCode;

  const Result._({
    required this.success,
    this.data,
    this.message,
    this.errorCode,
  });

  /// 创建成功结果
  factory Result.success(T data) {
    return Result._(
      success: true,
      data: data,
    );
  }

  /// 创建错误结果
  factory Result.error(String message, {String? errorCode}) {
    return Result._(
      success: false,
      message: message,
      errorCode: errorCode,
    );
  }

  /// 是否失败
  bool get isFailure => !success;

  /// 获取数据或抛出异常
  T get dataOrThrow {
    if (success && data != null) {
      return data!;
    }
    throw Exception(message ?? 'Operation failed');
  }

  /// 转换数据类型
  Result<R> map<R>(R Function(T) transform) {
    if (success && data != null) {
      try {
        return Result.success(transform(data!));
      } catch (e) {
        return Result.error('Transform failed: $e');
      }
    }
    return Result.error(message ?? 'No data to transform', errorCode: errorCode);
  }

  /// 链式操作
  Result<R> flatMap<R>(Result<R> Function(T) transform) {
    if (success && data != null) {
      return transform(data!);
    }
    return Result.error(message ?? 'No data to transform', errorCode: errorCode);
  }

  @override
  String toString() {
    if (success) {
      return 'Result.success($data)';
    } else {
      return 'Result.error($message)';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Result<T> &&
        other.success == success &&
        other.data == data &&
        other.message == message &&
        other.errorCode == errorCode;
  }

  @override
  int get hashCode {
    return success.hashCode ^
        data.hashCode ^
        message.hashCode ^
        errorCode.hashCode;
  }
}