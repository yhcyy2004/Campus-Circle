import '../models/result.dart';
import '../../models/user_model.dart';

abstract class UserDao {
  /// 用户注册
  Future<ApiResult<User>> createUser({
    required String studentNumber,
    required String email,
    required String password,
    required String nickname,
    required String realName,
    required String major,
    required int grade,
  });

  /// 用户登录
  Future<ApiResult<LoginResponse>> login({
    required String account,
    required String password,
  });

  /// 检查学号是否存在
  Future<bool> checkStudentNumberExists(String studentNumber);

  /// 检查邮箱是否存在
  Future<bool> checkEmailExists(String email);

  /// 根据ID获取用户信息
  Future<User?> getUserById(String userId);

  /// 更新用户资料
  Future<bool> updateUserProfile({
    required String userId,
    String? nickname,
    String? bio,
    String? avatarUrl,
  });
}