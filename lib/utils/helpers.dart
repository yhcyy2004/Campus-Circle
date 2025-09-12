import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Helpers {
  // 格式化时间
  static String formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return '刚刚';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}分钟前';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}小时前';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}天前';
    } else {
      return DateFormat('MM-dd').format(dateTime);
    }
  }
  
  // 格式化日期
  static String formatDate(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }
  
  // 格式化日期时间
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }
  
  // 格式化文件大小
  static String formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}GB';
    }
  }
  
  // 获取用户等级名称
  static String getUserLevelName(int level) {
    const levels = {
      1: '青铜',
      2: '白银', 
      3: '黄金',
      4: '铂金',
      5: '钻石',
    };
    return levels[level] ?? '青铜';
  }
  
  // 获取用户等级颜色
  static Color getUserLevelColor(int level) {
    switch (level) {
      case 1:
        return const Color(0xFFCD7F32); // 青铜
      case 2:
        return const Color(0xFFC0C0C0); // 白银
      case 3:
        return const Color(0xFFFFD700); // 黄金
      case 4:
        return const Color(0xFFE5E4E2); // 铂金
      case 5:
        return const Color(0xFFB9F2FF); // 钻石
      default:
        return const Color(0xFFCD7F32); // 默认青铜
    }
  }
  
  // 显示Toast
  static void showToast(BuildContext context, String message, {bool isError = false}) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : null,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  // 显示确认对话框
  static Future<bool?> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = '确定',
    String cancelText = '取消',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(cancelText),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }
  
  // 显示加载对话框
  static void showLoadingDialog(BuildContext context, {String message = '加载中...'}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 16),
            Text(message),
          ],
        ),
      ),
    );
  }
  
  // 隐藏加载对话框
  static void hideLoadingDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
  
  // 生成随机ID
  static String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        (DateTime.now().microsecond % 1000).toString().padLeft(3, '0');
  }
  
  // 获取文件扩展名
  static String getFileExtension(String fileName) {
    final lastDotIndex = fileName.lastIndexOf('.');
    if (lastDotIndex == -1) return '';
    return fileName.substring(lastDotIndex + 1).toLowerCase();
  }
  
  // 检查是否为图片文件
  static bool isImageFile(String fileName) {
    const imageExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'];
    final extension = getFileExtension(fileName);
    return imageExtensions.contains(extension);
  }
  
  // 脱敏处理手机号
  static String maskPhone(String phone) {
    if (phone.length != 11) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(7)}';
  }
  
  // 脱敏处理邮箱
  static String maskEmail(String email) {
    final atIndex = email.indexOf('@');
    if (atIndex == -1) return email;
    final localPart = email.substring(0, atIndex);
    final domainPart = email.substring(atIndex);
    
    if (localPart.length <= 2) {
      return email;
    }
    
    final maskedLocal = localPart.substring(0, 2) + 
        '*' * (localPart.length - 2);
    return maskedLocal + domainPart;
  }
}