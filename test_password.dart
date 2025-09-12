import 'package:crypto/crypto.dart';
import 'dart:convert';

String hashPassword(String password) {
  final bytes = utf8.encode(password);
  final digest = sha256.convert(bytes);
  return digest.toString();
}

Future<void> main() async {
  print('测试密码加密功能...');
  
  // 测试密码
  final testPassword = 'password123';
  final hashedPassword = hashPassword(testPassword);
  
  print('原始密码: $testPassword');
  print('加密后密码: $hashedPassword');
  
  // 验证密码一致性
  final hashedPassword2 = hashPassword(testPassword);
  print('二次加密: $hashedPassword2');
  print('加密一致性: ${hashedPassword == hashedPassword2}');
  
  // 测试不同密码
  final differentPassword = 'password456';
  final hashedDifferent = hashPassword(differentPassword);
  print('不同密码: $differentPassword -> $hashedDifferent');
  print('不同密码测试: ${hashedPassword != hashedDifferent}');
}