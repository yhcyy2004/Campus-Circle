import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

void main() async {
  print('创建测试用户数据...');
  
  // 测试用户数据
  final testUsers = [
    {
      'student_number': '202001000001',
      'email': 'test1@zzuli.edu.cn',
      'password': hashPassword('password123'),
      'nickname': '测试用户1',
      'real_name': '张三',
      'major': '计算机科学与技术',
      'grade': 2020,
    },
    {
      'student_number': '202001000002', 
      'email': 'test2@zzuli.edu.cn',
      'password': hashPassword('password123'),
      'nickname': '测试用户2',
      'real_name': '李四',
      'major': '软件工程',
      'grade': 2020,
    },
    {
      'student_number': '202001000003',
      'email': 'test3@zzuli.edu.cn',
      'password': hashPassword('password123'),
      'nickname': '测试用户3',
      'real_name': '王五',
      'major': '网络工程',
      'grade': 2021,
    },
  ];
  
  print('测试用户数据生成完成：');
  for (final user in testUsers) {
    print('学号: ${user['student_number']}, 邮箱: ${user['email']}, 昵称: ${user['nickname']}');
  }
  
  print('\n注意：这些测试数据需要通过API端点创建到数据库中');
  print('可以使用 POST /api/v1/auth/register 端点创建用户');
}