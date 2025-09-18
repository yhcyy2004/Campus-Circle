import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../config/app_routes.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/helpers.dart';
import '../theme/app_theme.dart';
import '../widgets/app_widgets.dart';
import '../animations/app_animations.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _accountController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // 认证服务实例
  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _accountController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.login(
        account: _accountController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        if (result.isSuccess) {
          Helpers.showToast(context, result.message, isError: false);
          
          // 等待一小段时间让用户看到成功消息
          await Future.delayed(const Duration(milliseconds: 500));
          
          // 跳转到主页
          if (mounted) {
            context.go(AppRoutes.main);
          }
        } else {
          Helpers.showToast(context, result.message, isError: true);
        }
      }
    } catch (e) {
      if (mounted) {
        Helpers.showToast(context, '登录失败，请稍后重试', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppWidget.gradientBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo和标题
                AppAnimations.fadeIn(
                  delay: 0.2,
                  child: _buildHeader(),
                ),
                
                const SizedBox(height: 50),
                
                // 登录表单卡片
                AppAnimations.slideIn(
                  delay: 0.4,
                  child: AppWidget.glassCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        _buildLoginForm(),
                        const SizedBox(height: 24),
                        _buildLoginButton(),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // 注册链接
                AppAnimations.fadeIn(
                  delay: 0.6,
                  child: _buildRegisterLink(),
                ),
                
                const SizedBox(height: 32),
                
                // 其他登录方式
                AppAnimations.slideIn(
                  delay: 0.8,
                  begin: const Offset(0, 0.5),
                  child: _buildOtherLogin(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.5),
                blurRadius: 25,
                spreadRadius: 5,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: AppWidget.glowIcon(
            icon: Icons.rocket_launch,
            size: 50,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          '欢迎回到未来',
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            shadows: [
              Shadow(
                color: AppTheme.primaryColor.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '连接校园数字世界',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // 账号输入框
          AppWidget.neonTextField(
            controller: _accountController,
            label: '账号',
            hint: '学号或邮箱',
            prefixIcon: Icons.account_circle_outlined,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '请输入学号或邮箱';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 20),
          
          // 密码输入框
          AppWidget.neonTextField(
            controller: _passwordController,
            label: '密码',
            hint: '请输入密码',
            prefixIcon: Icons.lock_outline,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: Validators.validatePassword,
            onFieldSubmitted: (_) => _handleLogin(),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.textSecondary,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return AppWidget.gradientButton(
      text: '登录系统',
      onPressed: _handleLogin,
      isLoading: _isLoading,
      height: 52,
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.register),
          child: Text(
            '创建账号',
            style: TextStyle(
              color: AppTheme.primaryColor,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              shadows: [
                Shadow(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherLogin() {
    return Column(
      children: [
        AppWidget.neonDivider(
          margin: const EdgeInsets.symmetric(vertical: 20),
        ),
        
        TextButton(
          onPressed: () {
            // TODO: 实现忘记密码功能
            Helpers.showToast(context, '功能开发中');
          },
          child: Text(
            '忘记密码？',
            style: TextStyle(
              color: AppTheme.accentColor,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: AppTheme.accentColor.withOpacity(0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}