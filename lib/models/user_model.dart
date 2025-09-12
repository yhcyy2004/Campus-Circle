import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  @JsonKey(name: 'student_number')
  final String studentNumber;
  final String email;
  final String nickname;
  @JsonKey(name: 'real_name')
  final String realName;
  final String major;
  final int grade;
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  final String? phone;
  final int status; // 0-禁用,1-正常,2-待验证
  @JsonKey(name: 'last_login_time')
  final DateTime? lastLoginTime;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;
  @JsonKey(name: 'updated_at')
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

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class UserProfile {
  @JsonKey(name: 'userId')  // 改为驼峰命名匹配服务器返回的字段名
  final String userId;
  final String? bio;
  final List<String>? interests;
  final String? location;
  @JsonKey(name: 'socialLinks')  // 改为驼峰命名
  final Map<String, String>? socialLinks;
  @JsonKey(name: 'totalPoints')  // 改为驼峰命名
  final int totalPoints;
  final int level;
  @JsonKey(name: 'postsCount')  // 改为驼峰命名
  final int postsCount;
  @JsonKey(name: 'commentsCount')  // 改为驼峰命名
  final int commentsCount;
  @JsonKey(name: 'likesReceived')  // 改为驼峰命名
  final int likesReceived;
  @JsonKey(name: 'createdAt')  // 改为驼峰命名
  final DateTime createdAt;
  @JsonKey(name: 'updatedAt')  // 改为驼峰命名
  final DateTime updatedAt;

  const UserProfile({
    required this.userId,
    this.bio,
    this.interests,
    this.location,
    this.socialLinks,
    required this.totalPoints,
    required this.level,
    required this.postsCount,
    required this.commentsCount,
    required this.likesReceived,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);
  Map<String, dynamic> toJson() => _$UserProfileToJson(this);
}

// 登录请求模型
@JsonSerializable()
class LoginRequest {
  final String account; // 可以是学号或邮箱
  final String password;

  const LoginRequest({
    required this.account,
    required this.password,
  });

  factory LoginRequest.fromJson(Map<String, dynamic> json) => _$LoginRequestFromJson(json);
  Map<String, dynamic> toJson() => _$LoginRequestToJson(this);
}

// 注册请求模型
@JsonSerializable()
class RegisterRequest {
  @JsonKey(name: 'student_number')
  final String studentNumber;
  final String email;
  final String password;
  @JsonKey(name: 'real_name')
  final String realName;
  final String major;
  final int grade;

  const RegisterRequest({
    required this.studentNumber,
    required this.email,
    required this.password,
    required this.realName,
    required this.major,
    required this.grade,
  });

  factory RegisterRequest.fromJson(Map<String, dynamic> json) => _$RegisterRequestFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestToJson(this);
}

// 登录响应模型
@JsonSerializable()
class LoginResponse {
  final String token;
  final User user;
  @JsonKey(name: 'userProfile')
  final UserProfile userProfile;

  const LoginResponse({
    required this.token,
    required this.user,
    required this.userProfile,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => _$LoginResponseFromJson(json);
  Map<String, dynamic> toJson() => _$LoginResponseToJson(this);
}