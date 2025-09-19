# 校园圈API后端

## 启动方法

1. 安装依赖：
```bash
cd api
npm install
```

2. 启动服务：
```bash
# 开发模式（自动重启）
npm run dev

# 或者直接启动
npm start
```

3. 服务地址：`http://localhost:8080`

## API接口文档

### 用户注册
- **POST** `/api/v1/auth/register`
- 请求体：
```json
{
  "student_number": "542312320411",
  "email": "test@zzuli.edu.cn", 
  "password": "123456",
  "nickname": "昵称",
  "real_name": "真实姓名",
  "major": "计算机科学与技术",
  "grade": 2023
}
```

### 用户登录
- **POST** `/api/v1/auth/login`
- 请求体：
```json
{
  "account": "542312320411", // 学号或邮箱
  "password": "123456"
}
```

### 检查学号
- **GET** `/api/v1/auth/check-student-number?student_number=542312320411`

### 检查邮箱
- **GET** `/api/v1/auth/check-email?email=test@zzuli.edu.cn`

### 健康检查
- **GET** `/api/v1/health`

## 分区交流功能API

### 分区管理
- **GET** `/api/v1/sections` - 获取所有分区列表
- **GET** `/api/v1/sections/:id` - 获取分区详情
- **POST** `/api/v1/sections` - 创建新分区（需要登录）
- **POST** `/api/v1/sections/:id/join` - 加入分区（需要登录）
- **DELETE** `/api/v1/sections/:id/leave` - 退出分区（需要登录）

### 分区帖子管理
- **GET** `/api/v1/sections/:id/posts` - 获取分区帖子列表
- **GET** `/api/v1/sections/:id/posts/:postId` - 获取帖子详情
- **POST** `/api/v1/sections/:id/posts` - 在分区发帖（需要登录）
- **POST** `/api/v1/sections/:id/posts/:postId/like` - 点赞/取消点赞（需要登录）
- **POST** `/api/v1/sections/:id/posts/:postId/comments` - 评论帖子（需要登录）

### 创建分区请求体示例
```json
{
  "name": "分区名称",
  "description": "分区描述",
  "icon": "school",
  "color": "#4A90E2",
  "is_public": 1,
  "join_permission": 1,
  "post_permission": 1,
  "rules": "分区规则（可选）"
}
```

### 发布帖子请求体示例
```json
{
  "title": "帖子标题",
  "content": "帖子内容",
  "content_type": 1,
  "is_anonymous": 0
}
```

### 评论请求体示例
```json
{
  "content": "评论内容",
  "parent_id": null,
  "is_anonymous": 0
}
```

## 数据库要求
- MySQL 5.7+
- 数据库名：`campus_project`
- 已导入 `database.sql` 中的表结构
- 新增分区功能相关表：
  - `sections` - 分区主表
  - `section_members` - 分区成员表
  - `section_posts` - 分区帖子表
  - `section_post_likes` - 分区帖子点赞表
  - `section_post_comments` - 分区帖子评论表
  - `section_comment_likes` - 分区评论点赞表

## 分区功能特性
1. **用户创建分区** - 用户可以创建自己的讨论区
2. **权限控制** - 支持公开/私有、加入权限、发帖权限设置
3. **独立板块** - 每个分区有独立的成员和帖子系统
4. **完整交流** - 支持发帖、评论、点赞功能
5. **实时统计** - 成员数、帖子数实时更新