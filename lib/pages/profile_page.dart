import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../config/app_routes.dart';
import '../utils/helpers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../animations/app_animations.dart';

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
      body: AppWidget.gradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                
                // 标题
                AppAnimations.fadeIn(
                  delay: 0.1,
                  child: _buildTitle(),
                ),
                
                const SizedBox(height: 30),
                
                // 用户信息卡片
                AppAnimations.slideIn(
                  delay: 0.2,
                  child: _buildUserCard(user, userProfile),
                ),
                
                const SizedBox(height: 24),
                
                // 统计数据
                AppAnimations.scaleIn(
                  delay: 0.3,
                  child: _buildStatsCard(userProfile),
                ),
                
                const SizedBox(height: 24),
                
                // 功能菜单
                AppAnimations.slideIn(
                  delay: 0.4,
                  child: _buildMenuCard(),
                ),
                
                const SizedBox(height: 32),
                
                // 登出按钮
                AppAnimations.fadeIn(
                  delay: 0.5,
                  child: _buildLogoutButton(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Row(
      children: [
        AppWidget.glowIcon(
          icon: Icons.account_circle,
          size: 32,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Text(
          '个人中心',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            shadows: [
              Shadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserCard(user, userProfile) {
    return AppWidget.glassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 头像
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: user?.avatarUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      user!.avatarUrl!,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.person, size: 50, color: Colors.white),
                    ),
                  )
                : const Icon(Icons.person, size: 50, color: Colors.white),
          ),
          
          const SizedBox(height: 20),
          
          // 用户昵称
          Text(
            user?.nickname ?? '未登录用户',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 用户信息
          if (user != null) ...[
            _buildInfoRow(Icons.badge, '学号', user.studentNumber),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.email, '邮箱', user.email),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.school, '专业', user.major),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.calendar_today, '年级', '${user.grade}级'),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(userProfile) {
    if (userProfile == null) return const SizedBox();
    
    return AppWidget.glassCard(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(Icons.star, '等级', '${userProfile.level}'),
          _buildVerticalDivider(),
          _buildStatItem(Icons.score, '积分', '${userProfile.totalPoints}'),
          _buildVerticalDivider(),
          _buildStatItem(Icons.article, '帖子', '${userProfile.postsCount}'),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 40,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppTheme.primaryColor.withOpacity(0.3),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard() {
    return AppWidget.glassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: '查看个人资料',
            subtitle: '查看完整的个人信息',
            onTap: () => context.push(AppRoutes.profileDetail),
          ),
          AppWidget.neonDivider(margin: const EdgeInsets.symmetric(vertical: 8)),
          _buildMenuItem(
            icon: Icons.edit_outlined,
            title: '编辑资料',
            subtitle: '修改个人信息和头像',
            onTap: () => context.push(AppRoutes.editProfile),
          ),
          AppWidget.neonDivider(margin: const EdgeInsets.symmetric(vertical: 8)),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            title: '设置',
            subtitle: '应用设置和偏好',
            onTap: () => Helpers.showToast(context, '功能开发中'),
          ),
          AppWidget.neonDivider(margin: const EdgeInsets.symmetric(vertical: 8)),
          _buildMenuItem(
            icon: Icons.help_outline,
            title: '帮助与反馈',
            subtitle: '获取帮助或提供反馈',
            onTap: () => Helpers.showToast(context, '功能开发中'),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppTheme.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return AppWidget.gradientButton(
      text: '安全登出',
      onPressed: _handleLogout,
      height: 52,
    );
  }
}