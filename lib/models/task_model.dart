/// 任务状态枚举
enum TaskStatus {
  deleted(0, '已删除'),
  recruiting(1, '招募中'),
  inProgress(2, '进行中'),
  completed(3, '已完成'),
  cancelled(4, '已取消'),
  reviewing(5, '审核中');

  const TaskStatus(this.value, this.label);
  final int value;
  final String label;

  static TaskStatus fromValue(int value) {
    return TaskStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskStatus.recruiting,
    );
  }
}

/// 任务分类枚举
enum TaskCategory {
  general('general', '普通任务'),
  study('study', '学习帮助'),
  delivery('delivery', '跑腿代取'),
  tech('tech', '技术服务'),
  other('other', '其他');

  const TaskCategory(this.value, this.label);
  final String value;
  final String label;

  static TaskCategory fromValue(String value) {
    return TaskCategory.values.firstWhere(
      (category) => category.value == value,
      orElse: () => TaskCategory.general,
    );
  }
}

/// 任务申请状态枚举
enum TaskApplicationStatus {
  cancelled(0, '已取消'),
  pending(1, '待审核'),
  accepted(2, '已接受'),
  rejected(3, '已拒绝');

  const TaskApplicationStatus(this.value, this.label);
  final int value;
  final String label;

  static TaskApplicationStatus fromValue(int value) {
    return TaskApplicationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskApplicationStatus.pending,
    );
  }
}

/// 任务执行状态枚举
enum TaskExecutionStatus {
  inProgress(1, '进行中'),
  completed(2, '已完成'),
  cancelled(3, '已取消');

  const TaskExecutionStatus(this.value, this.label);
  final int value;
  final String label;

  static TaskExecutionStatus fromValue(int value) {
    return TaskExecutionStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => TaskExecutionStatus.inProgress,
    );
  }
}

/// 任务模型
class Task {
  final String id;
  final String title;
  final String description;
  final String publisherId;
  final String category;
  final int rewardPoints;
  final double? rewardMoney;
  final DateTime deadline;
  final String? location;
  final String? requirements;
  final String? contactInfo;
  final List<String>? images;
  final List<String>? tags;
  final int? maxApplicants;
  final int currentApplicants;
  final int status;
  final bool isUrgent;
  final int viewCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 扩展字段 (从关联查询获得)
  final String? publisherName;
  final String? publisherAvatar;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.publisherId,
    required this.category,
    required this.rewardPoints,
    this.rewardMoney,
    required this.deadline,
    this.location,
    this.requirements,
    this.contactInfo,
    this.images,
    this.tags,
    this.maxApplicants,
    required this.currentApplicants,
    required this.status,
    required this.isUrgent,
    required this.viewCount,
    required this.createdAt,
    required this.updatedAt,
    this.publisherName,
    this.publisherAvatar,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      publisherId: json['publisher_id'] as String,
      category: json['category'] as String,
      rewardPoints: json['reward_points'] as int,
      rewardMoney: (json['reward_money'] as num?)?.toDouble(),
      deadline: DateTime.parse(json['deadline'] as String),
      location: json['location'] as String?,
      requirements: json['requirements'] as String?,
      contactInfo: json['contact_info'] as String?,
      images: json['images'] != null ? List<String>.from(json['images'] as List) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags'] as List) : null,
      maxApplicants: json['max_applicants'] as int?,
      currentApplicants: json['current_applicants'] as int,
      status: json['status'] as int,
      isUrgent: (json['is_urgent'] as int) == 1,
      viewCount: json['view_count'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      publisherName: json['publisher_name'] as String?,
      publisherAvatar: json['publisher_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'publisher_id': publisherId,
      'category': category,
      'reward_points': rewardPoints,
      'reward_money': rewardMoney,
      'deadline': deadline.toIso8601String(),
      'location': location,
      'requirements': requirements,
      'contact_info': contactInfo,
      'images': images,
      'tags': tags,
      'max_applicants': maxApplicants,
      'current_applicants': currentApplicants,
      'status': status,
      'is_urgent': isUrgent ? 1 : 0,
      'view_count': viewCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'publisher_name': publisherName,
      'publisher_avatar': publisherAvatar,
    };
  }

