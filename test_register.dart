// 测试注册功能
import 'lib/core/dao/impl/user_dao_impl.dart';
import 'lib/dao/database_connection.dart';

Future<void> main() async {
  try {
    print('开始测试注册功能...');
    
    // 测试API连接
    final db = DatabaseConnection();
    final connectionStatus = await db.checkConnection();
    print('API连接状态: ${connectionStatus ? "成功" : "失败"}');
    
    if (!connectionStatus) {
      print('API服务器未启动，请确保后端服务运行在 http://localhost:8080');
      return;
    }
    
    final userDao = UserDaoImpl();
    
    // 测试注册新用户
    print('注册新用户...');
    final result = await userDao.createUser(
      studentNumber: '20230999',
      email: 'test999@zzuli.edu.cn',
      password: 'password123',
      nickname: '测试用户999',
      realName: '张三',
      major: '计算机科学与技术',
      grade: 2023,
    );

    if (result.isSuccess) {
      final user = result.data!;
      print('注册成功！用户ID: ${user.id}, 昵称: ${user.nickname}');
      
      // 测试登录刚注册的用户
      print('测试登录刚注册的用户...');
      final loginResult = await userDao.login(
        account: '20230999',
        password: 'password123',
      );
      
      if (loginResult.isSuccess) {
        print('登录成功！用户: ${loginResult.data!.user.nickname}');
        print('Token: ${loginResult.data!.token}');
      } else {
        print('登录失败: ${loginResult.error}');
      }
    } else {
      print('注册失败: ${result.error}');
    }
    
    print('注册功能测试完成');
  } catch (e) {
    print('测试异常: $e');
  }
}