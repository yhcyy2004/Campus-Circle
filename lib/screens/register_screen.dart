import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/user_api_service.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 表单控制器
  final _nicknameController = TextEditingController();
  final _realNameController = TextEditingController();
  final _studentNumberController = TextEditingController();
  final _majorController = TextEditingController();
  final _gradeController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  // API服务实例
  final UserApiService _userApiService = UserApiService();

  // 年级选项
  final List<int> _gradeOptions = [
    DateTime.now().year,
    DateTime.now().year - 1,
    DateTime.now().year - 2,
    DateTime.now().year - 3,
    DateTime.now().year - 4,
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _realNameController.dispose();
    _studentNumberController.dispose();
    _majorController.dispose();
    _gradeController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 注册方法
  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _showError('请先同意用户协议和隐私政策');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 使用UserApiService进行注册（会先保存到本地存储，再发送到服务器）
      final result = await _userApiService.register(
        studentNumber: _studentNumberController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        nickname: _nicknameController.text.trim(),
        realName: _realNameController.text.trim(),
        major: _majorController.text.trim(),
        grade: int.parse(_gradeController.text.trim()),
      );

      if (result.isSuccess) {
        final user = result.data!;
        
        // 注册成功，保存用户ID
        await StorageService.setString(AppConstants.keyUserId, user.id);
        await StorageService.setJson(AppConstants.keyUserInfo, {
          'user': user.toJson(),
          'profile': null, // 新注册用户暂无详细profile
        });

        _showSuccess('注册成功！欢迎加入校园圈，${user.nickname}！');
        
        // 延迟跳转到登录页面（让用户重新登录获取token）
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go('/login');
        }
      } else {
        _showError(result.error ?? '注册失败，请稍后重试');
      }
    } catch (e) {
      print('注册异常: $e');
      _showError('网络异常，请稍后重试');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          '注册账号',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 头部说明
                    const Text(
                      '创建您的校园圈账号',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '请填写真实信息，以便审核通过',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // 昵称输入框
                    TextFormField(
                      controller: _nicknameController,
                      decoration: InputDecoration(
                        labelText: '昵称',
                        hintText: '请输入昵称',
                        prefixIcon: const Icon(Icons.person_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入昵称';
                        }
                        if (value.length < 2 || value.length > 20) {
                          return '昵称长度为2-20个字符';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // 真实姓名输入框
                    TextFormField(
                      controller: _realNameController,
                      decoration: InputDecoration(
                        labelText: '真实姓名',
                        hintText: '请输入真实姓名',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入真实姓名';
                        }
                        if (value.length < 2 || value.length > 10) {
                          return '姓名长度为2-10个字符';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // 学号输入框
                    TextFormField(
                      controller: _studentNumberController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '学号',
                        hintText: '请输入学号',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入学号';
                        }
                        if (value.length < 8) {
                          return '请输入有效的学号';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // 专业输入框
                    TextFormField(
                      controller: _majorController,
                      decoration: InputDecoration(
                        labelText: '专业',
                        hintText: '请输入专业名称',
                        prefixIcon: const Icon(Icons.school_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入专业';
                        }
                        if (value.length < 2) {
                          return '请输入有效的专业名称';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // 年级输入框
                    TextFormField(
                      controller: _gradeController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: '年级',
                        hintText: '请输入年级（如：2023）',
                        prefixIcon: const Icon(Icons.calendar_today_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入年级';
                        }
                        final year = int.tryParse(value);
                        if (year == null || year < 2020 || year > 2030) {
                          return '请输入有效的年级（2020-2030）';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // 邮箱输入框
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: '校园邮箱',
                        hintText: '请输入校园邮箱',
                        prefixIcon: const Icon(Icons.email_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入邮箱';
                        }
                        if (!value.contains('@') || !value.contains('zzuli.edu.cn')) {
                          return '请输入有效的校园邮箱';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // 密码输入框
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: '密码',
                        hintText: '请输入密码（至少6位）',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请输入密码';
                        }
                        if (value.length < 6) {
                          return '密码至少6位';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    // 确认密码输入框
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        labelText: '确认密码',
                        hintText: '请再次输入密码',
                        prefixIcon: const Icon(Icons.lock_outlined),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '请确认密码';
                        }
                        if (value != _passwordController.text) {
                          return '两次密码输入不一致';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 30),

                    // 协议勾选
                    Row(
                      children: [
                        Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() => _agreeToTerms = value ?? false);
                          },
                        ),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                              children: [
                                const TextSpan(text: '我已阅读并同意'),
                                TextSpan(
                                  text: '《用户协议》',
                                  style: TextStyle(
                                    color: AppConstants.primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const TextSpan(text: '和'),
                                TextSpan(
                                  text: '《隐私政策》',
                                  style: TextStyle(
                                    color: AppConstants.primaryColor,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 30),

                    // 注册按钮
                    ElevatedButton(
                      onPressed: _isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              '注册',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),

                    const SizedBox(height: 20),

                    // 登录链接
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          '已有账号？',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black54,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.pop();
                          },
                          child: Text(
                            '立即登录',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppConstants.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}