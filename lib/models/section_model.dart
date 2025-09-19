/// 版块相关数据模型 - 与section_tables.sql和server.js保持一致

/// 版块模型
class Section {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String? coverImage;
  final String color;
  final String creatorId;
  final List<String>? moderatorIds;
  final int memberCount;
  final int postCount;
  final bool isPublic;
  final int joinPermission; // 1-自由加入,2-需要审核,3-仅邀请
  final int postPermission; // 1-所有成员,2-管理员,3-版主和管理员
  final String? rules;
  final List<String>? tags;
  final int sortOrder;
  final int status; // 0-删除,1-正常,2-隐藏
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? creatorName; // 通过JOIN查询获得

  const Section({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.coverImage,
    required this.color,
    required this.creatorId,
    this.moderatorIds,
    required this.memberCount,
    required this.postCount,
    required this.isPublic,
    required this.joinPermission,
    required this.postPermission,
    this.rules,
    this.tags,
    required this.sortOrder,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.creatorName,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      coverImage: json['cover_image'] as String?,
      color: json['color'] as String? ?? '#007AFF',
      creatorId: json['creator_id'] as String,
      moderatorIds: json['moderator_ids'] != null
          ? List<String>.from(json['moderator_ids'] as List)
          : null,
      memberCount: json['member_count'] as int,
      postCount: json['post_count'] as int,
      isPublic: (json['is_public'] as int) == 1,
      joinPermission: json['join_permission'] as int,
      postPermission: json['post_permission'] as int,
      rules: json['rules'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      sortOrder: json['sort_order'] as int,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      creatorName: json['creator_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'cover_image': coverImage,
      'color': color,
      'creator_id': creatorId,
      'moderator_ids': moderatorIds,
      'member_count': memberCount,
      'post_count': postCount,
      'is_public': isPublic ? 1 : 0,
      'join_permission': joinPermission,
      'post_permission': postPermission,
      'rules': rules,
      'tags': tags,
      'sort_order': sortOrder,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'creator_name': creatorName,
    };
  }

  /// 加入权限说明文本
  String get joinPermissionText {
    switch (joinPermission) {
      case 1:
        return '自由加入';
      case 2:
        return '需要审核';
      case 3:
        return '仅邀请';
      default:
        return '未知';
    }
  }

  /// 发帖权限说明文本
  String get postPermissionText {
    switch (postPermission) {
      case 1:
        return '所有成员';
      case 2:
        return '管理员';
      case 3:
        return '版主和管理员';
      default:
        return '未知';
    }
  }
}

/// 版块成员模型
class SectionMember {
  final String id;
  final String sectionId;
  final String userId;
  final int role; // 1-普通成员,2-管理员,3-创建者
  final String? joinReason;
  final int status; // 0-待审核,1-正常,2-被禁,3-已退出
  final DateTime? muteUntil;
  final DateTime joinedAt;
  final DateTime updatedAt;

  const SectionMember({
    required this.id,
    required this.sectionId,
    required this.userId,
    required this.role,
    this.joinReason,
    required this.status,
    this.muteUntil,
    required this.joinedAt,
    required this.updatedAt,
  });

  factory SectionMember.fromJson(Map<String, dynamic> json) {
    return SectionMember(
      id: json['id'] as String,
      sectionId: json['section_id'] as String,
      userId: json['user_id'] as String,
      role: json['role'] as int,
      joinReason: json['join_reason'] as String?,
      status: json['status'] as int,
      muteUntil: json['mute_until'] != null
          ? DateTime.parse(json['mute_until'] as String)
          : null,
      joinedAt: DateTime.parse(json['joined_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// 角色文本
  String get roleText {
    switch (role) {
      case 1:
        return '普通成员';
      case 2:
        return '管理员';
      case 3:
        return '创建者';
      default:
        return '未知';
    }
  }

  /// 是否被禁言
  bool get isMuted {
    return muteUntil != null && muteUntil!.isAfter(DateTime.now());
  }
}

/// 版块帖子模型
class SectionPost {
  final String id;
  final String sectionId;
  final String userId;
  final String title;
  final String content;
  final int contentType; // 1-文字,2-图片,3-视频,4-链接
  final List<String>? images;
  final String? videoUrl;
  final String? linkUrl;
  final List<String>? tags;
  final bool isAnonymous;
  final bool isPinned;
  final bool isHot;
  final bool isLocked;
  final int viewCount;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final DateTime? lastCommentTime;
  final int status; // 0-删除,1-正常,2-隐藏,3-违规下架,4-审核中
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorName;
  final String? authorAvatar;

  const SectionPost({
    required this.id,
    required this.sectionId,
    required this.userId,
    required this.title,
    required this.content,
    required this.contentType,
    this.images,
    this.videoUrl,
    this.linkUrl,
    this.tags,
    required this.isAnonymous,
    required this.isPinned,
    required this.isHot,
    required this.isLocked,
    required this.viewCount,
    required this.likeCount,
    required this.commentCount,
    required this.shareCount,
    this.lastCommentTime,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatar,
  });

  factory SectionPost.fromJson(Map<String, dynamic> json) {
    return SectionPost(
      id: json['id'] as String,
      sectionId: json['section_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      contentType: json['content_type'] as int,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      videoUrl: json['video_url'] as String?,
      linkUrl: json['link_url'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : null,
      isAnonymous: (json['is_anonymous'] as int) == 1,
      isPinned: (json['is_pinned'] as int) == 1,
      isHot: (json['is_hot'] as int) == 1,
      isLocked: (json['is_locked'] as int) == 1,
      viewCount: json['view_count'] as int,
      likeCount: json['like_count'] as int,
      commentCount: json['comment_count'] as int,
      shareCount: json['share_count'] as int,
      lastCommentTime: json['last_comment_time'] != null
          ? DateTime.parse(json['last_comment_time'] as String)
          : null,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorName: json['author_name'] as String?,
      authorAvatar: json['author_avatar'] as String?,
    );
  }

  /// 内容类型文本
  String get contentTypeText {
    switch (contentType) {
      case 1:
        return '文字';
      case 2:
        return '图片';
      case 3:
        return '视频';
      case 4:
        return '链接';
      default:
        return '未知';
    }
  }

  /// 是否有媒体内容
  bool get hasMedia => images != null && images!.isNotEmpty || videoUrl != null;

  /// 复制并更新字段
  SectionPost copyWith({
    String? id,
    String? sectionId,
    String? userId,
    String? title,
    String? content,
    int? contentType,
    List<String>? images,
    String? videoUrl,
    String? linkUrl,
    List<String>? tags,
    bool? isAnonymous,
    bool? isPinned,
    bool? isHot,
    bool? isLocked,
    int? viewCount,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    DateTime? lastCommentTime,
    int? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? authorName,
    String? authorAvatar,
  }) {
    return SectionPost(
      id: id ?? this.id,
      sectionId: sectionId ?? this.sectionId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      contentType: contentType ?? this.contentType,
      images: images ?? this.images,
      videoUrl: videoUrl ?? this.videoUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      tags: tags ?? this.tags,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isPinned: isPinned ?? this.isPinned,
      isHot: isHot ?? this.isHot,
      isLocked: isLocked ?? this.isLocked,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      shareCount: shareCount ?? this.shareCount,
      lastCommentTime: lastCommentTime ?? this.lastCommentTime,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
    );
  }
}

/// 版块帖子评论模型
class SectionPostComment {
  final String id;
  final String postId;
  final String userId;
  final String? parentId;
  final String? replyToUserId;
  final String content;
  final List<String>? images;
  final bool isAnonymous;
  final int likeCount;
  final int replyCount;
  final int status; // 0-删除,1-正常,2-隐藏
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? authorName;
  final String? authorAvatar;

  const SectionPostComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    this.replyToUserId,
    required this.content,
    this.images,
    required this.isAnonymous,
    required this.likeCount,
    required this.replyCount,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.authorName,
    this.authorAvatar,
  });

  factory SectionPostComment.fromJson(Map<String, dynamic> json) {
    return SectionPostComment(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      parentId: json['parent_id'] as String?,
      replyToUserId: json['reply_to_user_id'] as String?,
      content: json['content'] as String,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : null,
      isAnonymous: (json['is_anonymous'] as int) == 1,
      likeCount: json['like_count'] as int,
      replyCount: json['reply_count'] as int,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      authorName: json['author_name'] as String?,
      authorAvatar: json['author_avatar'] as String?,
    );
  }

  /// 是否是回复
  bool get isReply => parentId != null;
}

/// 创建版块请求模型
class CreateSectionRequest {
  final String name;
  final String description;
  final String icon;
  final String color;
  final bool isPublic;
  final int joinPermission;
  final int postPermission;
  final String? rules;
  final List<String> tags;

  const CreateSectionRequest({
    required this.name,
    required this.description,
    this.icon = 'default',
    this.color = '#007AFF',
    this.isPublic = true,
    this.joinPermission = 1,
    this.postPermission = 1,
    this.rules,
    this.tags = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'is_public': isPublic ? 1 : 0,
      'join_permission': joinPermission,
      'post_permission': postPermission,
      'rules': rules,
      'tags': tags,
    };
  }
}

/// 加入版块请求模型
class JoinSectionRequest {
  final String? joinReason;

  const JoinSectionRequest({this.joinReason});

  Map<String, dynamic> toJson() {
    return {
      'join_reason': joinReason,
    };
  }
}

/// 创建版块帖子请求模型
class CreateSectionPostRequest {
  final String title;
  final String content;
  final int contentType;
  final List<String> images;
  final String? videoUrl;
  final String? linkUrl;
  final List<String> tags;
  final bool isAnonymous;

  const CreateSectionPostRequest({
    required this.title,
    required this.content,
    this.contentType = 1,
    this.images = const [],
    this.videoUrl,
    this.linkUrl,
    this.tags = const [],
    this.isAnonymous = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'content': content,
      'content_type': contentType,
      'images': images,
      'video_url': videoUrl,
      'link_url': linkUrl,
      'tags': tags,
      'is_anonymous': isAnonymous ? 1 : 0,
    };
  }
}

/// 创建评论请求模型
class CreateCommentRequest {
  final String content;
  final String? parentId;
  final String? replyToUserId;
  final List<String> images;
  final bool isAnonymous;

  const CreateCommentRequest({
    required this.content,
    this.parentId,
    this.replyToUserId,
    this.images = const [],
    this.isAnonymous = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'parent_id': parentId,
      'reply_to_user_id': replyToUserId,
      'images': images,
      'is_anonymous': isAnonymous ? 1 : 0,
    };
  }
}

/// 版块列表响应模型
class SectionListResponse {
  final List<Section> sections;
  final PaginationInfo pagination;

  const SectionListResponse({
    required this.sections,
    required this.pagination,
  });

  factory SectionListResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return SectionListResponse(
      sections: (data['sections'] as List)
          .map((e) => Section.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: PaginationInfo.fromJson(data['pagination'] as Map<String, dynamic>),
    );
  }
}

/// 分页信息模型
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int totalPages;

  const PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int,
    );
  }
}