// 测试个人资料更新功能的自动化脚本
import 'lib/services/auth_service.dart';
import 'lib/services/user_api_service.dart';
import 'lib/services/storage_service.dart';
import 'lib/utils/constants.dart';
import 'lib/models/user_model.dart';

Future<void> main() async {
  print('====== 开始自动化测试个人资料更新功能 ======');
  
  try {
    // 1. 初始化服务
    await StorageService.init();
    final authService = AuthService();
    await authService.initialize();
    
    print('\n1. 服务初始化完成');
    
    // 2. 执行登录
    print('\n2. 开始登录测试...');
    final loginResult = await authService.login(
      account: '542312320411',
      password: '542312320411',
    );
    
    if (!loginResult.isSuccess) {
      print('❌ 登录失败: ${loginResult.message}');
      return;
    }
    
    print('✅ 登录成功: ${loginResult.message}');
    print('   当前用户: ${authService.currentUser?.nickname}');
    print('   用户ID: ${authService.currentUser?.id}');
    
    // 3. 显示当前用户资料
    print('\n3. 当前用户资料信息:');
    final user = authService.currentUser;
    final profile = authService.currentUserProfile;
    
    if (user != null) {
      print('   昵称: ${user.nickname}');
      print('   手机: ${user.phone ?? "未设置"}');
      print('   邮箱: ${user.email}');
    }
    
    if (profile != null) {
      print('   个人简介: ${profile.bio ?? "未设置"}');
      print('   位置: ${profile.location ?? "未设置"}');
      print('   兴趣: ${profile.interests?.join(", ") ?? "未设置"}');
      print('   社交链接: ${profile.socialLinks ?? "未设置"}');
    }
    
    // 4. 测试更新个人资料
    print('\n4. 开始测试个人资料更新...');
    
    final testData = {
      'nickname': '自动化测试用户${DateTime.now().millisecondsSinceEpoch}',
      'phone': '13888888888',
      'bio': '这是通过自动化测试更新的个人简介 - ${DateTime.now()}',
      'location': '河南郑州',
      'interests': ['编程', '测试', '自动化', 'Flutter'],
      'socialLinks': {
        'qq': '123456789',
        'wechat': 'test_wechat',
        'weibo': 'test_weibo'
      }
    };
    
    print('   准备更新数据:');
    print('     昵称: ${testData['nickname']}');
    print('     手机: ${testData['phone']}');
    print('     简介: ${testData['bio']}');
    print('     位置: ${testData['location']}');
    print('     兴趣: ${testData['interests']}');
    print('     社交: ${testData['socialLinks']}');
    
    final updateResult = await authService.updateProfile(
      nickname: testData['nickname'] as String,
      phone: testData['phone'] as String,
      bio: testData['bio'] as String,
      location: testData['location'] as String,
      interests: testData['interests'] as List<String>,
      socialLinks: testData['socialLinks'] as Map<String, String>,
    );
    
    if (!updateResult.isSuccess) {
      print('❌ 更新失败: ${updateResult.message}');
      return;
    }
    
    print('✅ 更新成功: ${updateResult.message}');
    
    // 5. 验证更新结果
    print('\n5. 验证更新结果...');
    await authService.initialize(); // 重新初始化以读取最新数据
    
    final updatedUser = authService.currentUser;
    final updatedProfile = authService.currentUserProfile;
    
    bool allUpdatesSuccess = true;
    
    if (updatedUser != null) {
      if (updatedUser.nickname == testData['nickname']) {
        print('✅ 昵称更新成功: ${updatedUser.nickname}');
      } else {
        print('❌ 昵称更新失败: 期望=${testData['nickname']}, 实际=${updatedUser.nickname}');
        allUpdatesSuccess = false;
      }
      
      if (updatedUser.phone == testData['phone']) {
        print('✅ 手机号更新成功: ${updatedUser.phone}');
      } else {
        print('❌ 手机号更新失败: 期望=${testData['phone']}, 实际=${updatedUser.phone}');
        allUpdatesSuccess = false;
      }
    }
    
    if (updatedProfile != null) {
      if (updatedProfile.bio == testData['bio']) {
        print('✅ 个人简介更新成功: ${updatedProfile.bio}');
      } else {
        print('❌ 个人简介更新失败: 期望=${testData['bio']}, 实际=${updatedProfile.bio}');
        allUpdatesSuccess = false;
      }
      
      if (updatedProfile.location == testData['location']) {
        print('✅ 位置更新成功: ${updatedProfile.location}');
      } else {
        print('❌ 位置更新失败: 期望=${testData['location']}, 实际=${updatedProfile.location}');
        allUpdatesSuccess = false;
      }
      
      final expectedInterests = testData['interests'] as List<String>;
      if (updatedProfile.interests != null && 
          updatedProfile.interests!.length == expectedInterests.length &&
          updatedProfile.interests!.every((interest) => expectedInterests.contains(interest))) {
        print('✅ 兴趣更新成功: ${updatedProfile.interests?.join(", ")}');
      } else {
        print('❌ 兴趣更新失败: 期望=${expectedInterests.join(", ")}, 实际=${updatedProfile.interests?.join(", ")}');
        allUpdatesSuccess = false;
      }
      
      final expectedSocial = testData['socialLinks'] as Map<String, String>;
      if (updatedProfile.socialLinks != null && 
          updatedProfile.socialLinks!.length == expectedSocial.length) {
        bool socialMatch = true;
        expectedSocial.forEach((key, value) {
          if (updatedProfile.socialLinks![key] != value) {
            socialMatch = false;
          }
        });
        
        if (socialMatch) {
          print('✅ 社交链接更新成功: ${updatedProfile.socialLinks}');
        } else {
          print('❌ 社交链接更新失败: 期望=$expectedSocial, 实际=${updatedProfile.socialLinks}');
          allUpdatesSuccess = false;
        }
      } else {
        print('❌ 社交链接更新失败: 期望=$expectedSocial, 实际=${updatedProfile.socialLinks}');
        allUpdatesSuccess = false;
      }
    }
    
    // 6. 测试总结
    print('\n====== 测试结果总结 ======');
    if (allUpdatesSuccess) {
      print('🎉 所有个人资料更新测试均通过！');
      print('✅ 登录功能正常');
      print('✅ 个人资料更新功能正常');
      print('✅ 数据验证正常');
      print('✅ 本地存储更新正常');
    } else {
      print('❌ 部分测试失败，请检查上述错误信息');
    }
    
  } catch (e, stackTrace) {
    print('❌ 测试过程中发生异常: $e');
    print('堆栈跟踪: $stackTrace');
  }
  
  print('\n====== 测试完成 ======');
}