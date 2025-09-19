import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../config/app_routes.dart';

class ProfileDetailScreen extends StatelessWidget {
  const ProfileDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();
    final user = authService.currentUser;
    final userProfile = authService.currentUserProfile;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('个人资料'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            // 用户头像和基本信息
            _buildUserHeader(user, userProfile),
            
            const SizedBox(height: 24),
            
            // 详细信息
            _buildDetailInfo(user, userProfile),
            
            const SizedBox(height: 24),
            
            // 个人简介
            if (userProfile?.bio != null && userProfile!.bio!.isNotEmpty)
              _buildBioSection(userProfile.bio!),
            
            const SizedBox(height: 24),
            
            // 兴趣爱好
            if (userProfile?.interests != null && userProfile!.interests!.isNotEmpty)
              _buildInterestsSection(userProfile.interests!),
            
            const SizedBox(height: 24),
            
            // 社交信息
            if (userProfile?.socialLinks != null && userProfile!.socialLinks!.isNotEmpty)
              _buildSocialSection(userProfile.socialLinks!),
            
            const SizedBox(height: 24),
            
            // 统计信息
            _buildStatsSection(userProfile),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(User? user, UserProfile? userProfile) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 头像
          CircleAvatar(
            radius: 60,
            backgroundColor: AppConstants.primaryColor,
            child: user?.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Image.network(
                      user!.avatarUrl!,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.person, size: 60, color: Colors.white),
                    ),
                  )
                : const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          
          const SizedBox(height: 16),
          
          // 昵称
          Text(
            user?.nickname ?? '未知用户',
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 实名
          if (user?.realName != null) ...[
            Text(
              '${user!.realName}',
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // 等级和积分
          if (userProfile != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatChip('等级 ${userProfile.level}', Icons.star, Colors.orange),
                _buildStatChip('积分 ${userProfile.totalPoints}', Icons.local_fire_department, Colors.red),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: AppConstants.fontSizeSmall,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfo(User? user, UserProfile? userProfile) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '基本信息',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          if (user != null) ...[
            _buildInfoRow(Icons.badge, '学号', user.studentNumber),
            _buildInfoRow(Icons.email, '邮箱', user.email),
            _buildInfoRow(Icons.school, '专业', user.major),
            _buildInfoRow(Icons.calendar_today, '年级', '${user.grade}级'),
            if (user.phone != null && user.phone!.isNotEmpty)
              _buildInfoRow(Icons.phone, '手机', user.phone!),
            if (userProfile?.location != null && userProfile!.location!.isNotEmpty)
              _buildInfoRow(Icons.location_on, '位置', userProfile.location!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppConstants.primaryColor,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: AppConstants.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection(String bio) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '个人简介',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Text(
            bio,
            style: TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: AppConstants.textPrimaryColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection(List<String> interests) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '兴趣爱好',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
              ),
              child: Text(
                interest,
                style: TextStyle(
                  fontSize: AppConstants.fontSizeSmall,
                  color: AppConstants.primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialSection(Map<String, String> socialLinks) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '社交信息',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          ...socialLinks.entries.map((entry) {
            IconData icon;
            Color color;
            
            switch (entry.key.toLowerCase()) {
              case 'qq':
                icon = Icons.chat_bubble_outline;
                color = Colors.blue;
                break;
              case 'wechat':
                icon = Icons.wechat;
                color = Colors.green;
                break;
              case 'weibo':
                icon = Icons.alternate_email;
                color = Colors.orange;
                break;
              default:
                icon = Icons.link;
                color = AppConstants.primaryColor;
            }
            
            return _buildSocialRow(icon, _getSocialLabel(entry.key), entry.value, color);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildSocialRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: AppConstants.fontSizeMedium,
              color: AppConstants.textSecondaryColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getSocialLabel(String key) {
    switch (key.toLowerCase()) {
      case 'qq':
        return 'QQ';
      case 'wechat':
        return '微信';
      case 'weibo':
        return '微博';
      default:
        return key;
    }
  }

  Widget _buildStatsSection(UserProfile? userProfile) {
    if (userProfile == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '活动统计',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatItem('发帖', '${userProfile.postsCount}', Icons.article),
              ),
              Expanded(
                child: _buildStatItem('评论', '${userProfile.commentsCount}', Icons.comment),
              ),
              Expanded(
                child: _buildStatItem('获赞', '${userProfile.likesReceived}', Icons.favorite),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: AppConstants.primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppConstants.fontSizeSmall,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }
}