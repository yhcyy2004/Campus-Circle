import 'dart:io';
import 'package:dio/dio.dart';

void main() async {
  // 测试服务器连接
  await testServerConnection();
}

Future<void> testServerConnection() async {
  final dio = Dio();
  final serverUrl = 'http://43.138.4.157:8080/api/v1';
  
  print('🔍 测试服务器连接...');
  print('服务器地址: $serverUrl');
  print('=' * 50);
  
  // 1. 测试健康检查
  try {
    print('1️⃣ 测试健康检查接口...');
    final response = await dio.get('$serverUrl/health');
    print('✅ 健康检查成功: ${response.statusCode}');
    print('响应数据: ${response.data}');
  } catch (e) {
    print('❌ 健康检查失败: $e');
  }
  
  print('-' * 30);
  
  // 2. 测试登录接口
  try {
    print('2️⃣ 测试登录接口...');
    final response = await dio.post(
      '$serverUrl/auth/login',
      data: {
        'account': '542312320411',
        'password': '542312320411',
      },
    );
    print('✅ 登录测试成功: ${response.statusCode}');
    print('响应数据: ${response.data}');
  } catch (e) {
    print('❌ 登录测试失败: $e');
    if (e is DioException && e.response != null) {
      print('错误详情: ${e.response?.data}');
    }
  }
  
  print('-' * 30);
  
  // 3. 测试注册接口
  try {
    print('3️⃣ 测试注册接口可达性...');
    final response = await dio.post(
      '$serverUrl/auth/register',
      data: {
        'student_number': '000000000000',  // 无效数据，只测试连通性
        'email': 'test@zzuli.edu.cn',
        'password': 'test123',
        'nickname': '测试用户',
        'real_name': '测试',
        'major': '测试专业',
        'grade': 2023,
      },
    );
    print('✅ 注册接口可达: ${response.statusCode}');
  } catch (e) {
    if (e is DioException && e.response != null) {
      print('✅ 注册接口可达，返回错误响应: ${e.response?.statusCode}');
      print('错误信息: ${e.response?.data}');
    } else {
      print('❌ 注册接口不可达: $e');
    }
  }
  
  print('=' * 50);
  print('测试完成！');
}