  /// 获取任务状态
  TaskStatus get taskStatus => TaskStatus.fromValue(status);

  /// 获取任务分类
  TaskCategory get taskCategory => TaskCategory.fromValue(category);

  /// 是否已截止
  bool get isExpired => DateTime.now().isAfter(deadline);

  /// 是否可以申请
  bool get canApply {
    if (taskStatus != TaskStatus.recruiting) return false;
    if (isExpired) return false;
    if (maxApplicants != null && currentApplicants >= maxApplicants!) return false;
    return true;
  }

  /// 复制并更新字段
  Task copyWith({
    String? id,
    String? title,
    String? description,
    String? publisherId,
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
    int? currentApplicants,
    int? status,
    bool? isUrgent,
    int? viewCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? publisherName,
    String? publisherAvatar,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      publisherId: publisherId ?? this.publisherId,
      category: category ?? this.category,
      rewardPoints: rewardPoints ?? this.rewardPoints,
      rewardMoney: rewardMoney ?? this.rewardMoney,
      deadline: deadline ?? this.deadline,
      location: location ?? this.location,
      requirements: requirements ?? this.requirements,
      contactInfo: contactInfo ?? this.contactInfo,
      images: images ?? this.images,
      tags: tags ?? this.tags,
      maxApplicants: maxApplicants ?? this.maxApplicants,
      currentApplicants: currentApplicants ?? this.currentApplicants,
      status: status ?? this.status,
      isUrgent: isUrgent ?? this.isUrgent,
      viewCount: viewCount ?? this.viewCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      publisherName: publisherName ?? this.publisherName,
      publisherAvatar: publisherAvatar ?? this.publisherAvatar,
    );
  }
}

/// 任务申请模型
class TaskApplication {
  final String id;
  final String taskId;
  final String applicantId;
  final String? applicationReason;
  final DateTime? proposedCompletionTime;
  final String? contactInfo;
  final int status;
  final DateTime appliedAt;
  final DateTime updatedAt;

  // 扩展字段
  final String? applicantName;
  final String? applicantAvatar;
  final String? taskTitle;

  const TaskApplication({
    required this.id,
    required this.taskId,
    required this.applicantId,
    this.applicationReason,
    this.proposedCompletionTime,
    this.contactInfo,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.applicantName,
    this.applicantAvatar,
    this.taskTitle,
  });

