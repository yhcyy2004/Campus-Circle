import '../../models/task_model.dart';

/// 验证结果类
class ValidationResult {
  const ValidationResult({
    required this.isValid,
    this.errors = const [],
    this.warnings = const [],
  });

  final bool isValid;
  final List<String> errors;
  final List<String> warnings;

  /// 创建成功的验证结果
  factory ValidationResult.success({List<String> warnings = const []}) {
    return ValidationResult(
      isValid: true,
      warnings: warnings,
    );
  }

  /// 创建失败的验证结果
  factory ValidationResult.failure(List<String> errors, {List<String> warnings = const []}) {
    return ValidationResult(
      isValid: false,
      errors: errors,
      warnings: warnings,
    );
  }

  /// 获取第一个错误信息
  String? get firstError => errors.isNotEmpty ? errors.first : null;

  /// 获取所有错误信息的字符串
  String get errorMessage => errors.join('; ');

  /// 合并多个验证结果
  ValidationResult merge(ValidationResult other) {
    return ValidationResult(
      isValid: isValid && other.isValid,
      errors: [...errors, ...other.errors],
      warnings: [...warnings, ...other.warnings],
    );
  }
}

/// 验证规则接口
abstract class ValidationRule<T> {
  ValidationResult validate(T value);
  String get errorMessage;
}

/// 必填验证规则
class RequiredRule implements ValidationRule<String?> {
  const RequiredRule([this.customMessage]);

  final String? customMessage;

  @override
  String get errorMessage => customMessage ?? '此字段不能为空';

  @override
  ValidationResult validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return ValidationResult.failure([errorMessage]);
    }
    return ValidationResult.success();
  }
}

/// 字符串必填验证规则
class RequiredStringRule implements ValidationRule<String> {
  const RequiredStringRule([this.customMessage]);

  final String? customMessage;

  @override
  String get errorMessage => customMessage ?? '此字段不能为空';

  @override
  ValidationResult validate(String value) {
    if (value.trim().isEmpty) {
      return ValidationResult.failure([errorMessage]);
    }
    return ValidationResult.success();
  }
}

/// 长度验证规则
class LengthRule implements ValidationRule<String> {
  const LengthRule({
    this.min,
    this.max,
    this.customMessage,
  });

  final int? min;
  final int? max;
  final String? customMessage;

  @override
  String get errorMessage {
    if (customMessage != null) return customMessage!;
    if (min != null && max != null) {
      return '长度必须在$min-$max个字符之间';
    } else if (min != null) {
      return '长度不能少于$min个字符';
    } else if (max != null) {
      return '长度不能超过$max个字符';
    }
    return '长度不符合要求';
  }

  @override
  ValidationResult validate(String value) {
    final length = value.length;
    final errors = <String>[];

    if (min != null && length < min!) {
      errors.add(errorMessage);
    }
    if (max != null && length > max!) {
      errors.add(errorMessage);
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}

/// 范围验证规则
class RangeRule<T extends num> implements ValidationRule<T> {
  const RangeRule({
    required this.min,
    required this.max,
    this.customMessage,
  });

  final T min;
  final T max;
  final String? customMessage;

  @override
  String get errorMessage => customMessage ?? '值必须在$min到$max之间';

  @override
  ValidationResult validate(T value) {
    if (value < min || value > max) {
      return ValidationResult.failure([errorMessage]);
    }
    return ValidationResult.success();
  }
}

/// 日期时间验证规则
class DateTimeRule implements ValidationRule<DateTime> {
  const DateTimeRule({
    this.after,
    this.before,
    this.customMessage,
  });

  final DateTime? after;
  final DateTime? before;
  final String? customMessage;

  @override
  String get errorMessage {
    if (customMessage != null) return customMessage!;
    if (after != null) return '时间必须晚于${after!.toLocal()}';
    if (before != null) return '时间必须早于${before!.toLocal()}';
    return '时间不符合要求';
  }

  @override
  ValidationResult validate(DateTime value) {
    final errors = <String>[];

    if (after != null && value.isBefore(after!)) {
      errors.add(errorMessage);
    }
    if (before != null && value.isAfter(before!)) {
      errors.add(errorMessage);
    }

    return errors.isEmpty
        ? ValidationResult.success()
        : ValidationResult.failure(errors);
  }
}

/// 字段验证器
class FieldValidator<T> {
  FieldValidator(this.fieldName);

  final String fieldName;
  final List<ValidationRule<T>> _rules = [];

  /// 添加验证规则
  FieldValidator<T> addRule(ValidationRule<T> rule) {
    _rules.add(rule);
    return this;
  }

  /// 添加必填规则
  FieldValidator<String> required([String? message]) {
    if (T == String) {
      (_rules as List<ValidationRule<String>>).add(RequiredStringRule(message));
    }
    return this as FieldValidator<String>;
  }

  /// 添加长度规则
  FieldValidator<String> length({int? min, int? max, String? message}) {
    if (T == String) {
      (_rules as List<ValidationRule<String>>).add(LengthRule(
        min: min,
        max: max,
        customMessage: message,
      ));
    }
    return this as FieldValidator<String>;
  }

  /// 验证字段值
  ValidationResult validate(T value) {
    var result = ValidationResult.success();

    for (final rule in _rules) {
      final ruleResult = rule.validate(value);
      result = result.merge(ruleResult);
    }

    return result;
  }
}

/// 实体验证器基类
abstract class EntityValidator<T> {
  ValidationResult validate(T entity);

  /// 创建字段验证器
  FieldValidator<F> field<F>(String name) {
    return FieldValidator<F>(name);
  }
}

/// 任务创建请求验证器
class CreateTaskRequestValidator extends EntityValidator<CreateTaskRequest> {
  @override
  ValidationResult validate(CreateTaskRequest request) {
    var result = ValidationResult.success();

    // 验证标题
    final titleResult = field<String>('title')
        .addRule(const RequiredStringRule('任务标题不能为空'))
        .addRule(const LengthRule(max: 200, customMessage: '任务标题不能超过200个字符'))
        .validate(request.title);
    result = result.merge(titleResult);

    // 验证描述
    final descriptionResult = field<String>('description')
        .addRule(const RequiredStringRule('任务描述不能为空'))
        .addRule(const LengthRule(max: 2000, customMessage: '任务描述不能超过2000个字符'))
        .validate(request.description);
    result = result.merge(descriptionResult);

    // 验证截止时间
    final deadlineResult = field<DateTime>('deadline')
        .addRule(DateTimeRule(
          after: DateTime.now(),
          customMessage: '截止时间必须晚于当前时间',
        ))
        .validate(request.deadline);
    result = result.merge(deadlineResult);

    // 验证奖励积分
    final rewardResult = field<int>('rewardPoints')
        .addRule(const RangeRule(
          min: 0,
          max: 10000,
          customMessage: '奖励积分必须在0-10000之间',
        ))
        .validate(request.rewardPoints);

    return result.merge(rewardResult);
  }
}