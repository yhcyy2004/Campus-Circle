import '../core/logger.dart';
import '../core/models/result.dart';
import '../core/result.dart';
import '../core/validation/validation_framework.dart';
import '../models/task_model.dart';
import '../services/task_service.dart';

/// 任务查询参数
class TaskQueryParams {
  const TaskQueryParams({
    this.page = 1,
    this.limit = 20,
    this.categoryId,
    this.status = 1,
    this.sort = 'latest',
    this.search,
  });

  final int page;
  final int limit;
  final int? categoryId;
  final int status;
  final String sort;
  final String? search;

  Map<String, dynamic> toMap() {
    return {
      'page': page,
      'limit': limit,
      if (categoryId != null) 'categoryId': categoryId,
      'status': status,
      'sort': sort,
      if (search != null) 'search': search,
    };
  }
}

/// 任务控制器接口 - 遵循依赖倒置原则
abstract class ITaskController {
  Future<Result<Map<String, dynamic>>> getTasks(TaskQueryParams params);
  Future<Result<Task>> getTaskDetail(String taskId);
  Future<Result<Task>> createTask(CreateTaskRequest request);
  Future<Result<void>> joinTask(String taskId, String userId);
  Future<Result<List<TaskCategory>>> getTaskCategories();
}

/// 任务验证器接口 - 使用策略模式
abstract class ITaskValidator {
  ValidationResult validateCreateTaskRequest(CreateTaskRequest request);
  ValidationResult validateTaskQueryParams(TaskQueryParams params);
}

/// 默认任务验证器 - 使用新的验证框架
class DefaultTaskValidator implements ITaskValidator {
  DefaultTaskValidator() : _createTaskValidator = CreateTaskRequestValidator();

  final CreateTaskRequestValidator _createTaskValidator;

  @override
  ValidationResult validateCreateTaskRequest(CreateTaskRequest request) {
    return _createTaskValidator.validate(request);
  }

  @override
  ValidationResult validateTaskQueryParams(TaskQueryParams params) {
    var result = ValidationResult.success();

    // 验证分页参数
    if (params.page < 1) {
      result = result.merge(ValidationResult.failure(['页码必须大于0']));
    }

    if (params.limit < 1 || params.limit > 100) {
      result = result.merge(ValidationResult.failure(['每页数量必须在1-100之间']));
    }

    return result;
  }
}

/// ApiResult 到 Result 的适配器
class ResultAdapter {
  static Result<T> fromApiResult<T>(ApiResult<T> apiResult) {
    if (apiResult.isSuccess && apiResult.data != null) {
      return Result.success(apiResult.data!);
    } else {
      return Result.error(apiResult.error ?? '操作失败');
    }
  }
}

/// 任务控制器 - 处理任务相关的业务逻辑
/// 遵循单一职责原则，只负责任务相关的业务处理
class TaskController implements ITaskController {
  TaskController({
    required ITaskService taskService,
    ITaskValidator? validator,
  }) : _taskService = taskService,
       _validator = validator ?? DefaultTaskValidator();

  final ITaskService _taskService;
  final ITaskValidator _validator;

  @override
  Future<Result<Map<String, dynamic>>> getTasks(TaskQueryParams params) async {
    try {
      AppLogger.info('TaskController', '获取任务列表', params.toMap());

      // 验证查询参数
      final validationResult = _validator.validateTaskQueryParams(params);
      if (!validationResult.isValid) {
        AppLogger.warning('TaskController', '查询参数验证失败', {'errors': validationResult.errors});
        return Result.error(validationResult.errorMessage);
      }

      final apiResult = await _taskService.getTasks(
        page: params.page,
        limit: params.limit,
        category: params.categoryId?.toString(),
        status: params.status.toString(),
        sort: params.sort,
        search: params.search,
      );

      final result = ResultAdapter.fromApiResult(apiResult);

      if (result.success && result.data != null) {
        AppLogger.info('TaskController', '任务列表获取成功', {'count': result.data!.tasks.length});
        return Result.success({
          'tasks': result.data!.tasks,
          'pagination': {
            'page': result.data!.page,
            'limit': result.data!.limit,
            'total': result.data!.total,
            'totalPages': result.data!.totalPages,
          }
        });
      } else {
        AppLogger.error('TaskController', '任务列表获取失败', {'error': result.message});
        return Result.error(result.message ?? '获取任务列表失败');
      }
    } catch (e) {
      AppLogger.error('TaskController', '获取任务列表异常', {'error': e.toString()});
      return Result.error('服务器内部错误');
    }
  }

