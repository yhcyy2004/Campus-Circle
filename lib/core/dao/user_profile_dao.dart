import '../../models/user_model.dart';

abstract class UserProfileDao {
  /// 根据用户ID获取用户详细信息
  Future<UserProfile?> getUserProfileById(String userId);

  /// 更新用户详细信息
  Future<bool> updateUserProfile(UserProfile profile);

  /// 创建用户详细信息
  Future<bool> createUserProfile(UserProfile profile);
}