  factory TaskApplication.fromJson(Map<String, dynamic> json) {
    return TaskApplication(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      applicantId: json['applicant_id'] as String,
      applicationReason: json['application_reason'] as String?,
      proposedCompletionTime: json['proposed_completion_time'] != null
          ? DateTime.parse(json['proposed_completion_time'] as String)
          : null,
      contactInfo: json['contact_info'] as String?,
      status: json['status'] as int,
      appliedAt: DateTime.parse(json['applied_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      applicantName: json['applicant_name'] as String?,
      applicantAvatar: json['applicant_avatar'] as String?,
      taskTitle: json['task_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'applicant_id': applicantId,
      'application_reason': applicationReason,
      'proposed_completion_time': proposedCompletionTime?.toIso8601String(),
      'contact_info': contactInfo,
      'status': status,
      'applied_at': appliedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'applicant_name': applicantName,
      'applicant_avatar': applicantAvatar,
      'task_title': taskTitle,
    };
  }

  /// 获取申请状态
  TaskApplicationStatus get applicationStatus => TaskApplicationStatus.fromValue(status);

  /// 复制并更新字段
  TaskApplication copyWith({
    String? id,
    String? taskId,
    String? applicantId,
    String? applicationReason,
    DateTime? proposedCompletionTime,
    String? contactInfo,
    int? status,
    DateTime? appliedAt,
    DateTime? updatedAt,
    String? applicantName,
    String? applicantAvatar,
    String? taskTitle,
  }) {
    return TaskApplication(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      applicantId: applicantId ?? this.applicantId,
      applicationReason: applicationReason ?? this.applicationReason,
      proposedCompletionTime: proposedCompletionTime ?? this.proposedCompletionTime,
      contactInfo: contactInfo ?? this.contactInfo,
      status: status ?? this.status,
      appliedAt: appliedAt ?? this.appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      applicantName: applicantName ?? this.applicantName,
      applicantAvatar: applicantAvatar ?? this.applicantAvatar,
      taskTitle: taskTitle ?? this.taskTitle,
    );
  }
}

/// 任务执行记录模型
class TaskExecution {
  final String id;
  final String taskId;
  final String executorId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final int progress;
  final String? progressNotes;
  final List<String>? completionProof;
  final String? completionNotes;
  final int? rating;
  final String? feedback;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 扩展字段
  final String? executorName;
  final String? executorAvatar;
  final String? taskTitle;

  const TaskExecution({
    required this.id,
    required this.taskId,
    required this.executorId,
    required this.startedAt,
    this.completedAt,
    required this.progress,
    this.progressNotes,
    this.completionProof,
    this.completionNotes,
    this.rating,
    this.feedback,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.executorName,
    this.executorAvatar,
    this.taskTitle,
  });

  factory TaskExecution.fromJson(Map<String, dynamic> json) {
    return TaskExecution(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      executorId: json['executor_id'] as String,
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      progress: json['progress'] as int,
      progressNotes: json['progress_notes'] as String?,
      completionProof: json['completion_proof'] != null
          ? List<String>.from(json['completion_proof'] as List)
          : null,
      completionNotes: json['completion_notes'] as String?,
      rating: json['rating'] as int?,
      feedback: json['feedback'] as String?,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      executorName: json['executor_name'] as String?,
      executorAvatar: json['executor_avatar'] as String?,
      taskTitle: json['task_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'executor_id': executorId,
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'progress': progress,
      'progress_notes': progressNotes,
      'completion_proof': completionProof,
      'completion_notes': completionNotes,
      'rating': rating,
      'feedback': feedback,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'executor_name': executorName,
      'executor_avatar': executorAvatar,
      'task_title': taskTitle,
    };
  }

  /// 获取执行状态
  TaskExecutionStatus get executionStatus => TaskExecutionStatus.fromValue(status);

  /// 是否已完成
  bool get isCompleted => progress == 100 && completedAt != null;

  /// 复制并更新字段
  TaskExecution copyWith({
    String? id,
    String? taskId,
    String? executorId,
    DateTime? startedAt,
    DateTime? completedAt,
    int? progress,
    String? progressNotes,
    List<String>? completionProof,
    String? completionNotes,
    int? rating,
    String? feedback,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? executorName,
    String? executorAvatar,
    String? taskTitle,
  }) {
    return TaskExecution(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      executorId: executorId ?? this.executorId,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      progress: progress ?? this.progress,
      progressNotes: progressNotes ?? this.progressNotes,
      completionProof: completionProof ?? this.completionProof,
      completionNotes: completionNotes ?? this.completionNotes,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      executorName: executorName ?? this.executorName,
      executorAvatar: executorAvatar ?? this.executorAvatar,
      taskTitle: taskTitle ?? this.taskTitle,
    );
  }
}

/// 任务评论模型
class TaskComment {
  final String id;
  final String taskId;
  final String userId;
  final String? parentId;
  final String content;
  final List<String>? images;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  // 扩展字段
  final String? userName;
  final String? userAvatar;

  const TaskComment({
    required this.id,
    required this.taskId,
    required this.userId,
    this.parentId,
    required this.content,
    this.images,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.userName,
    this.userAvatar,
  });

  factory TaskComment.fromJson(Map<String, dynamic> json) {
    return TaskComment(
      id: json['id'] as String,
      taskId: json['task_id'] as String,
      userId: json['user_id'] as String,
      parentId: json['parent_id'] as String?,
      content: json['content'] as String,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      userName: json['user_name'] as String?,
      userAvatar: json['user_avatar'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_id': taskId,
      'user_id': userId,
      'parent_id': parentId,
      'content': content,
      'images': images,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'user_name': userName,
      'user_avatar': userAvatar,
    };
  }

  /// 是否为回复
  bool get isReply => parentId != null;

  /// 复制并更新字段
  TaskComment copyWith({
    String? id,
    String? taskId,
    String? userId,
    String? parentId,
    String? content,
    List<String>? images,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userAvatar,
  }) {
    return TaskComment(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      userId: userId ?? this.userId,
      parentId: parentId ?? this.parentId,
      content: content ?? this.content,
      images: images ?? this.images,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userAvatar: userAvatar ?? this.userAvatar,
    );
  }
}

/// 任务发布请求模型
class CreateTaskRequest {
  final String title;
  final String description;
  final String category;
  final int rewardPoints;
  final double? rewardMoney;
  final DateTime deadline;
  final String? location;
  final String? requirements;
  final String? contactInfo;
  final List<String>? images;
  final List<String>? tags;
  final int? maxApplicants;
  final bool isUrgent;

  const CreateTaskRequest({
    required this.title,
    required this.description,
    required this.category,
    required this.rewardPoints,
    this.rewardMoney,
    required this.deadline,
    this.location,
    this.requirements,
    this.contactInfo,
    this.images,
    this.tags,
    this.maxApplicants,
    required this.isUrgent,
  });

  factory CreateTaskRequest.fromJson(Map<String, dynamic> json) {
    return CreateTaskRequest(
      title: json['title'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      rewardPoints: json['reward_points'] as int,
      rewardMoney: (json['reward_money'] as num?)?.toDouble(),
      deadline: DateTime.parse(json['deadline'] as String),
      location: json['location'] as String?,
      requirements: json['requirements'] as String?,
      contactInfo: json['contact_info'] as String?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      maxApplicants: json['max_applicants'] as int?,
      isUrgent: (json['is_urgent'] as int) == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'reward_points': rewardPoints,
      'reward_money': rewardMoney,
      'deadline': deadline.toIso8601String(),
      'location': location,
      'requirements': requirements,
      'contact_info': contactInfo,
      'images': images,
      'tags': tags,
      'max_applicants': maxApplicants,
      'is_urgent': isUrgent ? 1 : 0,
    };
  }
}

/// 任务申请请求模型
class CreateTaskApplicationRequest {
  final String? applicationReason;
  final DateTime? proposedCompletionTime;
  final String? contactInfo;

  const CreateTaskApplicationRequest({
    this.applicationReason,
    this.proposedCompletionTime,
    this.contactInfo,
  });

  factory CreateTaskApplicationRequest.fromJson(Map<String, dynamic> json) {
    return CreateTaskApplicationRequest(
      applicationReason: json['application_reason'] as String?,
      proposedCompletionTime: json['proposed_completion_time'] != null
          ? DateTime.parse(json['proposed_completion_time'] as String)
          : null,
      contactInfo: json['contact_info'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'application_reason': applicationReason,
      'proposed_completion_time': proposedCompletionTime?.toIso8601String(),
      'contact_info': contactInfo,
    };
  }
}

/// 任务列表响应模型
class TaskListResponse {
  final List<Task> tasks;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  const TaskListResponse({
    required this.tasks,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory TaskListResponse.fromJson(Map<String, dynamic> json) {
    return TaskListResponse(
      tasks: (json['tasks'] as List)
          .map((e) => Task.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int,
      page: json['page'] as int,
      limit: json['limit'] as int,
      totalPages: json['totalPages'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tasks': tasks.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'limit': limit,
      'totalPages': totalPages,
    };
  }
}