  @override
  Future<Result<Task>> getTaskDetail(String taskId) async {
    try {
      AppLogger.info('TaskController', '获取任务详情', {'taskId': taskId});

      if (taskId.trim().isEmpty) {
        return Result.error('任务ID不能为空');
      }

      final apiResult = await _taskService.getTaskDetail(taskId);
      final result = ResultAdapter.fromApiResult(apiResult);

      if (result.success && result.data != null) {
        AppLogger.info('TaskController', '任务详情获取成功', {'taskId': taskId});
        return Result.success(result.data!);
      } else {
        AppLogger.warning('TaskController', '任务不存在', {'taskId': taskId});
        return Result.error(result.message ?? '任务不存在');
      }
    } catch (e) {
      AppLogger.error('TaskController', '获取任务详情异常', {'taskId': taskId, 'error': e.toString()});
      return Result.error('服务器内部错误');
    }
  }

  @override
  Future<Result<Task>> createTask(CreateTaskRequest request) async {
    try {
      AppLogger.info('TaskController', '创建任务', {'title': request.title});

      // 验证请求数据
      final validationResult = _validator.validateCreateTaskRequest(request);
      if (!validationResult.isValid) {
        AppLogger.warning('TaskController', '任务创建验证失败', {'errors': validationResult.errors});
        return Result.error(validationResult.errorMessage);
      }

      final apiResult = await _taskService.createTask(request);
      final result = ResultAdapter.fromApiResult(apiResult);

      if (result.success && result.data != null) {
        AppLogger.info('TaskController', '任务创建成功', {'taskId': result.data!.id});
        return Result.success(result.data!);
      } else {
        AppLogger.error('TaskController', '任务创建失败', {'error': result.message});
        return Result.error(result.message ?? '任务创建失败');
      }
    } catch (e) {
      AppLogger.error('TaskController', '创建任务异常', {'error': e.toString()});

      // 处理特定的业务异常
      if (e.toString().contains('积分不足')) {
        return Result.error('积分不足，无法发布任务');
      }

      return Result.error('服务器内部错误');
    }
  }

  @override
  Future<Result<void>> joinTask(String taskId, String userId) async {
    try {
      AppLogger.info('TaskController', '参与任务', {'taskId': taskId, 'userId': userId});

      if (taskId.trim().isEmpty || userId.trim().isEmpty) {
        return Result.error('任务ID和用户ID不能为空');
      }

      final apiResult = await _taskService.joinTask(taskId, userId);
      final result = ResultAdapter.fromApiResult(apiResult);

      if (result.success) {
        AppLogger.info('TaskController', '参与任务成功', {'taskId': taskId, 'userId': userId});
        return Result.success(null);
      } else {
        AppLogger.error('TaskController', '参与任务失败', {'error': result.message});
        return Result.error(result.message ?? '参与任务失败');
      }
    } catch (e) {
      AppLogger.error('TaskController', '参与任务异常', {'taskId': taskId, 'userId': userId, 'error': e.toString()});
      return Result.error('服务器内部错误');
    }
  }

  @override
  Future<Result<List<TaskCategory>>> getTaskCategories() async {
    try {
      AppLogger.info('TaskController', '获取任务分类');

      final apiResult = await _taskService.getTaskCategories();
      final result = ResultAdapter.fromApiResult(apiResult);

      if (result.success && result.data != null) {
        AppLogger.info('TaskController', '任务分类获取成功', {'count': result.data!.length});
        return Result.success(result.data!);
      } else {
        AppLogger.error('TaskController', '任务分类获取失败', {'error': result.message});
        return Result.error(result.message ?? '获取任务分类失败');
      }
    } catch (e) {
      AppLogger.error('TaskController', '获取任务分类异常', {'error': e.toString()});
      return Result.error('服务器内部错误');
    }
  }
}

/// 任务控制器工厂 - 使用工厂模式
class TaskControllerFactory {
  static TaskController create({
    required ITaskService taskService,
    ITaskValidator? validator,
  }) {
    return TaskController(
      taskService: taskService,
      validator: validator,
    );
  }
}