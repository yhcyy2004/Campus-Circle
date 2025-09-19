import '../core/dao/task_dao.dart';
import '../core/dao/impl/http_task_dao.dart';
import '../models/task_model.dart';
import '../core/models/result.dart';

/// 任务服务接口 - 遵循依赖倒置原则
abstract class ITaskService {
  Future<ApiResult<TaskListResponse>> getTasks({
    int page = 1,
    int limit = 20,
    String? category,
    String? status,
    String? sort,
    String? search,
  });

  Future<ApiResult<Task>> getTaskDetail(String taskId);
  Future<ApiResult<Task>> createTask(CreateTaskRequest request);
  Future<ApiResult<void>> joinTask(String taskId, String userId);
  Future<ApiResult<List<TaskCategory>>> getTaskCategories();
}

/// 任务服务类
class TaskService implements ITaskService {
  static final TaskService _instance = TaskService._internal();
  factory TaskService() => _instance;
  TaskService._internal();

  final TaskDAO _taskDAO = HttpTaskDAO();

  @override
  Future<ApiResult<TaskListResponse>> getTasks({
    int page = 1,
    int limit = 20,
    String? category,
    String? status,
    String? sort,
    String? search,
  }) {
    return _taskDAO.getTasks(
      page: page,
      limit: limit,
      category: category,
      status: status,
      sort: sort,
      search: search,
    );
  }

  @override
  Future<ApiResult<Task>> getTaskDetail(String taskId) {
    return _taskDAO.getTaskDetail(taskId);
  }

  @override
  Future<ApiResult<Task>> createTask(CreateTaskRequest request) {
    return _taskDAO.createTask(request);
  }

  @override
  Future<ApiResult<void>> joinTask(String taskId, String userId) {
    // 这里实现加入任务的逻辑
    return _taskDAO.applyForTask(taskId, CreateTaskApplicationRequest()).then((result) {
      if (result.isSuccess) {
        return ApiResult.success(null);
      } else {
        return ApiResult.failure(result.error ?? '加入任务失败');
      }
    });
  }

  @override
  Future<ApiResult<List<TaskCategory>>> getTaskCategories() {
    // 返回任务分类枚举作为列表
    final categories = TaskCategory.values;
    return Future.value(ApiResult.success(categories));
  }

  /// 获取热门任务
  Future<ApiResult<TaskListResponse>> getHotTasks({
    int limit = 10,
  }) {
    return _taskDAO.getTasks(
      limit: limit,
      sort: 'hot',
    );
  }

  /// 获取紧急任务
  Future<ApiResult<TaskListResponse>> getUrgentTasks({
    int limit = 10,
  }) {
    return _taskDAO.getTasks(
      limit: limit,
      sort: 'urgent',
    );
  }

  /// 根据分类获取任务
  Future<ApiResult<TaskListResponse>> getTasksByCategory(
    String category, {
    int page = 1,
    int limit = 20,
  }) {
    return _taskDAO.getTasks(
      page: page,
      limit: limit,
      category: category,
    );
  }

  /// 搜索任务
  Future<ApiResult<TaskListResponse>> searchTasks(
    String keyword, {
    int page = 1,
    int limit = 20,
    String? category,
  }) {
    return _taskDAO.getTasks(
      page: page,
      limit: limit,
      category: category,
      search: keyword,
    );
  }

  /// 更新任务
  Future<ApiResult<Task>> updateTask(String taskId, {
    String? title,
    String? description,
    String? category,
    int? rewardPoints,
    double? rewardMoney,
    DateTime? deadline,
    String? location,
    String? requirements,
    String? contactInfo,
    List<String>? images,
    List<String>? tags,
    int? maxApplicants,
    bool? isUrgent,
  }) {
    final updates = <String, dynamic>{};

    if (title != null) updates['title'] = title;
    if (description != null) updates['description'] = description;
    if (category != null) updates['category'] = category;
    if (rewardPoints != null) updates['reward_points'] = rewardPoints;
    if (rewardMoney != null) updates['reward_money'] = rewardMoney;
    if (deadline != null) updates['deadline'] = deadline.toIso8601String();
    if (location != null) updates['location'] = location;
    if (requirements != null) updates['requirements'] = requirements;
    if (contactInfo != null) updates['contact_info'] = contactInfo;
    if (images != null) updates['images'] = images;
    if (tags != null) updates['tags'] = tags;
    if (maxApplicants != null) updates['max_applicants'] = maxApplicants;
    if (isUrgent != null) updates['is_urgent'] = isUrgent;

    return _taskDAO.updateTask(taskId, updates);
  }

  /// 删除任务
  Future<ApiResult<void>> deleteTask(String taskId) {
    return _taskDAO.deleteTask(taskId);
  }

  /// 申请任务
  Future<ApiResult<TaskApplication>> applyForTask(
    String taskId, {
    String? applicationReason,
    DateTime? proposedCompletionTime,
    String? contactInfo,
  }) {
    final request = CreateTaskApplicationRequest(
      applicationReason: applicationReason,
      proposedCompletionTime: proposedCompletionTime,
      contactInfo: contactInfo,
    );

    return _taskDAO.applyForTask(taskId, request);
  }

  /// 获取任务申请列表
  Future<ApiResult<List<TaskApplication>>> getTaskApplications(String taskId) {
    return _taskDAO.getTaskApplications(taskId);
  }

