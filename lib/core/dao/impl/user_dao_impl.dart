import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../dao/database_connection.dart';
import '../user_dao.dart';
import '../../models/result.dart';
import '../../../models/user_model.dart';

class UserDaoImpl implements UserDao {
  final DatabaseConnection _db = DatabaseConnection();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<ApiResult<User>> createUser({
    required String studentNumber,
    required String email,
    required String password,
    required String nickname,
    required String realName,
    required String major,
    required int grade,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);
      
      // 检查学号和邮箱是否已存在
      final studentExists = await checkStudentNumberExists(studentNumber);
      if (studentExists) {
        return ApiResult.failure('学号已存在');
      }
      
      final emailExists = await checkEmailExists(email);
      if (emailExists) {
        return ApiResult.failure('邮箱已存在');
      }
      
      // 通过API创建用户
      final result = await _db.execute('/users', data: {
        'student_number': studentNumber,
        'email': email,
        'password': hashedPassword,
        'nickname': nickname,
        'real_name': realName,
        'major': major,
        'grade': grade,
        'status': 1,
      });
      
      if (result['success'] == true) {
        final userData = result['data'] as Map<String, dynamic>;
        final user = User.fromJson(userData);
        return ApiResult.success(user);
      } else {
        return ApiResult.failure(result['message'] ?? '创建用户失败');
      }
    } catch (e) {
      print('创建用户失败: $e');
      return ApiResult.failure('创建用户失败: $e');
    }
  }

  @override
  Future<bool> checkStudentNumberExists(String studentNumber) async {
    try {
      final result = await _db.query('/users/check-student-number', params: {
        'student_number': studentNumber,
      });
      return result['exists'] == true;
    } catch (e) {
      print('检查学号存在性失败: $e');
      return false;
    }
  }

  @override
  Future<bool> checkEmailExists(String email) async {
    try {
      final result = await _db.query('/users/check-email', params: {
        'email': email,
      });
      return result['exists'] == true;
    } catch (e) {
      print('检查邮箱存在性失败: $e');
      return false;
    }
  }

  @override
  Future<ApiResult<LoginResponse>> login({
    required String account,
    required String password,
  }) async {
    try {
      final hashedPassword = _hashPassword(password);
      
      final result = await _db.execute('/auth/login', data: {
        'account': account,
        'password': hashedPassword,
      });
      
      if (result['success'] == true && result['data'] != null) {
        final loginData = result['data'] as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(loginData);
        return ApiResult.success(loginResponse);
      } else {
        return ApiResult.failure(result['message'] ?? '登录失败');
      }
    } catch (e) {
      print('登录失败: $e');
      return ApiResult.failure('登录失败: $e');
    }
  }

  @override
  Future<User?> getUserById(String userId) async {
    try {
      final result = await _db.query('/users/$userId');
      
      if (result['success'] == true && result['data'] != null) {
        final userData = result['data'] as Map<String, dynamic>;
        return User.fromJson(userData);
      } else {
        return null;
      }
    } catch (e) {
      print('获取用户失败: $e');
      return null;
    }
  }

  @override
  Future<bool> updateUserProfile({
    required String userId,
    String? nickname,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      final result = await _db.update('/users/$userId/profile', data: {
        if (nickname != null) 'nickname': nickname,
        if (bio != null) 'bio': bio,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
      });
      
      return result['success'] == true;
    } catch (e) {
      print('更新用户资料失败: $e');
      return false;
    }
  }
}