import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// 认证管理器 - 单例模式
class AuthManager {
  static AuthManager? _instance;
  static AuthManager get instance => _instance ??= AuthManager._internal();

  AuthManager._internal();

  // 存储键名
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _userProfileKey = 'user_profile_data';

  String? _token;
  User? _currentUser;
  UserProfile? _currentUserProfile;

  /// 获取当前用户token
  String? get token => _token;

  /// 获取当前用户信息
  User? get currentUser => _currentUser;

  /// 获取当前用户资料
  UserProfile? get currentUserProfile => _currentUserProfile;

  /// 是否已登录
  bool get isLoggedIn => _token != null && _token!.isNotEmpty;

  /// 获取当前用户ID
  String? get userId => _currentUser?.id;

  /// 初始化认证管理器
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 读取token
      _token = prefs.getString(_tokenKey);

      // 读取用户信息
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        final userMap = json.decode(userJson);
        _currentUser = User.fromJson(userMap);
      }

      // 读取用户资料
      final profileJson = prefs.getString(_userProfileKey);
      if (profileJson != null) {
        final profileMap = json.decode(profileJson);
        _currentUserProfile = UserProfile.fromJson(profileMap);
      }
    } catch (e) {
      // 初始化失败时清空数据
      await clearAuth();
    }
  }

  /// 保存认证信息
  Future<void> saveAuth({
    required String token,
    required User user,
    UserProfile? userProfile,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _token = token;
      _currentUser = user;
      _currentUserProfile = userProfile;

      // 保存到本地存储
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userKey, json.encode(user.toJson()));

      if (userProfile != null) {
        await prefs.setString(_userProfileKey, json.encode(userProfile.toJson()));
      }
    } catch (e) {
      throw AuthException('保存认证信息失败: $e');
    }
  }

  /// 更新用户信息
  Future<void> updateUser(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _currentUser = user;
      await prefs.setString(_userKey, json.encode(user.toJson()));
    } catch (e) {
      throw AuthException('更新用户信息失败: $e');
    }
  }

  /// 更新用户资料
  Future<void> updateUserProfile(UserProfile userProfile) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _currentUserProfile = userProfile;
      await prefs.setString(_userProfileKey, json.encode(userProfile.toJson()));
    } catch (e) {
      throw AuthException('更新用户资料失败: $e');
    }
  }

  /// 更新token
  Future<void> updateToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _token = token;
      await prefs.setString(_tokenKey, token);
    } catch (e) {
      throw AuthException('更新token失败: $e');
    }
  }

  /// 清空认证信息
  Future<void> clearAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      _token = null;
      _currentUser = null;
      _currentUserProfile = null;

      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
      await prefs.remove(_userProfileKey);
    } catch (e) {
      throw AuthException('清空认证信息失败: $e');
    }
  }

  /// 检查token是否有效（可以添加过期检查逻辑）
  bool isTokenValid() {
    if (_token == null || _token!.isEmpty) {
      return false;
    }

    // 这里可以添加JWT token解析和过期检查
    // 目前简单检查token是否存在
    return true;
  }

  /// 获取认证头
  Map<String, String> getAuthHeaders() {
    if (!isLoggedIn) {
      return {};
    }

    return {
      'Authorization': 'Bearer $_token',
    };
  }

  /// 静态方法获取token（用于DAO层）
  static Future<String?> getToken() async {
    return instance.token;
  }

  /// 登出
  Future<void> logout() async {
    await clearAuth();
  }

  /// 检查是否需要重新登录
  bool needsReauth() {
    return !isLoggedIn || !isTokenValid();
  }
}

/// 认证异常类
class AuthException implements Exception {
  final String message;

  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}