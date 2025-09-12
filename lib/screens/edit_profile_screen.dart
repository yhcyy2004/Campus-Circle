import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  // 控制器
  final _nicknameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  final _locationController = TextEditingController();
  final _qqController = TextEditingController();
  final _wechatController = TextEditingController();
  final _weiboController = TextEditingController();

  // 兴趣标签
  List<String> _interests = [];
  final _interestController = TextEditingController();

  bool _isLoading = false;
  bool _saveSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _qqController.dispose();
    _wechatController.dispose();
    _weiboController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    final userProfile = _authService.currentUserProfile;

    if (user != null) {
      _nicknameController.text = user.nickname;
      _phoneController.text = user.phone ?? '';
    }

    if (userProfile != null) {
      _bioController.text = userProfile.bio ?? '';
      _locationController.text = userProfile.location ?? '';
      _interests = List<String>.from(userProfile.interests ?? []);
      
      final socialLinks = userProfile.socialLinks ?? {};
      _qqController.text = socialLinks['qq'] ?? '';
      _wechatController.text = socialLinks['wechat'] ?? '';
      _weiboController.text = socialLinks['weibo'] ?? '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 确保API服务已初始化
      final apiService = ApiService();
      apiService.init();
      
      final socialLinks = <String, String>{};
      if (_qqController.text.isNotEmpty) {
        socialLinks['qq'] = _qqController.text.trim();
      }
      if (_wechatController.text.isNotEmpty) {
        socialLinks['wechat'] = _wechatController.text.trim();
      }
      if (_weiboController.text.isNotEmpty) {
        socialLinks['weibo'] = _weiboController.text.trim();
      }

      print('开始保存个人资料...');
      print('昵称: ${_nicknameController.text.trim()}');
      print('手机: ${_phoneController.text.trim()}');
      print('简介: ${_bioController.text.trim()}');
      print('位置: ${_locationController.text.trim()}');
      print('兴趣: $_interests');
      print('社交链接: $socialLinks');

      // 调用AuthService更新用户资料
      final result = await _authService.updateProfile(
        nickname: _nicknameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        location: _locationController.text.trim().isEmpty ? null : _locationController.text.trim(),
        interests: _interests.isEmpty ? null : _interests,
        socialLinks: socialLinks.isEmpty ? null : socialLinks,
      );

      if (mounted) {
        if (result.isSuccess) {
          // 保存成功，先刷新页面数据显示更新后的内容
          _loadUserData();
          setState(() {
            _saveSuccess = true;
            // 触发页面重建以显示最新数据
          });
          
          Helpers.showToast(context, result.message, isError: false);
          
          // 延迟2秒后关闭页面，让用户看到更新后的数据
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              context.pop();
            }
          });
        } else {
          print('保存失败: ${result.message}');
          Helpers.showToast(context, result.message, isError: true);
        }
      }
    } catch (e, stackTrace) {
      print('保存个人资料时发生异常: $e');
      print('堆栈跟踪: $stackTrace');
      if (mounted) {
        String errorMessage = '更新失败，请稍后重试';
        
        // 提供更详细的错误信息
        if (e.toString().contains('Connection')) {
          errorMessage = '网络连接失败，请检查网络设置';
        } else if (e.toString().contains('timeout')) {
          errorMessage = '请求超时，请稍后重试';
        } else if (e.toString().contains('401')) {
          errorMessage = '登录已过期，请重新登录';
        } else if (e.toString().contains('500')) {
          errorMessage = '服务器内部错误，请稍后重试';
        }
        
        Helpers.showToast(context, errorMessage, isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _addInterest() {
    final interest = _interestController.text.trim();
    if (interest.isNotEmpty && !_interests.contains(interest)) {
      setState(() {
        _interests.add(interest);
        _interestController.clear();
      });
    }
  }

  void _removeInterest(String interest) {
    setState(() {
      _interests.remove(interest);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppConstants.backgroundColor,
      appBar: AppBar(
        title: Row(
          children: [
            Text(_saveSuccess ? '保存成功' : '编辑资料'),
            if (_saveSuccess) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle, color: Colors.green, size: 20),
            ],
          ],
        ),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveSuccess ? null : _saveProfile,
              child: Text(
                _saveSuccess ? '已保存' : '保存',
                style: TextStyle(
                  color: _saveSuccess ? Colors.green : Colors.white,
                  fontSize: AppConstants.fontSizeMedium,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 头像部分
              _buildAvatarSection(),
              
              const SizedBox(height: 32),
              
              // 基本信息
              _buildBasicInfoSection(),
              
              const SizedBox(height: 32),
              
              // 个人描述
              _buildBioSection(),
              
              const SizedBox(height: 32),
              
              // 兴趣爱好
              _buildInterestsSection(),
              
              const SizedBox(height: 32),
              
              // 社交信息
              _buildSocialSection(),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    final user = _authService.currentUser;
    
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            '头像',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 头像
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppConstants.primaryColor,
                child: user?.avatarUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50),
                        child: Image.network(
                          user!.avatarUrl!,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.person, size: 50, color: Colors.white),
                        ),
                      )
                    : const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppConstants.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    onPressed: () {
                      // TODO: 实现头像上传功能
                      Helpers.showToast(context, '头像上传功能开发中');
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '基本信息',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 昵称
          TextFormField(
            controller: _nicknameController,
            decoration: const InputDecoration(
              labelText: '昵称',
              hintText: '请输入昵称',
              prefixIcon: Icon(Icons.person),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return '请输入昵称';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 手机号
          TextFormField(
            controller: _phoneController,
            decoration: const InputDecoration(
              labelText: '手机号',
              hintText: '请输入手机号（可选）',
              prefixIcon: Icon(Icons.phone),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                  return '请输入有效的手机号';
                }
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // 位置
          TextFormField(
            controller: _locationController,
            decoration: const InputDecoration(
              labelText: '位置',
              hintText: '请输入所在位置（可选）',
              prefixIcon: Icon(Icons.location_on),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '个人简介',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 20),
          
          TextFormField(
            controller: _bioController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: '个人简介',
              hintText: '写点什么介绍一下自己吧...',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value != null && value.length > 200) {
                return '个人简介不能超过200字';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '兴趣爱好',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 添加兴趣的输入框
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _interestController,
                  decoration: const InputDecoration(
                    labelText: '添加兴趣',
                    hintText: '如：编程、音乐、运动等',
                    border: OutlineInputBorder(),
                  ),
                  onFieldSubmitted: (_) => _addInterest(),
                ),
              ),
              
              const SizedBox(width: 8),
              
              IconButton(
                onPressed: _addInterest,
                icon: const Icon(Icons.add, color: AppConstants.primaryColor),
                style: IconButton.styleFrom(
                  backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 兴趣标签列表
          if (_interests.isNotEmpty) ...[
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _interests.map((interest) => Chip(
                label: Text(interest),
                onDeleted: () => _removeInterest(interest),
                deleteIcon: const Icon(Icons.close, size: 18),
                backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
                labelStyle: const TextStyle(color: AppConstants.primaryColor),
              )).toList(),
            ),
          ] else ...[
            Text(
              '还没有添加兴趣爱好',
              style: TextStyle(
                color: AppConstants.textSecondaryColor,
                fontSize: AppConstants.fontSizeSmall,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSocialSection() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingLarge),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '社交信息',
            style: TextStyle(
              fontSize: AppConstants.fontSizeLarge,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          
          const SizedBox(height: 20),
          
          // QQ
          TextFormField(
            controller: _qqController,
            decoration: const InputDecoration(
              labelText: 'QQ号',
              hintText: '请输入QQ号（可选）',
              prefixIcon: Icon(Icons.chat_bubble_outline),
            ),
            keyboardType: TextInputType.number,
          ),
          
          const SizedBox(height: 16),
          
          // 微信
          TextFormField(
            controller: _wechatController,
            decoration: const InputDecoration(
              labelText: '微信号',
              hintText: '请输入微信号（可选）',
              prefixIcon: Icon(Icons.wechat, color: Colors.green),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 微博
          TextFormField(
            controller: _weiboController,
            decoration: const InputDecoration(
              labelText: '微博',
              hintText: '请输入微博用户名（可选）',
              prefixIcon: Icon(Icons.alternate_email, color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}