import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? _userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  void _loadUserInfo() {
    final userInfo = StorageService.getJson(AppConstants.keyUserInfo);
    if (userInfo != null && userInfo['user'] != null) {
      final user = userInfo['user'];
      setState(() {
        _userInfo = '欢迎回来，${user['nickname']}！';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('首页'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.home,
              size: 80,
              color: AppConstants.primaryColor,
            ),
            const SizedBox(height: 20),
            Text(
              _userInfo ?? '校园圈首页',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '连接校园生活的社交平台',
              style: TextStyle(
                fontSize: 16,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Text(
                '🎉 恭喜！你已成功实现了前端-HTTP API-数据库的完整架构！\n\n'
                '✅ 数据流程：浏览器本地存储 → HTTP请求 → Node.js后端 → MySQL数据库\n'
                '✅ 用户认证：JWT Token + 本地存储\n'
                '✅ 跨平台兼容：移除了mysql1依赖，支持Flutter Web',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppConstants.textPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}