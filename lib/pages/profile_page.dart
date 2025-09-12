import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../config/app_routes.dart';
import '../utils/helpers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  Future<void> _handleLogout() async {
    try {
      // 显示确认对话框
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('确认登出'),
          content: const Text('确定要登出当前账户吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('确定'),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        // 执行登出
        await _authService.logout();
        
        if (mounted) {
          Helpers.showToast(context, '已成功登出', isError: false);
          
          // 跳转到登录页
          context.go(AppRoutes.login);
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showToast(context, '登出失败，请稍后重试', isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final userProfile = _authService.currentUserProfile;

    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('我的'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingLarge),
        child: Column(
          children: [
            const SizedBox(height: 40),
            
            // 用户头像和信息
            _buildUserInfo(user, userProfile),
            
            const SizedBox(height: 40),
            
            // 功能列表
            _buildFeatureList(),
            
            const SizedBox(height: 40),
            
            // 登出按钮
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfo(user, userProfile) {
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
            radius: 40,
            backgroundColor: AppConstants.primaryColor,
            child: user?.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: Image.network(
                      user!.avatarUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                  )
                : const Icon(Icons.person, size: 40, color: Colors.white),
          ),
          
          const SizedBox(height: 16),
          
          // 用户昵称
          Text(
            user?.nickname ?? '未登录用户',
            style: const TextStyle(
              fontSize: AppConstants.fontSizeXLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 8),
          
          // 学号和邮箱
          if (user != null) ...[
            Text(
              '学号: ${user.studentNumber}',
              style: const TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '邮箱: ${user.email}',
              style: const TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ],
          
          // 用户等级和积分
          if (userProfile != null) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('等级', '${userProfile.level}'),
                _buildStatItem('积分', '${userProfile.totalPoints}'),
                _buildStatItem('帖子', '${userProfile.postsCount}'),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: AppConstants.fontSizeSmall,
            color: AppConstants.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureList() {
    return Container(
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
          _buildFeatureItem(
            icon: Icons.person,
            title: '查看个人资料',
            onTap: () {
              context.push(AppRoutes.profileDetail);
            },
          ),
          _buildDivider(),
          _buildFeatureItem(
            icon: Icons.edit,
            title: '编辑资料',
            onTap: () {
              context.push(AppRoutes.editProfile);
            },
          ),
          _buildDivider(),
          _buildFeatureItem(
            icon: Icons.settings,
            title: '设置',
            onTap: () {
              // TODO: 导航到设置页面
              Helpers.showToast(context, '功能开发中');
            },
          ),
          _buildDivider(),
          _buildFeatureItem(
            icon: Icons.help,
            title: '帮助与反馈',
            onTap: () {
              // TODO: 导航到帮助页面
              Helpers.showToast(context, '功能开发中');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppConstants.primaryColor,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: AppConstants.fontSizeMedium,
          color: AppConstants.textPrimaryColor,
        ),
      ),
      trailing: const Icon(
        Icons.chevron_right,
        color: AppConstants.textSecondaryColor,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 16,
      endIndent: 16,
      color: AppConstants.backgroundColor,
    );
  }

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleLogout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.errorColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
          ),
        ),
        child: const Text(
          '登出',
          style: TextStyle(
            fontSize: AppConstants.fontSizeLarge,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}