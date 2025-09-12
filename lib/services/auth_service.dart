import '../services/storage_service.dart';
import '../services/user_api_service.dart';
import '../utils/constants.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final UserApiService _userApiService = UserApiService();

  // 当前用户信息缓存
  User? _currentUser;
  UserProfile? _currentUserProfile;
  String? _currentToken;

  // 检查是否已登录
  bool get isLoggedIn {
    _currentToken ??= StorageService.getString(AppConstants.keyToken);
    return _currentToken != null && _currentToken!.isNotEmpty;
  }

  // 获取当前用户
  User? get currentUser => _currentUser;
  UserProfile? get currentUserProfile => _currentUserProfile;
  String? get currentToken => _currentToken;

  // 初始化认证状态（应用启动时调用）
  Future<void> initialize() async {
    try {
      _currentToken = StorageService.getString(AppConstants.keyToken);
      
      if (_currentToken != null && _currentToken!.isNotEmpty) {
        // 从本地存储恢复用户信息
        final userInfo = StorageService.getJson(AppConstants.keyUserInfo);
        if (userInfo != null && userInfo is Map<String, dynamic>) {
          try {
            // 安全地解析用户数据
            final userField = userInfo['user'];
            final profileField = userInfo['profile'];
            
            if (userField != null && userField is Map<String, dynamic>) {
              _currentUser = User.fromJson(userField);
            }
            
            if (profileField != null && profileField is Map<String, dynamic>) {
              _currentUserProfile = UserProfile.fromJson(profileField);
            }
            
            if (_currentUser != null) {
              print('用户认证状态已恢复: ${_currentUser?.nickname}');
            } else {
              throw Exception('用户数据解析失败');
            }
          } catch (parseError) {
            print('解析本地用户数据失败: $parseError');
            await logout();
          }
        } else {
          // 本地存储中没有用户信息，清除token
          print('本地存储中没有用户信息，清除认证状态');
          await logout();
        }
      }
    } catch (e) {
      print('初始化认证状态失败: $e');
      await logout();
    }
  }

  // 用户登录
  Future<AuthResult> login({
    required String account,
    required String password,
  }) async {
    try {
      print('开始登录: $account');
      
      final result = await _userApiService.login(
        account: account,
        password: password,
      );

      if (result.isSuccess && result.data != null) {
        final loginResponse = result.data!;
        
        // 更新内存中的用户信息
        _currentUser = loginResponse.user;
        _currentUserProfile = loginResponse.userProfile;
        _currentToken = loginResponse.token;
        
        print('登录成功: ${_currentUser?.nickname}');
        return AuthResult.success('登录成功');
      } else {
        print('登录失败: ${result.error}');
        return AuthResult.failure(result.error ?? '登录失败');
      }
    } catch (e) {
      print('登录过程中发生错误: $e');
      return AuthResult.failure('登录失败，请稍后重试');
    }
  }

  // 用户注册
  Future<AuthResult> register({
    required String studentNumber,
    required String email,
    required String password,
    required String nickname,
    required String realName,
    required String major,
    required int grade,
  }) async {
    try {
      print('开始注册: $studentNumber');
      
      final result = await _userApiService.register(
        studentNumber: studentNumber,
        email: email,
        password: password,
        nickname: nickname,
        realName: realName,
        major: major,
        grade: grade,
      );

      if (result.isSuccess) {
        print('注册成功: $nickname');
        return AuthResult.success('注册成功，请登录');
      } else {
        print('注册失败: ${result.error}');
        return AuthResult.failure(result.error ?? '注册失败');
      }
    } catch (e) {
      print('注册过程中发生错误: $e');
      return AuthResult.failure('注册失败，请稍后重试');
    }
  }

  // 更新用户资料
  Future<AuthResult> updateProfile({
    String? nickname,
    String? phone,
    String? bio,
    String? location,
    List<String>? interests,
    Map<String, String>? socialLinks,
  }) async {
    try {
      print('开始更新用户资料');
      
      final result = await _userApiService.updateProfile(
        nickname: nickname,
        phone: phone,
        bio: bio,
        location: location,
        interests: interests,
        socialLinks: socialLinks,
      );

      if (result.isSuccess && result.data != null) {
        final updateResponse = result.data!;
        
        // 更新内存中的用户信息
        _currentUser = updateResponse.user;
        _currentUserProfile = updateResponse.userProfile;
        _currentToken = updateResponse.token;
        
        print('用户资料更新成功: ${_currentUser?.nickname}');
        return AuthResult.success('资料更新成功');
      } else {
        print('用户资料更新失败: ${result.error}');
        return AuthResult.failure(result.error ?? '更新失败');
      }
    } catch (e) {
      print('更新用户资料时发生错误: $e');
      return AuthResult.failure('更新失败，请稍后重试');
    }
  }

  // 用户登出
  Future<void> logout() async {
    try {
      print('用户登出: ${_currentUser?.nickname}');
      
      // 调用API登出
      await _userApiService.logout();
      
      // 清除内存中的用户信息
      _currentUser = null;
      _currentUserProfile = null;
      _currentToken = null;
      
      print('登出完成');
    } catch (e) {
      print('登出时发生错误: $e');
      // 即使API调用失败，也要清除本地数据
      _currentUser = null;
      _currentUserProfile = null;
      _currentToken = null;
    }
  }

  // 刷新用户信息
  Future<bool> refreshUserInfo() async {
    if (!isLoggedIn || _currentUser == null) {
      return false;
    }

    try {
      // 这里可以调用API获取最新的用户信息
      // 暂时返回true表示成功
      return true;
    } catch (e) {
      print('刷新用户信息失败: $e');
      return false;
    }
  }

  // 检查token是否有效
  Future<bool> validateToken() async {
    if (!isLoggedIn) {
      return false;
    }

    try {
      // 这里可以调用API验证token
      // 如果token无效，应该清除本地存储并返回false
      return true;
    } catch (e) {
      print('验证token失败: $e');
      await logout();
      return false;
    }
  }
}

// 认证结果
class AuthResult {
  final bool isSuccess;
  final String message;

  AuthResult._(this.isSuccess, this.message);

  factory AuthResult.success(String message) => AuthResult._(true, message);
  factory AuthResult.failure(String message) => AuthResult._(false, message);
}