/// 用户相关数据模型 - 与server.js和数据库结构保持一致

/// 用户基本信息模型
class User {
  final String id;
  final String studentNumber;
  final String email;
  final String nickname;
  final String realName;
  final String major;
  final String grade;
  final String? avatarUrl;
  final String? phone;
  final int status;
  final DateTime? lastLoginTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const User({
    required this.id,
    required this.studentNumber,
    required this.email,
    required this.nickname,
    required this.realName,
    required this.major,
    required this.grade,
    this.avatarUrl,
    this.phone,
    required this.status,
    this.lastLoginTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      studentNumber: json['student_number'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      realName: json['real_name'] as String,
      major: json['major'] as String,
      grade: json['grade'] as String,
      avatarUrl: json['avatar_url'] as String?,
      phone: json['phone'] as String?,
      status: json['status'] as int,
      lastLoginTime: json['last_login_time'] != null
          ? DateTime.parse(json['last_login_time'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_number': studentNumber,
      'email': email,
      'nickname': nickname,
      'real_name': realName,
      'major': major,
      'grade': grade,
      'avatar_url': avatarUrl,
      'phone': phone,
      'status': status,
      'last_login_time': lastLoginTime?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? nickname,
    String? avatarUrl,
    String? phone,
    int? status,
    DateTime? lastLoginTime,
    DateTime? updatedAt,
  }) {
    return User(
      id: id,
      studentNumber: studentNumber,
      email: email,
      nickname: nickname ?? this.nickname,
      realName: realName,
      major: major,
      grade: grade,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      lastLoginTime: lastLoginTime ?? this.lastLoginTime,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'User(id: $id, nickname: $nickname, studentNumber: $studentNumber)';
}

/// 用户资料模型
class UserProfile {
  final String userId;
  final String? bio;
  final List<String>? interests;
  final String? location;
  final Map<String, String>? socialLinks;
  final Map<String, dynamic>? privacySettings;
  final int totalPoints;
  final int level;
  final int postsCount;
  final int commentsCount;
  final int likesReceived;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.userId,
    this.bio,
    this.interests,
    this.location,
    this.socialLinks,
    this.privacySettings,
    required this.totalPoints,
    required this.level,
    required this.postsCount,
    required this.commentsCount,
    required this.likesReceived,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      userId: json['userId'] as String,
      bio: json['bio'] as String?,
      interests: json['interests'] != null
          ? List<String>.from(json['interests'] as List)
          : null,
      location: json['location'] as String?,
      socialLinks: json['socialLinks'] != null
          ? Map<String, String>.from(json['socialLinks'] as Map)
          : null,
      privacySettings: json['privacySettings'] as Map<String, dynamic>?,
      totalPoints: json['totalPoints'] as int,
      level: json['level'] as int,
      postsCount: json['postsCount'] as int,
      commentsCount: json['commentsCount'] as int,
      likesReceived: json['likesReceived'] as int,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'bio': bio,
      'interests': interests,
      'location': location,
      'socialLinks': socialLinks,
      'privacySettings': privacySettings,
      'totalPoints': totalPoints,
      'level': level,
      'postsCount': postsCount,
      'commentsCount': commentsCount,
      'likesReceived': likesReceived,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? bio,
    List<String>? interests,
    String? location,
    Map<String, String>? socialLinks,
    Map<String, dynamic>? privacySettings,
    int? totalPoints,
    int? level,
    int? postsCount,
    int? commentsCount,
    int? likesReceived,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      userId: userId,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      socialLinks: socialLinks ?? this.socialLinks,
      privacySettings: privacySettings ?? this.privacySettings,
      totalPoints: totalPoints ?? this.totalPoints,
      level: level ?? this.level,
      postsCount: postsCount ?? this.postsCount,
      commentsCount: commentsCount ?? this.commentsCount,
      likesReceived: likesReceived ?? this.likesReceived,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// 用户注册请求模型
class RegisterRequest {
  final String studentNumber;
  final String email;
  final String password;
  final String nickname;
  final String realName;
  final String major;
  final String grade;

  const RegisterRequest({
    required this.studentNumber,
    required this.email,
    required this.password,
    required this.nickname,
    required this.realName,
    required this.major,
    required this.grade,
  });

  Map<String, dynamic> toJson() {
    return {
      'student_number': studentNumber,
      'email': email,
      'password': password,
      'nickname': nickname,
      'real_name': realName,
      'major': major,
      'grade': grade,
    };
  }
}

/// 用户登录请求模型
class LoginRequest {
  final String account; // 可以是学号或邮箱
  final String password;

  const LoginRequest({
    required this.account,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'account': account,
      'password': password,
    };
  }
}

/// 登录响应模型
class LoginResponse {
  final String token;
  final User user;
  final UserProfile userProfile;

  const LoginResponse({
    required this.token,
    required this.user,
    required this.userProfile,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return LoginResponse(
      token: data['token'] as String,
      user: User.fromJson(data['user'] as Map<String, dynamic>),
      userProfile: UserProfile.fromJson(data['userProfile'] as Map<String, dynamic>),
    );
  }
}

/// 更新用户资料请求模型
class UpdateProfileRequest {
  final String? nickname;
  final String? phone;
  final String? bio;
  final String? location;
  final List<String>? interests;
  final Map<String, String>? socialLinks;

  const UpdateProfileRequest({
    this.nickname,
    this.phone,
    this.bio,
    this.location,
    this.interests,
    this.socialLinks,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {};

    if (nickname != null) json['nickname'] = nickname;
    if (phone != null) json['phone'] = phone;
    if (bio != null) json['bio'] = bio;
    if (location != null) json['location'] = location;
    if (interests != null) json['interests'] = interests;
    if (socialLinks != null) json['socialLinks'] = socialLinks;

    return json;
  }
}