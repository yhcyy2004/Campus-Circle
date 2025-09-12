import 'package:flutter/material.dart';

class AppConstants {
  // App信息
  static const String appName = '校园圈';
  static const String appVersion = '1.0.0';
  
  // 颜色配置
  static const Color primaryColor = Color(0xFF007AFF);
  static const Color secondaryColor = Color(0xFF34C759);
  static const Color errorColor = Color(0xFFFF3B30);
  static const Color warningColor = Color(0xFFFF9500);
  
  // 文字颜色
  static const Color textPrimaryColor = Color(0xFF000000);
  static const Color textSecondaryColor = Color(0xFF8E8E93);
  static const Color textDisabledColor = Color(0xFFC7C7CC);
  
  // 背景颜色
  static const Color backgroundColor = Color(0xFFF2F2F7);
  static const Color cardColor = Color(0xFFFFFFFF);
  
  // 间距
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  // 圆角
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  
  // 字体大小
  static const double fontSizeSmall = 12.0;
  static const double fontSizeMedium = 14.0;
  static const double fontSizeLarge = 16.0;
  static const double fontSizeXLarge = 18.0;
  static const double fontSizeXXLarge = 20.0;
  
  // API配置
  static const String baseUrl = 'http://43.138.4.157:8080/api/v1';
  static const Duration requestTimeout = Duration(seconds: 30);
  
  // 存储键名
  static const String keyToken = 'token';
  static const String keyUserId = 'user_id';
  static const String keyUserInfo = 'user_info';
  static const String keyIsFirstLaunch = 'is_first_launch';
  static const String keyRegistrationDraft = 'registration_draft';
  
  // 用户等级配置
  static const Map<int, String> userLevels = {
    1: '青铜',
    2: '白银',
    3: '黄金',
    4: '铂金',
    5: '钻石',
  };
  
  // 正则表达式
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@zzuli\.edu\.cn$';
  static const String studentNumberRegex = r'^\d{12}$';
  static const String phoneRegex = r'^1[3-9]\d{9}$';
  
  // 文件上传限制
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
  
  // 分页配置
  static const int defaultPageSize = 20;
  
  // 缓存配置
  static const Duration cacheExpiration = Duration(minutes: 30);
}