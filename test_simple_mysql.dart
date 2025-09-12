// 简单测试API连接
void main() {
  print('API连接测试');
  print('本项目现在使用HTTP API而不是直接MySQL连接');
  print('API基础URL: http://localhost:8080/api/v1');
  
  print('\n可用端点:');
  print('- POST /auth/register - 用户注册');
  print('- POST /auth/login - 用户登录');
  print('- GET /auth/check-student-number - 检查学号');
  print('- GET /auth/check-email - 检查邮箱');
  print('- GET /users/:id - 获取用户信息');
  print('- PUT /users/:id/profile - 更新用户资料');
  
  print('\n要测试连接，请确保后端服务器正在运行在 localhost:8080');
}