# 校园圈 Campus Circle

> 连接校园生活的社交平台

## 项目简介

校园圈是一个专为郑州轻工业大学学生打造的校园社交平台，提供动态分享、任务系统、聊天交流、积分奖励等功能，旨在丰富校园生活、促进同学交流。

## 功能特点

### 🎯 核心功能

- **用户系统**：学号注册、邮箱验证、个人资料管理
- **社交动态**：发布动态、点赞评论、关注互动
- **任务系统**：完成任务获得积分、积分兑换奖励
- **聊天系统**：私聊群聊、消息管理、在线状态
- **个人中心**：资料展示、数据统计、设置管理

### 📱 用户界面

- **现代化设计**：Material Design 3风格
- **响应式布局**：适配不同屏幕尺寸
- **流畅动画**：丰富的交互动效
- **深色模式**：支持主题切换（计划中）

## 技术栈

### 前端技术

- **框架**: Flutter 3.10+
- **语言**: Dart 3.0+
- **状态管理**: Provider
- **路由管理**: go_router
- **网络请求**: Dio
- **本地存储**: SharedPreferences
- **JSON序列化**: json_annotation

### 后端技术

- **数据库**: MySQL 8.0
- **字符集**: UTF-8 (支持emoji和中文)

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── config/                      # 配置文件
│   ├── app_routes.dart         # 路由配置
├── models/                      # 数据模型
│   └── user_model.dart         # 用户模型
├── services/                    # 服务层
│   ├── storage_service.dart    # 本地存储
│   ├── api_service.dart        # API服务
│   └── user_service.dart       # 用户服务
├── screens/                     # 页面
│   ├── splash_screen.dart      # 启动页
│   ├── login_screen.dart       # 登录页
│   ├── register_screen.dart    # 注册页
│   └── main_screen.dart        # 主框架页
├── pages/                       # 功能页面
│   ├── home_page.dart          # 首页
│   ├── chat_page.dart          # 聊天页
│   ├── task_page.dart          # 任务页
│   └── profile_page.dart       # 个人中心
├── widgets/                     # 自定义组件
│   └── user_avatar.dart        # 用户头像
└── utils/                       # 工具类
    ├── constants.dart          # 常量
    ├── validators.dart         # 验证器
    └── helpers.dart            # 帮助函数
```

## 快速开始

### 环境要求

- Flutter SDK 3.10+
- Dart SDK 3.0+
- Android Studio / VS Code
- MySQL 8.0+

### 安装步骤

1. **克隆项目**
   ```bash
   git clone https://github.com/your-repo/campus-circle.git
   cd campus-circle
   ```

2. **安装依赖**
   ```bash
   flutter pub get
   ```

3. **生成代码**
   ```bash
   flutter packages pub run build_runner build
   ```

4. **配置数据库**
   - 创建数据库 `campus_project`
   - 导入 `database.sql` 文件
   - 用户名：`root`，密码：`123456`

5. **运行项目**
   ```bash
   flutter run
   ```

## 用户注册规则

### 注册要求

- **学号**: 12位数字（如：542312320411）
- **邮箱**: 必须以 `@zzuli.edu.cn` 结尾
- **密码**: 至少6位字符
- **姓名**: 真实姓名，2-10个字符
- **专业**: 所学专业名称
- **年级**: 入学年份

### 初始化数据

注册成功后，系统自动初始化：
- 昵称默认为真实姓名
- 任务完成数：0
- 积分：0
- 用户等级：青铜（1级）
- 加入天数：0天

## 用户等级系统

| 等级 | 名称 | 颜色 |
|------|------|------|
| 1 | 青铜 | #CD7F32 |
| 2 | 白银 | #C0C0C0 |
| 3 | 黄金 | #FFD700 |
| 4 | 铂金 | #E5E4E2 |
| 5 | 钻石 | #B9F2FF |

## 功能详细说明

### 注册登录

- **多方式登录**：支持学号或邮箱登录
- **三步注册**：账号信息 → 个人信息 → 确认注册
- **实时验证**：注册时检查学号/邮箱可用性
- **安全认证**：密码加密存储，Token认证

### 聊天系统

- **私聊功能**：一对一聊天
- **群聊功能**：多人群组聊天
- **消息类型**：文本、图片、语音、视频、文件、位置
- **实时通信**：消息实时推送
- **未读提醒**：未读消息数量显示

### 任务系统

- **任务分类**：日常签到、发帖互动、校园活动、志愿服务等
- **难度等级**：简单、普通、困难
- **奖励机制**：积分奖励、实物奖励、优惠券
- **进度跟踪**：任务完成进度实时更新
- **筛选功能**：按分类、难度筛选任务

### 个人中心

- **资料管理**：头像、昵称、个人简介等
- **数据统计**：积分、动态数、获赞数
- **功能入口**：我的动态、任务记录、积分商城
- **系统设置**：通知设置、账号安全、帮助反馈

## 开发规范

### 代码规范

- 使用 `analysis_options.yaml` 进行代码检查
- 遵循 Dart 官方代码风格指南
- 文件命名使用小写字母和下划线
- 类名使用 PascalCase，变量名使用 camelCase

### Git 提交规范

```
feat: 新功能
fix: 修复bug  
docs: 文档更新
style: 代码格式调整
refactor: 代码重构
test: 测试相关
chore: 构建过程或辅助工具的变动
```

## 构建命令

```bash
# 获取依赖
flutter pub get

# 代码生成
flutter packages pub run build_runner build

# 运行应用
flutter run

# 构建APK
flutter build apk

# 构建iOS
flutter build ios
```

## 项目进度

- [x] 项目架构设计
- [x] 数据库设计
- [x] 用户认证系统
- [x] 主界面框架
- [x] 聊天系统界面
- [x] 任务系统界面
- [x] 个人中心界面
- [ ] 后端API接口
- [ ] 数据持久化
- [ ] 图片上传功能
- [ ] 消息推送
- [ ] 性能优化

## 待开发功能

### 即将开发

- [ ] 动态发布与浏览
- [ ] 积分商城
- [ ] 文件上传
- [ ] 消息推送
- [ ] 好友系统

### 计划开发

- [ ] 深色模式
- [ ] 多语言支持
- [ ] 语音聊天
- [ ] 视频通话
- [ ] 小程序插件

## 贡献指南

欢迎提交Issue和Pull Request！

1. Fork 项目
2. 创建功能分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送到分支 (`git push origin feature/AmazingFeature`)
5. 开启 Pull Request

## 许可证

本项目采用 MIT 许可证。详见 [LICENSE](LICENSE) 文件。

## 联系方式

- 项目维护者：校园圈开发团队
- 邮箱：2827766545@qq.com

## 致谢

感谢所有为项目贡献代码和建议的开发者！

---

**校园圈** - 让校园生活更精彩！ 🎓✨
