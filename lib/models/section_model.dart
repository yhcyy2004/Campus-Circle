int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  return null;
}

class Section {
  final String id;
  final String name;
  final String? description;
  final String? icon;
  final String color;
  final String creatorId;
  final String? creatorName;
  final int memberCount;
  final int postCount;
  final bool isPublic;
  final int joinPermission;
  final int postPermission;
  final String? rules;
  final List<String>? tags;
  final DateTime createdAt;

  Section({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    required this.color,
    required this.creatorId,
    this.creatorName,
    required this.memberCount,
    required this.postCount,
    required this.isPublic,
    required this.joinPermission,
    required this.postPermission,
    this.rules,
    this.tags,
    required this.createdAt,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'],
      icon: json['icon'],
      color: json['color'] ?? '#007AFF',
      creatorId: json['creator_id'] ?? '',
      creatorName: json['creator_name'],
      memberCount: _parseInt(json['member_count']) ?? 0,
      postCount: _parseInt(json['post_count']) ?? 0,
      isPublic: json['is_public'] == 1,
      joinPermission: _parseInt(json['join_permission']) ?? 1,
      postPermission: _parseInt(json['post_permission']) ?? 1,
      rules: json['rules'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] is String 
              ? [] 
              : json['tags'])
          : null,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'creator_id': creatorId,
      'creator_name': creatorName,
      'member_count': memberCount,
      'post_count': postCount,
      'is_public': isPublic ? 1 : 0,
      'join_permission': joinPermission,
      'post_permission': postPermission,
      'rules': rules,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class SectionPost {
  final String id;
  final String sectionId;
  final String userId;
  final String? authorName;
  final String? authorAvatar;
  final String title;
  final String content;
  final int contentType;
  final List<String>? images;
  final String? videoUrl;
  final String? linkUrl;
  final List<String>? tags;
  final bool isAnonymous;
  final bool isPinned;
  final bool isHot;
  final bool isLocked;
  final int viewCount;
  int likeCount; // 改为可变
  final int commentCount;
  final int shareCount;
  final DateTime? lastCommentTime;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SectionPost({
    required this.id,
    required this.sectionId,
    required this.userId,
    this.authorName,
    this.authorAvatar,
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
  });

  factory SectionPost.fromJson(Map<String, dynamic> json) {
    return SectionPost(
      id: json['id'] ?? '',
      sectionId: json['section_id'] ?? '',
      userId: json['user_id'] ?? '',
      authorName: json['author_name'],
      authorAvatar: json['author_avatar'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      contentType: _parseInt(json['content_type']) ?? 1,
      images: json['images'] != null 
          ? List<String>.from(json['images'] is String 
              ? [] 
              : json['images'])
          : null,
      videoUrl: json['video_url'],
      linkUrl: json['link_url'],
      tags: json['tags'] != null 
          ? List<String>.from(json['tags'] is String 
              ? [] 
              : json['tags'])
          : null,
      isAnonymous: json['is_anonymous'] == 1,
      isPinned: json['is_pinned'] == 1,
      isHot: json['is_hot'] == 1,
      isLocked: json['is_locked'] == 1,
      viewCount: _parseInt(json['view_count']) ?? 0,
      likeCount: _parseInt(json['like_count']) ?? 0,
      commentCount: _parseInt(json['comment_count']) ?? 0,
      shareCount: _parseInt(json['share_count']) ?? 0,
      lastCommentTime: json['last_comment_time'] != null 
          ? DateTime.tryParse(json['last_comment_time'])
          : null,
      status: _parseInt(json['status']) ?? 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_id': sectionId,
      'user_id': userId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'title': title,
      'content': content,
      'content_type': contentType,
      'images': images,
      'video_url': videoUrl,
      'link_url': linkUrl,
      'tags': tags,
      'is_anonymous': isAnonymous ? 1 : 0,
      'is_pinned': isPinned ? 1 : 0,
      'is_hot': isHot ? 1 : 0,
      'is_locked': isLocked ? 1 : 0,
      'view_count': viewCount,
      'like_count': likeCount,
      'comment_count': commentCount,
      'share_count': shareCount,
      'last_comment_time': lastCommentTime?.toIso8601String(),
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class SectionComment {
  final String id;
  final String postId;
  final String userId;
  final String? authorName;
  final String? authorAvatar;
  final String? parentId;
  final String? replyToUserId;
  final String content;
  final List<String>? images;
  final bool isAnonymous;
  final int likeCount;
  final int replyCount;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;

  SectionComment({
    required this.id,
    required this.postId,
    required this.userId,
    this.authorName,
    this.authorAvatar,
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
  });

  factory SectionComment.fromJson(Map<String, dynamic> json) {
    return SectionComment(
      id: json['id'] ?? '',
      postId: json['post_id'] ?? '',
      userId: json['user_id'] ?? '',
      authorName: json['author_name'],
      authorAvatar: json['author_avatar'],
      parentId: json['parent_id'],
      replyToUserId: json['reply_to_user_id'],
      content: json['content'] ?? '',
      images: json['images'] != null 
          ? List<String>.from(json['images'] is String 
              ? [] 
              : json['images'])
          : null,
      isAnonymous: json['is_anonymous'] == 1,
      likeCount: _parseInt(json['like_count']) ?? 0,
      replyCount: _parseInt(json['reply_count']) ?? 0,
      status: _parseInt(json['status']) ?? 1,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'author_name': authorName,
      'author_avatar': authorAvatar,
      'parent_id': parentId,
      'reply_to_user_id': replyToUserId,
      'content': content,
      'images': images,
      'is_anonymous': isAnonymous ? 1 : 0,
      'like_count': likeCount,
      'reply_count': replyCount,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}