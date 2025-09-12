import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';
import '../screens/main_screen.dart';
import '../screens/edit_profile_screen.dart';
import '../screens/profile_detail_screen.dart';
import '../pages/profile_page.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String main = '/main';
  static const String profile = '/profile';
  static const String editProfile = '/edit-profile';
  static const String profileDetail = '/profile-detail';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [
      // 启动页
      GoRoute(
        path: splash,
        builder: (context, state) => const SplashScreen(),
      ),
      
      // 登录页
      GoRoute(
        path: login,
        builder: (context, state) => const LoginScreen(),
      ),
      
      // 注册页
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      
      // 主页面
      GoRoute(
        path: main,
        builder: (context, state) => const MainScreen(),
      ),
      
      // 个人资料页
      GoRoute(
        path: profile,
        builder: (context, state) => const ProfilePage(),
      ),
      
      // 编辑资料页
      GoRoute(
        path: editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      
      // 个人资料详情页
      GoRoute(
        path: profileDetail,
        builder: (context, state) => const ProfileDetailScreen(),
      ),
    ],
    
    // 改进的路由守卫
    redirect: (context, state) {
      final authService = AuthService();
      final isLoggedIn = authService.isLoggedIn;
      
      final isGoingToLogin = state.matchedLocation == login;
      final isGoingToRegister = state.matchedLocation == register;
      final isGoingToSplash = state.matchedLocation == splash;

      print('路由守卫: 当前路径=${state.matchedLocation}, 已登录=$isLoggedIn');

      // 如果未登录且不是去登录/注册/启动页面，重定向到登录页
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister && !isGoingToSplash) {
        print('重定向到登录页: 用户未登录');
        return login;
      }
      
      // 如果已登录且在登录/注册页面，重定向到主页
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        print('重定向到主页: 用户已登录');
        return main;
      }
      
      // 如果在启动页且已登录，重定向到主页
      if (isLoggedIn && isGoingToSplash) {
        print('重定向到主页: 启动页跳转');
        return main;
      }
      
      // 如果在启动页且未登录，重定向到登录页
      if (!isLoggedIn && isGoingToSplash) {
        print('重定向到登录页: 启动页跳转');
        return login;
      }
      
      return null;
    },
    
    // 错误页面
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              '页面未找到',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.error?.toString() ?? '未知错误',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(main),
              child: const Text('返回首页'),
            ),
          ],
        ),
      ),
    ),
  );
}