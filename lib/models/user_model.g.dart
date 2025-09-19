// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  studentNumber: json['student_number'] as String,
  email: json['email'] as String,
  nickname: json['nickname'] as String,
  realName: json['real_name'] as String,
  major: json['major'] as String,
  grade: (json['grade'] as num).toInt(),
  avatarUrl: json['avatar_url'] as String?,
  phone: json['phone'] as String?,
  status: (json['status'] as num).toInt(),
  lastLoginTime: json['last_login_time'] == null
      ? null
      : DateTime.parse(json['last_login_time'] as String),
  createdAt: DateTime.parse(json['created_at'] as String),
  updatedAt: DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'student_number': instance.studentNumber,
  'email': instance.email,
  'nickname': instance.nickname,
  'real_name': instance.realName,
  'major': instance.major,
  'grade': instance.grade,
  'avatar_url': instance.avatarUrl,
  'phone': instance.phone,
  'status': instance.status,
  'last_login_time': instance.lastLoginTime?.toIso8601String(),
  'created_at': instance.createdAt.toIso8601String(),
  'updated_at': instance.updatedAt.toIso8601String(),
};

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
  userId: json['userId'] as String,
  bio: json['bio'] as String?,
  interests: (json['interests'] as List<dynamic>?)
      ?.map((e) => e as String)
      .toList(),
  location: json['location'] as String?,
  socialLinks: (json['socialLinks'] as Map<String, dynamic>?)?.map(
    (k, e) => MapEntry(k, e as String),
  ),
  totalPoints: (json['totalPoints'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  postsCount: (json['postsCount'] as num).toInt(),
  commentsCount: (json['commentsCount'] as num).toInt(),
  likesReceived: (json['likesReceived'] as num).toInt(),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'bio': instance.bio,
      'interests': instance.interests,
      'location': instance.location,
      'socialLinks': instance.socialLinks,
      'totalPoints': instance.totalPoints,
      'level': instance.level,
      'postsCount': instance.postsCount,
      'commentsCount': instance.commentsCount,
      'likesReceived': instance.likesReceived,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

LoginRequest _$LoginRequestFromJson(Map<String, dynamic> json) => LoginRequest(
  account: json['account'] as String,
  password: json['password'] as String,
);

Map<String, dynamic> _$LoginRequestToJson(LoginRequest instance) =>
    <String, dynamic>{
      'account': instance.account,
      'password': instance.password,
    };

RegisterRequest _$RegisterRequestFromJson(Map<String, dynamic> json) =>
    RegisterRequest(
      studentNumber: json['student_number'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      realName: json['real_name'] as String,
      major: json['major'] as String,
      grade: (json['grade'] as num).toInt(),
    );

Map<String, dynamic> _$RegisterRequestToJson(RegisterRequest instance) =>
    <String, dynamic>{
      'student_number': instance.studentNumber,
      'email': instance.email,
      'password': instance.password,
      'real_name': instance.realName,
      'major': instance.major,
      'grade': instance.grade,
    };

LoginResponse _$LoginResponseFromJson(Map<String, dynamic> json) =>
    LoginResponse(
      token: json['token'] as String,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      userProfile: UserProfile.fromJson(
        json['userProfile'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$LoginResponseToJson(LoginResponse instance) =>
    <String, dynamic>{
      'token': instance.token,
      'user': instance.user,
      'userProfile': instance.userProfile,
    };