  /// 接受任务申请
  Future<ApiResult<TaskApplication>> acceptTaskApplication(String applicationId, {String? reason}) {
    return _taskDAO.handleTaskApplication(applicationId, true, reason);
  }

  /// 拒绝任务申请
  Future<ApiResult<TaskApplication>> rejectTaskApplication(String applicationId, {String? reason}) {
    return _taskDAO.handleTaskApplication(applicationId, false, reason);
  }

  /// 获取我的申请列表
  Future<ApiResult<List<TaskApplication>>> getMyApplications({
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    return _taskDAO.getMyApplications(page: page, limit: limit, status: status);
  }

  /// 获取我发布的任务
  Future<ApiResult<List<Task>>> getMyTasks({
    int page = 1,
    int limit = 20,
    String? status,
  }) {
    return _taskDAO.getMyTasks(page: page, limit: limit, status: status);
  }

  /// 收藏任务
  Future<ApiResult<void>> favoriteTask(String taskId) {
    return _taskDAO.toggleTaskFavorite(taskId);
  }

  /// 取消收藏任务
  Future<ApiResult<void>> unfavoriteTask(String taskId) {
    return _taskDAO.toggleTaskFavorite(taskId);
  }

  /// 获取收藏的任务
  Future<ApiResult<List<Task>>> getFavoriteTasks({
    int page = 1,
    int limit = 20,
  }) {
    return _taskDAO.getFavoriteTasks(page: page, limit: limit);
  }

  /// 更新任务进度
  Future<ApiResult<TaskExecution>> updateTaskProgress(
    String taskId,
    int progress, {
    String? notes,
  }) {
    return _taskDAO.updateTaskProgress(taskId, progress, notes);
  }

  /// 提交任务完成
  Future<ApiResult<TaskExecution>> submitTaskCompletion(
    String taskId, {
    List<String>? proofImages,
    String? notes,
  }) {
    return _taskDAO.submitTaskCompletion(taskId, proofImages, notes);
  }

  /// 获取任务评论
  Future<ApiResult<List<TaskComment>>> getTaskComments(
    String taskId, {
    int page = 1,
    int limit = 50,
  }) {
    return _taskDAO.getTaskComments(taskId, page: page, limit: limit);
  }

  /// 添加任务评论
  Future<ApiResult<TaskComment>> addTaskComment(
    String taskId,
    String content, {
    String? parentId,
    List<String>? images,
  }) {
    return _taskDAO.addTaskComment(taskId, content, parentId: parentId, images: images);
  }

  /// 回复任务评论
  Future<ApiResult<TaskComment>> replyToTaskComment(
    String taskId,
    String parentCommentId,
    String content, {
    List<String>? images,
  }) {
    return _taskDAO.addTaskComment(
      taskId,
      content,
      parentId: parentCommentId,
      images: images,
    );
  }

  /// 获取任务执行记录
  Future<ApiResult<List<TaskExecution>>> getTaskExecutions(String taskId) {
    return _taskDAO.getTaskExecutions(taskId);
  }

  /// 评价任务执行
  Future<ApiResult<TaskExecution>> rateTaskExecution(
    String executionId,
    int rating, {
    String? feedback,
  }) {
    return _taskDAO.rateTaskExecution(executionId, rating, feedback);
  }

  /// 举报任务
  Future<ApiResult<void>> reportTask(
    String taskId,
    String reportType,
    String reason,
  ) {
    return _taskDAO.reportTask(taskId, reportType, reason);
  }

  /// 验证任务数据
  static String? validateTaskData({
    required String title,
    required String description,
    required String category,
    required int rewardPoints,
    required DateTime deadline,
  }) {
    if (title.trim().isEmpty) {
      return '任务标题不能为空';
    }
    if (title.length > 200) {
      return '任务标题不能超过200个字符';
    }
    if (description.trim().isEmpty) {
      return '任务描述不能为空';
    }
    if (description.length > 2000) {
      return '任务描述不能超过2000个字符';
    }
    if (rewardPoints < 0) {
      return '悬赏积分不能为负数';
    }
    if (deadline.isBefore(DateTime.now())) {
      return '截止时间不能早于当前时间';
    }
    if (deadline.isAfter(DateTime.now().add(const Duration(days: 365)))) {
      return '截止时间不能超过一年';
    }

    return null; // 验证通过
  }

  /// 格式化任务状态
  static String formatTaskStatus(TaskStatus status) {
    return status.label;
  }

  /// 格式化任务分类
  static String formatTaskCategory(TaskCategory category) {
    return category.label;
  }

  /// 计算任务紧急程度
  static String getTaskUrgencyLevel(Task task) {
    final now = DateTime.now();
    final timeLeft = task.deadline.difference(now);

    if (task.isUrgent) {
      return '紧急';
    } else if (timeLeft.inHours < 24) {
      return '即将截止';
    } else if (timeLeft.inDays < 3) {
      return '紧急';
    } else if (timeLeft.inDays < 7) {
      return '一般';
    } else {
      return '充足';
    }
  }

  /// 格式化时间剩余
  static String formatTimeLeft(DateTime deadline) {
    final now = DateTime.now();
    final difference = deadline.difference(now);

    if (difference.isNegative) {
      return '已截止';
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '剩余${days}天';
    } else if (hours > 0) {
      return '剩余${hours}小时';
    } else if (minutes > 0) {
      return '剩余${minutes}分钟';
    } else {
      return '即将截止';
    }
  }
}