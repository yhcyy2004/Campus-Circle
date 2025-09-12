import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../config/app_routes.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/helpers.dart';

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
      backgroundColor: AppConstants.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              
              // Logo和标题
              _buildHeader(),
              
              const SizedBox(height: 60),
              
              // 登录表单
              _buildLoginForm(),
              
              const SizedBox(height: 24),
              
              // 登录按钮
              _buildLoginButton(),
              
              const SizedBox(height: 16),
              
              // 注册链接
              _buildRegisterLink(),
              
              const SizedBox(height: 40),
              
              // 其他登录方式
              _buildOtherLogin(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppConstants.primaryColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppConstants.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.school,
            size: 40,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '欢迎回来',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppConstants.textPrimaryColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '登录你的校园圈账号',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppConstants.textSecondaryColor,
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
          TextFormField(
            controller: _accountController,
            decoration: const InputDecoration(
              labelText: '学号或邮箱',
              hintText: '请输入学号或zzuli.edu.cn邮箱',
              prefixIcon: Icon(Icons.person_outline),
            ),
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
          TextFormField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: '密码',
              hintText: '请输入密码',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            validator: Validators.validatePassword,
            onFieldSubmitted: (_) => _handleLogin(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              '登录',
              style: TextStyle(
                fontSize: AppConstants.fontSizeLarge,
                fontWeight: FontWeight.w600,
              ),
            ),
    );
  }

  Widget _buildRegisterLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '还没有账号？',
          style: TextStyle(
            color: AppConstants.textSecondaryColor,
            fontSize: AppConstants.fontSizeMedium,
          ),
        ),
        TextButton(
          onPressed: () => context.go(AppRoutes.register),
          child: const Text(
            '立即注册',
            style: TextStyle(
              color: AppConstants.primaryColor,
              fontSize: AppConstants.fontSizeMedium,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOtherLogin() {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '或者',
                style: TextStyle(
                  color: AppConstants.textSecondaryColor,
                  fontSize: AppConstants.fontSizeSmall,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        
        const SizedBox(height: 20),
        
        TextButton(
          onPressed: () {
            // TODO: 实现忘记密码功能
            Helpers.showToast(context, '功能开发中');
          },
          child: const Text(
            '忘记密码？',
            style: TextStyle(
              color: AppConstants.primaryColor,
              fontSize: AppConstants.fontSizeMedium,
            ),
          ),
        ),
      ],
    );
  }
}