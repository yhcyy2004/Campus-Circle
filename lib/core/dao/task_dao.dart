import '../../models/task_model.dart';
import '../models/result.dart';

/// 任务数据访问对象
abstract class TaskDAO {
  /// 获取任务列表
  Future<ApiResult<TaskListResponse>> getTasks({
    int page = 1,
    int limit = 20,
    String? category,
    String? status,
    String? sort,
    String? search,
  });

  /// 获取任务详情
  Future<ApiResult<Task>> getTaskDetail(String taskId);

  /// 创建任务
  Future<ApiResult<Task>> createTask(CreateTaskRequest request);

  /// 更新任务
  Future<ApiResult<Task>> updateTask(String taskId, Map<String, dynamic> updates);

  /// 删除任务
  Future<ApiResult<void>> deleteTask(String taskId);

  /// 申请任务
  Future<ApiResult<TaskApplication>> applyForTask(String taskId, CreateTaskApplicationRequest request);

  /// 获取任务申请列表
  Future<ApiResult<List<TaskApplication>>> getTaskApplications(String taskId);

  /// 处理任务申请
  Future<ApiResult<TaskApplication>> handleTaskApplication(String applicationId, bool accept, String? reason);

  /// 获取我的申请列表
  Future<ApiResult<List<TaskApplication>>> getMyApplications({
    int page = 1,
    int limit = 20,
    String? status,
  });

  /// 获取我发布的任务
  Future<ApiResult<List<Task>>> getMyTasks({
    int page = 1,
    int limit = 20,
    String? status,
  });

  /// 收藏/取消收藏任务
  Future<ApiResult<void>> toggleTaskFavorite(String taskId);

  /// 获取收藏的任务
  Future<ApiResult<List<Task>>> getFavoriteTasks({
    int page = 1,
    int limit = 20,
  });

  /// 更新任务进度
  Future<ApiResult<TaskExecution>> updateTaskProgress(String taskId, int progress, String? notes);

  /// 提交任务完成
  Future<ApiResult<TaskExecution>> submitTaskCompletion(
    String taskId,
    List<String>? proofImages,
    String? notes,
  );

  /// 获取任务评论
  Future<ApiResult<List<TaskComment>>> getTaskComments(String taskId, {int page = 1, int limit = 50});

  /// 添加任务评论
  Future<ApiResult<TaskComment>> addTaskComment(String taskId, String content, {String? parentId, List<String>? images});

  /// 获取任务执行记录
  Future<ApiResult<List<TaskExecution>>> getTaskExecutions(String taskId);

  /// 评价任务执行
  Future<ApiResult<TaskExecution>> rateTaskExecution(String executionId, int rating, String? feedback);

  /// 举报任务
  Future<ApiResult<void>> reportTask(String taskId, String reportType, String reason);
}