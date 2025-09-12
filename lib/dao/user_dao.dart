import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../dao/database_connection.dart';
import '../models/user_model.dart';

class UserDao {
  static final DatabaseConnection _db = DatabaseConnection();

  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  static Future<bool> isStudentNumberExists(String studentNumber) async {
    try {
      final result = await _db.query('/users/check-student-number', params: {
        'student_number': studentNumber,
      });
      return result['exists'] == true;
    } catch (e) {
      print('检查学号是否存在时发生错误: $e');
      return false;
    }
  }

  static Future<bool> isEmailExists(String email) async {
    try {
      final result = await _db.query('/users/check-email', params: {
        'email': email,
      });
      return result['exists'] == true;
    } catch (e) {
      print('检查邮箱是否存在时发生错误: $e');
      return false;
    }
  }

  static Future<User?> registerUser({
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
      if (await isStudentNumberExists(studentNumber)) {
        print('学号已存在: $studentNumber');
        return null;
      }

      if (await isEmailExists(email)) {
        print('邮箱已存在: $email');
        return null;
      }

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
        return User.fromJson(userData);
      } else {
        print('注册失败: ${result['message']}');
        return null;
      }
    } catch (e) {
      print('注册用户时发生错误: $e');
      return null;
    }
  }

  static Future<LoginResponse?> loginUser(String account, String password) async {
    try {
      final hashedPassword = _hashPassword(password);

      final result = await _db.execute('/auth/login', data: {
        'account': account,
        'password': hashedPassword,
      });

      // 新增：先判断result是否为有效Map
      if (result == null || result is! Map<String, dynamic>) {
        print('登录响应格式错误: 非Map类型');
        return null;
      }

      if (result['success'] == true) {
        // 安全处理：使用as?进行类型转换，避免强制转换失败
        final loginData = result['data'] as Map<String, dynamic>?;
        if (loginData != null) {
          return LoginResponse.fromJson(loginData);
        } else {
          print('登录失败: 服务器返回数据为空');
          return null;
        }
      } else {
        print('登录失败: ${result['message'] ?? "账号或密码错误"}');
        return null;
      }
    } catch (e) {
      print('登录时发生错误: $e');
      return null;
    }
  }

  static Future<User?> getUserById(String userId) async {
    try {
      final result = await _db.query('/users/$userId');

      if (result['success'] == true && result['data'] != null) {
        final userData = result['data'] as Map<String, dynamic>;
        return User.fromJson(userData);
      } else {
        return null;
      }
    } catch (e) {
      print('获取用户信息时发生错误: $e');
      return null;
    }
  }

  static Future<bool> updateUserProfile({
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
      print('更新用户资料时发生错误: $e');
      return false;
    }
  }
}