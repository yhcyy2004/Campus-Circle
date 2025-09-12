import '../../../dao/database_connection.dart';
import '../user_profile_dao.dart';
import '../../../models/user_model.dart';

class UserProfileDaoImpl implements UserProfileDao {
  final DatabaseConnection _db = DatabaseConnection();

  @override
  Future<UserProfile?> getUserProfileById(String userId) async {
    try {
      final result = await _db.query('/users/$userId/profile');

      if (result['success'] == true && result['data'] != null) {
        final profileData = result['data'] as Map<String, dynamic>;
        return UserProfile.fromJson(profileData);
      } else {
        return null;
      }
    } catch (e) {
      print('获取用户详细信息失败: $e');
      return null;
    }
  }

  @override
  Future<bool> updateUserProfile(UserProfile profile) async {
    try {
      final result = await _db.update('/users/${profile.userId}/profile', data: {
        'bio': profile.bio,
        'interests': profile.interests,
        'location': profile.location,
        'social_links': profile.socialLinks,
        'total_points': profile.totalPoints,
        'level': profile.level,
        'posts_count': profile.postsCount,
        'comments_count': profile.commentsCount,
        'likes_received': profile.likesReceived,
      });

      return result['success'] == true;
    } catch (e) {
      print('更新用户详细信息失败: $e');
      return false;
    }
  }

  @override
  Future<bool> createUserProfile(UserProfile profile) async {
    try {
      final result = await _db.execute('/users/${profile.userId}/profile', data: {
        'bio': profile.bio,
        'interests': profile.interests,
        'location': profile.location,
        'social_links': profile.socialLinks,
        'total_points': profile.totalPoints,
        'level': profile.level,
        'posts_count': profile.postsCount,
        'comments_count': profile.commentsCount,
        'likes_received': profile.likesReceived,
      });

      return result['success'] == true;
    } catch (e) {
      print('创建用户详细信息失败: $e');
      return false;
    }
  }
}