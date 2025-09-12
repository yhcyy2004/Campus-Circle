import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

/// 用户服务 - 使用AuthService的包装器，提供ChangeNotifier功能
/// 主要用于需要状态管理的场景
class UserService extends ChangeNotifier {
  final AuthService _authService = AuthService();

  // 获取当前用户信息
  User? get currentUser => _authService.currentUser;
  UserProfile? get userProfile => _authService.currentUserProfile;
  bool get isLoggedIn => _authService.isLoggedIn;
  String? get currentToken => _authService.currentToken;

  UserService() {
    // 监听认证状态变化，可以在这里添加逻辑
  }

  /// 用户登录
  Future<AuthResult> login(String account, String password) async {
    final result = await _authService.login(
      account: account,
      password: password,
    );
    
    // 通知监听者状态已更改
    notifyListeners();
    return result;
  }

  /// 用户注册
  Future<AuthResult> register({
    required String studentNumber,
    required String email,
    required String password,
    required String nickname,
    required String realName,
    required String major,
    required int grade,
  }) async {
    final result = await _authService.register(
      studentNumber: studentNumber,
      email: email,
      password: password,
      nickname: nickname,
      realName: realName,
      major: major,
      grade: grade,
    );
    
    // 通知监听者状态已更改
    notifyListeners();
    return result;
  }

  /// 用户登出
  Future<void> logout() async {
    await _authService.logout();
    
    // 通知监听者状态已更改
    notifyListeners();
  }

  /// 刷新用户信息
  Future<bool> refreshUserInfo() async {
    final result = await _authService.refreshUserInfo();
    
    if (result) {
      // 通知监听者状态已更改
      notifyListeners();
    }
    
    return result;
  }

  /// 验证token
  Future<bool> validateToken() async {
    final result = await _authService.validateToken();
    
    if (!result) {
      // 如果token无效，通知监听者状态已更改
      notifyListeners();
    }
    
    return result;
  }

  /// 获取加入天数
  int getDaysJoined() {
    if (currentUser == null) return 0;
    final now = DateTime.now();
    return now.difference(currentUser!.createdAt).inDays;
  }

  /// 获取用户等级文本
  String getUserLevelText() {
    if (userProfile == null) return '新手';
    
    final level = userProfile!.level;
    const levelMap = {
      1: '青铜',
      2: '白银', 
      3: '黄金',
      4: '铂金',
      5: '钻石',
    };
    
    return levelMap[level] ?? '未知等级';
  }

  /// 获取用户积分等级进度
  double getLevelProgress() {
    if (userProfile == null) return 0.0;
    
    final points = userProfile!.totalPoints;
    final level = userProfile!.level;
    
    // 简单的积分等级计算
    final currentLevelPoints = (level - 1) * 100;
    final nextLevelPoints = level * 100;
    
    if (points >= nextLevelPoints) return 1.0;
    if (points <= currentLevelPoints) return 0.0;
    
    return (points - currentLevelPoints) / (nextLevelPoints - currentLevelPoints);
  }
}