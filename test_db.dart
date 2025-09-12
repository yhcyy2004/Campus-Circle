// 测试API数据库连接
import 'lib/dao/database_connection.dart';
import 'lib/core/dao/impl/user_dao_impl.dart';

Future<void> main() async {
  try {
    print('开始测试API连接...');
    
    // 测试API连接
    final db = DatabaseConnection();
    final connectionStatus = await db.checkConnection();
    print('API连接状态: ${connectionStatus ? "成功" : "失败"}');
    
    if (!connectionStatus) {
      print('API服务器未启动，请确保后端服务运行在 http://localhost:8080');
      return;
    }
    
    // 测试UserDaoImpl API调用
    print('测试UserDaoImpl API调用...');
    final userDao = UserDaoImpl();
    
    // 测试检查学号是否存在
    print('检查学号是否存在...');
    final studentExists = await userDao.checkStudentNumberExists('202001000001');
    print('学号202001000001是否存在: $studentExists');
    
    // 测试检查邮箱是否存在  
    print('检查邮箱是否存在...');
    final emailExists = await userDao.checkEmailExists('test1@zzuli.edu.cn');
    print('邮箱test1@zzuli.edu.cn是否存在: $emailExists');
    
    // 如果用户存在，测试登录
    if (studentExists || emailExists) {
      print('尝试登录测试用户...');
      final loginResult = await userDao.login(
        account: emailExists ? 'test1@zzuli.edu.cn' : '202001000001',
        password: 'password123',
      );
      
      if (loginResult.isSuccess) {
        print('登录成功: ${loginResult.data?.user.nickname}');
        print('Token: ${loginResult.data?.token}');
      } else {
        print('登录失败: ${loginResult.error}');
      }
    } else {
      print('没有找到测试用户，请先创建测试用户');
    }
    
    print('API连接测试完成');
  } catch (e) {
    print('API连接测试失败: $e');
  }
}