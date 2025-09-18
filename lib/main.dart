import 'package:flutter/material.dart';
import 'config/app_routes.dart';
import 'services/storage_service.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'utils/constants.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化服务
  await StorageService.init();
  ApiService().init();
  
  // 初始化认证服务
  await AuthService().initialize();
  
  runApp(const CampusCircleApp());
}

class CampusCircleApp extends StatelessWidget {
  const CampusCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppConstants.appName,
      theme: AppTheme.getTheme(),
      routerConfig: AppRoutes.router,
      debugShowCheckedModeBanner: false,
    );
  }
}